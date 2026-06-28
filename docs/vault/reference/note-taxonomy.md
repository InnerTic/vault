---
title: "Note Taxonomy"
tags:
  - reference
  - taxonomy
  - conventions
modified: 2026-06-28
---

# Note Taxonomy

Every note in the vault belongs to one of four types. Each has a distinct purpose, directory, and frontmatter schema.

```
                    Knowledge Vault
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   Learning           Engineering         Reference
   (courses)            (work)            (evergreen)
        │                  │                  │
    Lessons          Work Entries         Concepts
    Labs             Projects             APIs
    Exercises        Decisions            Commands
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
                     Daily Journal
                   (daily index only)
```

---

## 1. Learning

**Purpose:** Structured curricula with atomic lessons, labs, and exercises. Each topic is a small course.

**Directory:** `learning/<topic>/`

**Naming convention:**
```
learning/<topic>/
├── 00 - Roadmap.md
├── 01 - Lesson Title.md
├── 02 - Lesson Title.md
├── Labs/
│   ├── 01 - Lab Title.md
│   └── 02 - Lab Title.md
├── Cheat Sheets/
│   └── <topic>-cheat-sheet.md
└── Inbox/                    # AI drafts, pre-review
```

**Frontmatter:**
```yaml
---
title: "Lesson Title"
tags:
  - learning
  - <topic>
  - lesson-<N>
status: draft | review | evergreen
modified: YYYY-MM-DD
---
```

**Rules:**
- One concept per note. If a note covers more than one idea, split it.
- `status: draft` means AI-generated, unreviewed. `status: review` means pending human review. `status: evergreen` means approved and stable.
- All AI output lands in `Inbox/` first. Nothing goes directly into the numbered sequence without review.
- Labs live in `Labs/`, not in the numbered sequence.
- **Every file must be tagged.** Tags derived from directory + filename (e.g. `learning/tmux/02-Sessions.md` → `learning, tmux, sessions`).
- **Every file must be backlinkable.** Must contain at least one `[[wikilink]]` to another vault page. No orphan notes.
- **General AI drafts** (not part of a curriculum) go to `docs/vault/inbox/`. Same rules apply: tagged, backlinked, reviewed before promotion.

---

## 2. Engineering

**Purpose:** Record of work done — decisions, fixes, builds, sessions. Each entry is a single coherent piece of work with an immutable ID.

**Directories:**

| Subtype | Directory | Example |
|---------|-----------|---------|
| Work entries | `journal/entries/YYYY/` | `journal/entries/2026/20260628-003-Web-Pipeline.md` |
| Daily indexes | `journal/` | `journal/2026-06-28.md` |
| Projects | `projects/` | `projects/citation-attribution.md` |

**Work entry naming convention:**
```
YYYYMMDD-NNN-Short-Description.md
```
- `YYYYMMDD` — date
- `NNN` — sequential within that day (001, 002...)
- `Short-Description` — kebab-case summary

**Work entry frontmatter:**
```yaml
---
type: work-entry
id: YYYYMMDD-NNN
date: YYYY-MM-DD
status: completed | in-progress | blocked
confidence: high | medium | low
time_spent: Xh
projects:
  - "[[Project Name]]"
daily:
  - "[[YYYY-MM-DD]]"
systems:
  - "[[System Name]]"
scripts:
  - script-path
files:
  - file-path
created:
  - "[[Thing Created]]"
updated:
  - "[[Thing Updated]]"
tags:
  - tag1
  - tag2
modified: YYYY-MM-DD
---
```

**Immutable IDs:** The `id` field (YYYYMMDD-NNN) never changes. It is a stable reference point for Dataview timelines, backlinks, and provenance tracking. See [[#History field schema]].

**Rules:**
- One piece of work per entry. If a session covered three unrelated tasks, write three entries.
- IDs are immutable. Never change an ID after creation.
- Link `projects:` to the relevant project doc(s).
- Link `daily:` to the daily index note.

---

## 3. Reference

**Purpose:** Evergreen, fact-based documentation — concepts, APIs, commands, configs, glossaries. These are the stable knowledge layer.

**Directories:** `reference/`, `software/`, `system/`, `hardware/`, `scripts/`, `script-reference/`

**Frontmatter:**
```yaml
---
title: "Page Title"
tags:
  - reference
  - <category>
modified: YYYY-MM-DD
source: "optional provenance URL"
---
```

**Rules:**
- Facts only. Opinions and decisions belong in Engineering entries.
- `source:` field for external provenance (repos, docs, articles).
- Cross-link to Engineering entries that created or modified them via `history:` in frontmatter (see [[#History field schema]]).

---

## 4. Daily Journal

**Purpose:** Single-page index of what happened on a given day. Links to work entries, lessons studied, and notable events.

**Directory:** `journal/`

**Naming convention:** `YYYY-MM-DD.md`

**Frontmatter:**
```yaml
---
title: "YYYY-MM-DD"
tags:
  - journal
  - daily
modified: YYYY-MM-DD
---
```

**Rules:**
- One page per day. No exceptions.
- No inline content beyond a brief highlights list. Link to work entries (`[[YYYYMMDD-NNN]]`) for detail.
- Links to learning: `Studied [[01 - Lesson Title]]`, `Completed [[Lab 01 - Lab Title]]`.

---

## History field schema

Project docs, reference notes, and scripts can carry a `history:` field in frontmatter that lists engineering entry IDs in chronological order. This enables automatic timeline rendering via Dataview.

**Schema:**
```yaml
history:
  - "YYYYMMDD-NNN  Description"
  - "YYYYMMDD-NNN  Description"
```

**Example (projects/learning-pipeline.md):**
```yaml
history:
  - "20260628-?   Project created"
```

**Dataview query to render a timeline:**
```dataview
TABLE without id
  split(entry, "  ")[0] as "Entry",
  split(entry, "  ")[1] as "Description"
FROM "projects/learning-pipeline"
FLATTEN history as entry
SORT entry ASC
```

**Dataview query to auto-collect history from linked work entries:**
```dataview
TABLE
  id as "Entry",
  date as "Date",
  status as "Status"
FROM "journal/entries"
WHERE contains(projects, [[learning-pipeline]])
SORT id ASC
```

The second query is preferred — it requires no manual `history:` maintenance. But `history:` is useful when you want an explicit curated timeline (e.g., for a published project page).

---

## Summary

| Type | Purpose | Directory | Key frontmatter | Immutable? |
|------|---------|-----------|----------------|------------|
| Learning | Curricula, lessons, labs | `learning/` | title, tags, status | No |
| Engineering | Work records, decisions | `journal/entries/` | id, date, projects | Yes (id) |
| Reference | Concepts, APIs, commands | `reference/`, `software/`, etc. | title, tags, source | No |
| Daily | Day index | `journal/` | title, tags | No |
