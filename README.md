# RVC Photo Library

Public photo library for Relentless Value Coaching (RVC) — used by the carousel skill, landing pages, social media, and ad creative.

## How to use

Photos are referenced by their raw GitHub URL. Pattern:

```
https://raw.githubusercontent.com/justingoodbread/rvc-photo-library/main/<path>/<filename>
```

Example:

```
https://raw.githubusercontent.com/justingoodbread/rvc-photo-library/main/justin/headshots/web-2026/jg-headshot-web-01.jpg
```

## Index

### `destination-decamillionaire/`

In-person bootcamp photos from RVC's Destination DecaMillionaire events.

| Event | Path | Photos |
|-------|------|--------|
| Nashville 2026 (Feb 25-26) | `destination-decamillionaire/bootcamps/nashville-2026/` | Day 1: 19, Day 2: 5 |

### `justin/`

Justin Goodbread photos by category and use case.

| Category | Path | Files | Use case |
|----------|------|-------|----------|
| Web headshots (current) | `justin/headshots/web-2026/` | 4 | Landing pages, social profiles |
| Pro shoot headshots (2024) | `justin/headshots/pro-shoot-2024/` | 5 | Ad creative, hero images, print |
| Portrait set (Feb 2024) | `justin/headshots/portraits-2024/` | 3 | Smaller assets, thumbnails |
| Speaking — freecall (Mar 2026) | `justin/speaking/jg-speaking-freecall-2026.jpg` | 1 | Speaking proof |
| Speaking — Exit Planning Summit (May 2025) | `justin/speaking/exit-planning-summit-2025/` | 3 | Speaking proof, authority |
| Lifestyle — Anguilla (Apr 2026) | `justin/lifestyle/jg-lifestyle-anguilla-2026.jpg` | 1 | Lifestyle / brand |

### `proof/client-wins/`

Slack-style client win screenshots used as social proof. **Last names redacted** (white box overlay) — first names preserved for relatability. Use these as carousel proof slides, ad creative, landing page testimonials.

| File | First name | Notes |
|------|------------|-------|
| `client-win-darren-01.png` | Darren | Team / SOP / operations win |
| `client-win-darren-02.png` | Darren | Personnel decisions win |
| `client-win-dan-01.png` | Dan | Team / vacation / hands-off win |
| `client-win-robert-01.png` | Robert | CFO / financials win |
| `client-win-robert-02.png` | Robert | Fee schedule / compliance win |
| `client-win-robert-03.png` | Robert | Investment in people win |
| `client-win-scott-01.png` | Scott | Core values / management system |
| `client-win-scott-02.png` | Scott | Employee attrition reduction |
| `client-win-frank-01.png` | Frank | 90-Day plan / new clients |
| `client-win-frank-02.png` | Frank | Operations / 130 ops procedures |
| `client-win-eric-01.png` | Eric | "Totally relentless" testimonial |
| `client-win-garrett-01.png` | Garrett | Surge meetings / automations |

## Naming conventions

### Event photos
```
<event-prefix>-<location>-<year>-day<N>-<NN>.jpg
```

### Justin photos
```
jg-<category>-<context>-<NN>.jpg
```
Examples: `jg-headshot-web-01.jpg`, `jg-speaking-eps-2025-02.jpg`, `jg-lifestyle-anguilla-2026.jpg`

### Client wins
```
client-win-<firstname>-<NN>.png
```

## Folder conventions

### Event photos
```
<program>/<format>/<location>-<year>/day<N>/
```
Scales as more events are added (e.g. `destination-decamillionaire/bootcamps/austin-2026/`, `mda-summit/keynotes/2027/`).

### Justin photos
```
justin/<category>/<context>/
```
Categories: `headshots`, `speaking`, `lifestyle`. Context groups by shoot or event.

### Proof
```
proof/<type>/
```
Types: `client-wins/` (Slack screenshots, redacted), future: `testimonial-videos/`, `case-studies/`, etc.
