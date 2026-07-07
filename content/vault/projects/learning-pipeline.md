---
title: "Learning Pipeline"
tags:
  - projects
  - learning
  - curriculum
  - local-ai
modified: 2026-06-28
history:
  - "20260628-003  Pipeline architecture designed"
  - "20260628-003  learn-topic agent script written"
---

# Learning Pipeline

**Goal:** Turn vault topics into structured curricula. AI researches and drafts; you review and own. Every topic becomes a sequence of atomic lessons, labs, and journal entries — not a wall of text.

## Why

Single "Learn X" notes are graveyards. They get written once, never updated, never practiced. A curriculum with discrete lessons and labs creates:

- **Reviewable units** — each lesson is small enough to fact-check
- **Practice loops** — labs separate theory from hands-on
- **Progress visibility** — Dataview shows what's done vs. pending
- **Journal integration** — daily entries link to specific lessons studied
- **Reusable pipeline** — same process for tmux, Docker, Kubernetes, networking, Python, Playwright, etc.

## Pipeline

```
Topic
  │
  ▼
1. Planner    — Break topic into modules, lessons, labs, estimate time
  │
  ▼
2. Researcher — AI gathers info for ONE lesson at a time
  │
  ▼
3. Inbox      — Drafts land in Learning/<topic>/Inbox/ (never permanent)
  │
  ▼
4. Review     — You read, edit, approve, or reject
  │
  ▼
5. Knowledge  — Reviewed note moves to Learning/<topic>/ (permanent)
  │
  ▼
6. Lab        — AI generates hands-on exercises for your homelab setup
  │
  ▼
7. Journal    — Daily entries link to labs done and discoveries made
```

### Phase 1 — Planner

Prompt the local AI to analyze a topic and produce:

- Prerequisites (with links to existing vault pages)
- Modules (logical groupings)
- Lessons per module (smallest atomic unit)
- Labs per module
- Estimated time
- Dependencies between lessons

Output goes to `Learning/<topic>/00 - Roadmap.md`.

### Phase 2 — Researcher

For each lesson, the AI receives a structured research task:

```
Research <topic>: <lesson title>

Requirements:
- Explain conceptually (what, why, when)
- Terminology
- Common commands / patterns
- Best practices
- Common mistakes
- Cross-links to related vault pages
- Practice exercises
- Markdown suitable for Obsidian with [[wikilinks]]
```

One request per lesson. Output is a single focused note.

### Phase 3 — Inbox

All AI output lands in `Learning/<topic>/Inbox/`. Nothing touches the permanent lesson directory without review. The inbox is a quarantine — the AI drafts freely, you decide what stays.

### Phase 4 — Review

You read the draft. Things to check:

- Technical accuracy (the local model can hallucinate)
- Relevance to your actual homelab setup
- Cross-links to existing vault pages
- Whether the scope is right (too big → split, too small → merge)

### Phase 5 — Knowledge

Approved notes move from `Inbox/` to `Learning/<topic>/`. They are now permanent curriculum. Run `vault-journal-backlink.sh` to backlink them from the journal retroactively.

### Phase 6 — Lab Generator

After a module's lessons are reviewed, the AI generates lab exercises:

```
Create lab exercises for <topic>: <module name>

Requirements:
- Usable on the actual Akuma homelab (dual GPU, LXC, QEMU/KVM)
- Step-by-step instructions
- Verification steps (how to know it worked)
- Estimated time per exercise
- Cross-links to relevant lessons
```

Labs go in `Learning/<topic>/Labs/`.

### Phase 7 — Journal Integration

Daily notes link what you studied:

```
Worked through [[Lab 03 - Panes]]
Reviewed [[tmux/04 - Panes]]
Discovered Ctrl+b q shows pane numbers
```

The `vault-journal-backlink.sh` script automatically finds and links these references.

## Directory Structure

```
docs/vault/learning/
├── README.md                    # Index of all topics
│
├── tmux/                        # First topic (see below)
│   ├── 00 - Roadmap.md
│   ├── 01 - What is tmux.md
│   ├── 02 - Sessions.md
│   ├── 03 - Windows.md
│   ├── 04 - Panes.md
│   ├── 05 - Commands.md
│   ├── 06 - Configuration.md
│   ├── 07 - Scripting.md
│   ├── 08 - Copy Mode.md
│   ├── 09 - Remote Workflows.md
│   ├── 10 - Homelab Workspaces.md
│   ├── Inbox/                   # AI drafts, pre-review
│   ├── Labs/
│   │   ├── 01 - Create sessions.md
│   │   ├── 02 - Detach and reconnect.md
│   │   ├── 03 - Split panes.md
│   │   ├── 04 - Remote server workflow.md
│   │   └── 05 - Persistent AI workspace.md
│   └── Cheat Sheets/
│
├── docker/                      # Future topic
├── kubernetes/                  # Future topic
├── networking/                  # Future topic
└── <topic>/                     # Next topic
```

### When to add a subdirectory

If a topic generates enough volume to warrant its own structure (multiple modules, labs, cheatsheets), it gets a subdirectory under `learning/`. For a single-guide topic, one file at `learning/<topic>.md` suffices until it grows.

## Tmux Curriculum (First Topic)

