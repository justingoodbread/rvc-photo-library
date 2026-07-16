#!/usr/bin/env bash
#
# pull-photos.sh — pull photos from a Google Drive folder into this repo,
# web-optimized and sequentially named. Speeds up the manual workflow.
#
# WHAT IT DOES
#   1. Downloads images from a Drive folder (or an explicit list of file IDs)
#   2. Optimizes each for web (resize long edge, recompress) — never upscales
#   3. Names them <prefix>-NN.jpg, continuing after any existing ones in --dest
#   4. (optional) builds a contact sheet so you can review before committing
#
# REQUIREMENTS  (already on this Mac)
#   - gdown   (pip install gdown)      for --folder mode
#   - sips    (built into macOS)       for optimize/resize
#   - ffmpeg  (brew install ffmpeg)    only for --sheet
#
# ------------------------------------------------------------------------------
# USAGE
#
#   Folder mode (folder must be shared "Anyone with the link"; gdown caps ~50 files):
#     scripts/pull-photos.sh \
#       --folder <DRIVE_FOLDER_ID> \
#       --dest justin/relentless \
#       --prefix jg-relentless \
#       --sheet
#
#   ID-list mode (no 50-file cap; works for any list of public file IDs):
#     scripts/pull-photos.sh \
#       --ids ids.txt \
#       --dest destination-decamillionaire/bootcamps/austin-2026/day1 \
#       --prefix dd-austin-2026-day1
#     # ids.txt = one Google Drive FILE id per line
#
# OPTIONS
#   --folder ID        Drive folder id (public link-shared)
#   --ids FILE         text file of Drive file ids, one per line
#   --dest PATH        repo-relative destination folder (created if missing)
#   --prefix NAME      filename prefix; output is <prefix>-01.jpg, -02, ...
#   --maxdim N         max long-edge pixels (default 2000)
#   --quality N        jpeg quality 1-100 (default 80)
#   --sheet            build a contact sheet at /tmp/pull-photos-sheet.png
#   --commit "MSG"     git add/commit --dest with MSG and push to origin main
#   --dry-run          download + list what WOULD be created, but don't write to --dest
#   -h | --help        show this help
#
# NOTES
#   - Videos (.mp4/.mov) and RAW (.cr2) are skipped automatically.
#   - Re-running with the same --dest/--prefix APPENDS (continues numbering).
#   - This repo is PUBLIC. Do not pull personal/private photos into it.
# ------------------------------------------------------------------------------

set -euo pipefail

FOLDER=""; IDS=""; DEST=""; PREFIX=""; MAXDIM=2000; QUALITY=80
SHEET=0; COMMIT=""; DRYRUN=0

die(){ echo "ERROR: $*" >&2; exit 1; }
usage(){ sed -n '2,55p' "$0"; exit 0; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --folder) FOLDER="$2"; shift 2;;
    --ids) IDS="$2"; shift 2;;
    --dest) DEST="$2"; shift 2;;
    --prefix) PREFIX="$2"; shift 2;;
    --maxdim) MAXDIM="$2"; shift 2;;
    --quality) QUALITY="$2"; shift 2;;
    --sheet) SHEET=1; shift;;
    --commit) COMMIT="$2"; shift 2;;
    --dry-run) DRYRUN=1; shift;;
    -h|--help) usage;;
    *) die "unknown option: $1 (use --help)";;
  esac
done

[[ -n "$DEST" ]]   || die "--dest is required"
[[ -n "$PREFIX" ]] || die "--prefix is required"
[[ -n "$FOLDER" || -n "$IDS" ]] || die "give --folder OR --ids"
command -v sips >/dev/null || die "sips not found (macOS only)"

# repo root = parent of this script's dir
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_ABS="$REPO_ROOT/$DEST"
TMP="$(mktemp -d /tmp/pull-photos.XXXXXX)"
RAW="$TMP/raw"; mkdir -p "$RAW"
trap 'rm -rf "$TMP"' EXIT

echo "▶ repo:   $REPO_ROOT"
echo "▶ dest:   $DEST   (prefix: $PREFIX)"
echo "▶ tmp:    $TMP"

# ---- 1. download -------------------------------------------------------------
if [[ -n "$FOLDER" ]]; then
  command -v gdown >/dev/null || die "gdown not found (pip install gdown)"
  echo "▶ downloading folder via gdown ..."
  gdown --folder "https://drive.google.com/drive/folders/$FOLDER" --remaining-ok -O "$RAW" >/dev/null 2>&1 \
    || die "gdown failed — is the folder shared 'Anyone with the link'?"
  # flatten any subfolders gdown created
  find "$RAW" -mindepth 2 -type f -exec mv -n {} "$RAW"/ \; 2>/dev/null || true
