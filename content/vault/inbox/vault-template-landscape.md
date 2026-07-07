---
title: "Vault Template Landscape — Existing Systems Compared"
tags:
  - inbox
  - research
  - knowledge-management
  - vault-design
modified: 2026-06-28
status: draft
---

An analysis of existing PKM systems relative to the [[note-taxonomy]] and vault architecture. But there *are* partial systems you can steal pieces from, and a couple of templates that get you ~40–70% of the way.

What you're building is closer to a hybrid of:

- Zettelkasten (knowledge graph)
- PARA (projects/areas/resources/archive)
- Dev changelog systems (engineering events)
- Personal CRM / work logs
- Git-style commit history thinking

No single template fully fuses those.

---

## 1. Obsidian "Johnny Decimal / PARA dashboards"

### Closest structural match for your *index layer*

People build:
- Daily notes
- Project notes
- Area dashboards
- MOCs (maps of content)

Typical templates:
- PARA vault templates
- "Digital Brain" templates (various GitHub repos)

What they give you:
```
Daily Notes → Projects → Knowledge
```

What they *don't* give you:
- event IDs
- engineering log granularity
- automated provenance tracking

Search terms:
- "Obsidian PARA template vault"
- "Obsidian digital brain template GitHub"

---

## 2. Zettelkasten "slip-box systems"

### Closest to your Knowledge Layer

Examples:
- Luhmann-style systems
- Evergreen notes systems (Andy Matuschak-inspired)
- "Atomic notes" templates

What they give:
```
Idea → Note → Backlinks → Emergent structure
```

Useful part for you:
- strict single-concept notes
- heavy linking discipline

Missing:
- operational logs
- system state tracking
- time-based event indexing

Search:
- "Obsidian Zettelkasten template evergreen notes"

---

## 3. "Engineering logs / dev diary systems" (rare but relevant)

### Closest to your journal layer

There are a few dev-focused vaults where people do:
- daily coding logs
- bug logs
- build logs

Example patterns:
```
YYYY-MM-DD Dev Log
  - What I did
  - Bugs
  - Commands
  - Decisions
```

Sometimes used in:
- game dev journals
- indie hacker logs
- solo engineering notebooks

What they give:
- chronological clarity
- reproducibility mindset

What they don't:
- structured event IDs like yours
- cross-system linking (scripts/projects/knowledge)

Search:
- "developer journal obsidian template"
- "engineering log template markdown"

---

## 4. "Obsidian Digital Garden / Quartz sites"

### Closest to your publishing layer

Quartz itself already is part of this ecosystem:
- Obsidian → Quartz publishing
- digital gardens
- public second brains

Templates:
- Quartz starter themes
- Digital Garden starter kits

What they give:
- publishing layer
- backlinks
- graph view

What they don't:
- workflow model
- learning pipeline
- engineering event system

Search:
- "Quartz digital garden template"
- "Obsidian Quartz starter kit"

---

## 5. The closest *philosophical match* (important)

The closest thing conceptually is:

### "Event-sourced personal knowledge systems"

This is not a mainstream Obsidian template category, but shows up in:
- event sourcing (software architecture)
- temporal databases
- Git commit thinking applied to life logs

This is **the closest conceptual sibling to your system**.

Your system is basically:
```
Event Sourcing applied to knowledge work
```

Where:
- Event = 20260628-002 Citation Pipeline
- State = current vault
- Projections = projects, learning, scripts, graphs, Quartz site

That's why you're not finding a ready-made template:
most PKM systems are **state-based**, not **event-based**.

---

## What I would do (practical answer)

Instead of searching for a perfect template, take 3 partial systems and fuse them:

### Base layer (structure)
- PARA vault template OR Johnny Decimal vault

### Knowledge layer
- Zettelkasten / evergreen notes style

### Execution layer (your innovation)
- your engineering event system (IDs like 20260628-002)

---

## If you want something closer to "drop-in usable"

I can build you a **Quartz + Obsidian starter architecture** that includes:

- `/Journal/` (event-sourced logs)
- `/Events/` (your 2026-XX-XX-XXX system)
- `/Learning/` (tmux, docker, etc curriculum system)
- `/Projects/` (auto-linked event timeline)
- `/Knowledge/` (evergreen notes)
- `/Inbox/` (AI-generated drafts)

Plus:
- Dataview queries prebuilt
- Event index page auto-generated
- "What changed today" page
- "System evolution timeline"
- backlink rules for AI agents

That would basically turn what you're building into a **repeatable template system instead of a one-off vault design**.

---

## Next steps

Options:
1. Build a **Quartz-ready vault template structure (folders + starter notes)**
2. Design your **Event schema formally (like a mini database spec)**
3. Write your **AI "research → event → knowledge" pipeline as actual commands**
4. Or map your current vault into this model cleanly without breaking anything

Your system is already past "template stage" in spirit, but it's still early enough that structuring it now will save you a lot of future refactoring.
