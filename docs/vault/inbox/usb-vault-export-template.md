---
title: "USB Vault Export Template"
tags:
  - inbox
  - research
  - vault-design
  - quartz
modified: 2026-06-28
status: draft
---

A template for exporting the [[note-taxonomy|vault]] to a USB stick as a standalone, browsable website. Plug in USB → open `index.html` → everything readable, curated, story-driven. No Obsidian required.

---

## Top-level structure

```text
USB-Vault/
├── public/                     # Quartz build output (the actual website)
│   ├── index.html             # ENTRY POINT (open this)
│   ├── assets/
│   ├── Journal/
│   ├── Projects/
│   ├── Learning/
│   ├── Systems/
│   └── Events/
│
├── manifest.json              # optional metadata about export
├── build.sh                   # regenerate site
└── README.txt                 # fallback explanation for non-technical users
```

---

## Entry Design (CRITICAL)

### `public/index.html` → "Home Portal"

This is what your friend sees first.

#### Layout concept:

```text
────────────────────────────
  ENGINEERING KNOWLEDGE VAULT
────────────────────────────

What this is:
A personal engineering log turned into a navigable knowledge system.

Start here:
[ Start Here ]
[ Engineering Timeline ]
[ Projects ]
[ Learning Paths ]
[ Systems Overview ]

Recent Activity:
- 20260628-003 Web Pipeline
- 20260628-002 Citation Pipeline
- 20260628-001 Meta Scripts Fix
```

---

## 1. Start Here Page

### `public/Start-Here.html`

Explain the system in 30 seconds.

```markdown
# Start Here

This vault is a snapshot of an engineering system.

It is organized into four layers:

## 1. Engineering Events
Atomic work units (like commits)

## 2. Projects
Ongoing systems built from events

## 3. Learning
Structured skill development (tmux, networking, etc)

## 4. Systems
Infrastructure components (Quartz, Firecrawl, etc)

---

## How to browse

Start with:
👉 Engineering Timeline

Then explore:
- Projects
- Learning paths
- Individual events
```

---

## 2. Engineering Timeline (core artifact)

### `public/Journal/index.html`

This is your "Git log for life":

```text
ENGINEERING TIMELINE
────────────────────

June 2026

20260628-003 Web Pipeline
20260628-002 Citation Pipeline
20260628-001 Meta Scripts Fix

20260627-XXX ...
```

Each item links to a full event page.

---

## 3. Engineering Event Template (core unit)

### `public/Events/20260628-003-web-pipeline.html`

```markdown
# Web Pipeline (20260628-003)

## Summary
A 3-stage web acquisition system was built:
Firecrawl → Playwright Stealth → Persistent Browser

## Why it exists
To bypass bot detection systems and ensure reliable scraping.

## Systems involved
- Firecrawl
- Playwright
- Chromium persistent context

## Decisions made
- Escalation-based fetch pipeline
- Cache layer (10 min TTL)
- Persistent browser fallback

## Related work
- 20260628-002 Citation Pipeline
- 20260626-002 Meta Scripts Fix

## Outcome
Stable multi-tier web scraping system
```

Key rule: each event = one engineering "commit"

---

## 4. Projects Page

### `public/Projects/index.html`

```text
PROJECTS
────────

Web Pipeline
- Last updated: 20260628-003
- Status: Active
- Related events:
  - 20260628-003
  - 20260627-002

Citation Pipeline
- Last updated: 20260628-002
- Status: Active
```

Each project page auto-links events.

---

## 5. Learning System

### `public/Learning/tmux/index.html`

```text
TMUX LEARNING PATH
──────────────────

Progress:
[███░░░░░░░] 30%

Lessons:
1. Sessions
2. Windows
3. Panes
4. Copy Mode
5. Scripting

Labs:
- Lab 01: Sessions
- Lab 02: Window navigation
- Lab 03: Panes

Recent Activity:
- 20260628-004 tmux Lab 03 completed
```

---

## 6. Systems Page

### `public/Systems/index.html`

```text
SYSTEMS OVERVIEW
────────────────

Quartz         — Static site generator for vault publishing
Firecrawl      — Web scraping pipeline
Playwright     — Browser automation layer
Vault Attribution — Citation validation system
```

---

## 7. Navigation Model

Every page must include:

```text
Back to:
- Home
- Timeline
- Projects
```

No dead ends.

---

## 8. Export Script

```bash
#!/usr/bin/env bash

echo "Building Quartz vault..."
npx quartz build

echo "Copying to USB export folder..."
rm -rf /mnt/usb/Vault/public
cp -r public /mnt/usb/Vault/

echo "Export complete."
```

Optional upgrades: auto-timestamp export folder, compress snapshot, generate changelog page.

---

## 9. README.txt (for non-technical users)

```text
This USB contains a personal engineering knowledge system.

To use:
1. Open folder "public"
2. Double click "index.html"
3. Click "Start Here"

This system contains:
- Development logs
- Projects
- Learning paths
- Technical systems

No installation required. Works offline.
```

---

## Design Principles

1. **Read-only first** — This is a snapshot artifact, not a tool.
2. **Everything links upward** — Events → Projects → Learning → Systems → Timeline → Home.
3. **No raw file browsing** — Never expose markdown directories, vault structure, or hidden config. Only curated pages.
4. **Events are the atomic unit** — Everything important becomes an Event.

---

## Optional future upgrade: "Narrative Mode"

A page at `The-Evolution-of-My-System.html` that tells the story chronologically:

- Meta Scripts failure → citation pipeline creation → web pipeline escalation → learning system design

This is what makes it interesting to other people.

---

## What this template gives you

When you plug in the USB:
- Instantly browsable system
- No install required
- No Obsidian knowledge needed
- Readable engineering history
- Structured learning system
- Narrative coherence

---

## Next step

Can upgrade this into a fully automated exporter:
- Fish script
- Quartz build
- Event index generator
- Auto project timelines
- USB sync command
- Optional compression snapshot system