The tmux curriculum is the pilot. It validates the pipeline before generalizing to other topics.

Existing vault knowledge: [[tmux-agent-interface|tmux Agent Interface Project]] (8 research docs), [[commands|Commands Reference]], [[quick-commands|Quick Commands]].

### Roadmap

| # | Lesson | Est. | Prerequisites | Backlinks |
|---|--------|------|--------------|-----------|
| 01 | What is tmux? | 30m | [[commands|Linux terminal]] | [[tmux-agent-interface]] |
| 02 | Sessions | 1h | Lesson 01 | [[tmux-research-v2\|tmux Sessions]] |
| 03 | Windows | 1h | Lesson 02 | [[tmux-research-v2\|tmux Windows]] |
| 04 | Panes | 1.5h | Lesson 03 | [[tmux-research-v2\|tmux Panes]] |
| 05 | Commands | 1h | Lessons 02-04 | [[commands\|tmux Commands]], [[tmux-research-v3-ref\|Config Reference]] |
| 06 | Configuration | 1h | Lesson 05 | [[tmux-research-v3-ref\|Config Reference]], [[bootstrap-configs\|Bootstrap Configs]] |
| 07 | Scripting | 2h | Lesson 06 | [[tmux-research-v2\|Scripting tmux]] |
| 08 | Copy Mode | 1h | Lesson 05 | [[tmux-research-v2\|Copy Mode]] |
| 09 | Remote Workflows | 1.5h | Lessons 02-05, [[proxmox-ssh-infrastructure\|SSH]] | [[ai-ssh-architecture\|AI SSH Architecture]] |
| 10 | Homelab Workspaces | 2h | All above | [[tmux-agent-interface\|tmux Agent Interface]] |

**Total estimated time:** 12-16 hours  
**Prerequisites:** [[commands|Linux terminal]], [[proxmox-ssh-infrastructure|SSH]], Vim basics (optional)

### Labs

| # | Lab | Links to |
|---|-----|----------|
| 01 | Create and manage sessions | Lessons 01-02 |
| 02 | Detach and reconnect | Lesson 02 |
| 03 | Split and arrange panes | Lesson 04 |
| 04 | Remote server workflow with tmux | Lessons 09, [[proxmox-ssh-infrastructure\|SSH]] |
| 05 | Persistent AI dev workspace | Lessons 06, 10, [[llama-loader/INDEX\|llama-loader]] |

### Projects (capstone)

- Build a homelab monitoring workspace (panes + sessions + remote) — see [[tmux-agent-interface]]
- Persistent [[quartz-wiki-architecture\|Quartz]] development workspace
- AI model serving workspace ([[llama-server|llama-server]] + [[forge-neo|SD Forge]] on separate panes)
- Remote maintenance workflow — see [[proxmox-ssh-infrastructure]]

## Agent Script

A CLI tool to bootstrap new topics:

```bash
learn-topic <topic> [--generate-lesson N]
```

Phase 1 generates the roadmap into `Learning/<topic>/Inbox/`. Phase 2 takes a lesson number and produces the draft. Designed to be run with the local LLM (llama-server on port 8080).

### Usage

```bash
# Phase 1: Plan the topic
learn-topic tmux

# Phase 2: Generate lesson 3
learn-topic tmux --lesson 3

# Phase 2: Regenerate lesson 3 into inbox
learn-topic tmux --lesson 3 --force
```

## Timeline

The `history:` frontmatter field lists immutable entry IDs. Dataview renders these as a table:

```dataview
TABLE without id
  split(entry, "  ")[0] as "Entry",
  split(entry, "  ")[1] as "Description"
FROM "projects/learning-pipeline"
FLATTEN history as entry
SORT entry ASC
```

To auto-collect history from linked work entries instead (no manual maintenance):

```dataview
TABLE
  id as "Entry",
  date as "Date",
  status as "Status"
FROM "journal/entries"
WHERE contains(projects, [[learning-pipeline]])
SORT id ASC
```

## Integration

| System | How |
|--------|-----|
| Journal | Daily entries link to lessons/labs via [[wikilinks]] |
| Backlinks | `vault-journal-backlink.sh` adds cross-refs from journal to lessons |
| Citation | AI-drafted inbound lessons get `source: ai-draft  # TODO: verify` |
| Dataview | Roadmap frontmatter tracks completion; history field renders timeline |
| Quartz | Learning topics are published alongside the rest of the vault |

## Status

| Phase | Tool | Status |
|-------|------|--------|
| 1 — Planner | `learn-topic` | Planned |
| 2 — Researcher | `learn-topic --lesson` | Planned |
| 3 — Inbox | Directory structure | TBD |
| 4 — Review | Manual | TBD |
| 5 — Knowledge | `vault-journal-backlink.sh` | Script written |
| 6 — Lab Generator | `learn-topic --lab` | Planned |
| 7 — Journal | Manual + backlink script | Active |

## Future Topics

Once the tmux pilot is complete, the pipeline applies to any topic:

- Docker / Podman
- Kubernetes (K3s)
- Networking (VLAN, bridging, OPNsense)
- Python (async, testing, packaging)
- Playwright / browser automation
- AI engineering (fine-tuning, prompting, RAG)
- Proxmox / LXC management
- ZFS / storage
