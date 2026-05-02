# RVC Photo Library

Public photo library for Relentless Value Coaching (RVC) — used by the carousel skill, landing pages, social media, and ad creative.

## How to use

Photos are referenced by their raw GitHub URL. Pattern:

```
https://raw.githubusercontent.com/justingoodbread/rvc-photo-library/main/<path>/<filename>.jpg
```

Example:

```
https://raw.githubusercontent.com/justingoodbread/rvc-photo-library/main/destination-decamillionaire/bootcamps/nashville-2026/day1/dd-nashville-2026-day1-01.jpg
```

## Index

### destination-decamillionaire/

In-person bootcamp photos from RVC's Destination DecaMillionaire events.

| Event | Path | Photos |
|-------|------|--------|
| Nashville 2026 (Feb 25-26) | `destination-decamillionaire/bootcamps/nashville-2026/` | Day 1: 19, Day 2: 5 |

## Naming convention

Files follow this pattern:

```
<event-prefix>-<location>-<year>-day<N>-<NN>.jpg
```

- `event-prefix` — short event code (`dd` = Destination DecaMillionaire)
- `location` — city slug (e.g. `nashville`)
- `year` — 4-digit year
- `day<N>` — day number within the event (`day1`, `day2`)
- `<NN>` — chronological sequence within that day, zero-padded (`01`, `02`, ...)

## Folder convention

```
<program>/<format>/<location>-<year>/day<N>/
```

Example: `destination-decamillionaire/bootcamps/nashville-2026/day1/`

This scales as more events, programs, or formats are added (e.g. `destination-decamillionaire/bootcamps/austin-2026/`, `mda-summit/keynotes/2027/`).