else
  [[ -f "$IDS" ]] || die "--ids file not found: $IDS"
  echo "▶ downloading by id list ..."
  n=0
  while IFS= read -r id; do
    id="$(echo "$id" | tr -d '[:space:]')"; [[ -n "$id" ]] || continue
    n=$((n+1)); out="$RAW/$(printf '%04d' $n).bin"
    curl -sL "https://drive.google.com/uc?export=download&id=$id" -o "$out"
    if file "$out" | grep -qi 'HTML'; then
      echo "  ⚠ id $id returned an HTML page (not public / not found) — skipping"; rm -f "$out"; continue
    fi
    # give it a real extension so the image filter below sees it
    case "$(file -b --mime-type "$out")" in
      image/jpeg) mv "$out" "${out%.bin}.jpg";;
      image/png)  mv "$out" "${out%.bin}.png";;
      image/heic) mv "$out" "${out%.bin}.heic";;
      *) echo "  ⚠ id $id is not an image ($(file -b --mime-type "$out")) — skipping"; rm -f "$out";;
    esac
  done < "$IDS"
fi

# ---- 2. collect images (skip video/raw) --------------------------------------
# (portable: macOS bash 3.2 has no `mapfile`)
IMGS=()
while IFS= read -r line; do IMGS+=("$line"); done < <(find "$RAW" -maxdepth 1 -type f \
  \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.heic' \) | sort)
[[ ${#IMGS[@]} -gt 0 ]] || die "no images downloaded"
echo "▶ images downloaded: ${#IMGS[@]}"
skipped=$(find "$RAW" -maxdepth 1 -type f \( -iname '*.mp4' -o -iname '*.mov' -o -iname '*.cr2' \) | wc -l | tr -d ' ')
[[ "$skipped" -gt 0 ]] && echo "  (skipped $skipped video/raw files)"

# ---- 3. figure out starting index (append mode) ------------------------------
start=1
if [[ -d "$DEST_ABS" ]]; then
  last=$(ls "$DEST_ABS"/${PREFIX}-*.jpg 2>/dev/null | sed -E "s/.*${PREFIX}-0*([0-9]+)\.jpg/\1/" | sort -n | tail -1 || true)
  [[ -n "${last:-}" ]] && start=$((last+1))
fi
echo "▶ numbering starts at $(printf '%02d' $start)"

# ---- 4. optimize + name ------------------------------------------------------
[[ $DRYRUN -eq 1 ]] || mkdir -p "$DEST_ABS"
i=$start
declare -a MADE=()
for f in "${IMGS[@]}"; do
  n=$(printf '%02d' $i)
  outname="${PREFIX}-${n}.jpg"
  out="$DEST_ABS/$outname"
  long=$(sips -g pixelWidth -g pixelHeight "$f" 2>/dev/null | awk '/pixelWidth:|pixelHeight:/{print $2}' | sort -nr | head -1)
  if [[ $DRYRUN -eq 1 ]]; then
    echo "  would create $DEST/$outname   (from $(basename "$f"), ${long}px)"
  else
    if [[ -n "$long" && "$long" -gt "$MAXDIM" ]]; then
      sips -Z "$MAXDIM" -s format jpeg -s formatOptions "$QUALITY" "$f" --out "$out" >/dev/null 2>&1
    else
      sips -s format jpeg -s formatOptions "$QUALITY" "$f" --out "$out" >/dev/null 2>&1
    fi
    MADE+=("$out")
    echo "  ✓ $DEST/$outname"
  fi
  i=$((i+1))
done
[[ $DRYRUN -eq 1 ]] && { echo "▶ dry run — nothing written. re-run without --dry-run to apply."; exit 0; }
echo "▶ created ${#MADE[@]} file(s) in $DEST"

# ---- 5. contact sheet (optional) --------------------------------------------
if [[ $SHEET -eq 1 ]]; then
  command -v ffmpeg >/dev/null || { echo "  ⚠ ffmpeg not found — skipping sheet"; }
  if command -v ffmpeg >/dev/null; then
    ST="$TMP/sheet"; mkdir -p "$ST"; j=0
    for f in "${MADE[@]}"; do
      j=$((j+1)); nn=$(printf '%03d' $j)
      ffmpeg -loglevel error -y -i "$f" -vf \
        "scale=320:320:force_original_aspect_ratio=decrease,pad=320:320:(ow-iw)/2:(oh-ih)/2:white,drawtext=text='$nn':x=5:y=5:fontsize=22:fontcolor=red:box=1:boxcolor=white" \
        "$ST/$nn.png" 2>/dev/null || true
    done
    cols=6; rows=$(( (${#MADE[@]} + cols - 1) / cols )); [[ $rows -lt 1 ]] && rows=1
    ffmpeg -loglevel error -y -framerate 1 -pattern_type glob -i "$ST/*.png" \
      -filter_complex "tile=${cols}x${rows}:margin=4:padding=4:color=black" \
      /tmp/pull-photos-sheet.png 2>/dev/null || true
    echo "▶ contact sheet: /tmp/pull-photos-sheet.png"
  fi
fi

# ---- 6. commit (optional) ----------------------------------------------------
if [[ -n "$COMMIT" ]]; then
  git -C "$REPO_ROOT" add "$DEST"
  git -C "$REPO_ROOT" commit -q -m "$COMMIT" && echo "▶ committed: $COMMIT"
  git -C "$REPO_ROOT" push origin main 2>&1 | tail -1
fi

echo "✅ done."
