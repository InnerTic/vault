---
title: "Tmux Evolution"
tags:
  - projects
modified: 2026-06-26
---

# tmux Notes — File Evolution

This documents how six tmux note files were created, each building on the prior. The progression went from bare research notes → structured walkthroughs → consolidated reference.

---

## Timeline

| # | File | Lines | Date (implied) | Purpose |
|---|------|-------|----------------|---------|
| 1 | `tmux-research.md` | 427 | v1 | Initial research dump |
| 2 | `tmux-research-v2.md` | 465 | +38 lines | Add ecosystem, config recipes |
| 3 | `tmux-research-v3.md` | 534 | +69 lines | Expand AI patterns, add `get-clipboard` |
| 4 | `tmux-research-v3-ref.md` | 192 | spinoff | Reference-only config + troubleshooting |
| 5 | `tmux-guide-v4.md` | 714 | major rewrite | Walkthrough-first structure, numbered sections |
| 6 | `tmux-walkthroughs.md` | 523 | companion | Dedicated walkthroughs with code |
| 7 | `tmux-unified.md` | ~430 | final | Consolidated, all versions merged |

---

## File 1: tmux-research.md (v1) — 427 lines

The starting point. A raw research dump organized into sections.

**Sections:**
- Core Concepts (server, session, window, pane, client, prefix)
- tmux 3.6+ Features (floating panes, remain-on-exit, copy mode line numbers, bracket-paste, OSC 9;4, #() format expansion)
- Control Mode (starting, protocol, notifications, format subscriptions, flow control)
- Scripting tmux (targets, key commands, piping)
- tmux + AI Agent Workflows (context extraction, observer-worker, control mode, real-time tailing, tmuxp)
- .tmux.conf — Reference Configuration
- Quick Reference (key bindings, common commands, formats, control mode protocol)
- Troubleshooting

**What it had:** Everything foundational. The base. No walkthroughs, no ecosystem table, no version-conditional config, no `get-clipboard`, no advanced config recipes.

---

## File 2: tmux-research-v2.md — +38 lines (465 total)

Built on v1. Added new content but kept the same structure.

**Additions:**
- Ecosystem tools table (mux, agent-conductor, tmux-worktree, swarm, orion, grab, tmux-journal, Helix-Zellij-or-Tmux-AI-REPL)
- "Tailing-to-Agent" pattern (separate section for piping pane output to LLM)
- Configuration recipe: Prevent pane navigation wrapping
- Configuration recipe: Create a new pane to copy (3.2+)
- Configuration recipe: Menu button on pane border (3.7+)
- Updated CHANGES to reflect 3.7 features more completely

**What changed:** Added ecosystem awareness and practical config recipes. The AI section grew from 3 patterns to 5, with a dedicated "Tailing-to-Agent" section.

---

## File 3: tmux-research-v3.md — +69 lines (534 total)

Built on v2. Added more features from the 3.7-rc CHANGES, expanded config reference, and filled in gaps.

**Additions:**
- `get-clipboard` format and config
- `pane_pipe_pid` format variable
- `focus-follows-mouse`, `selection_mode`, `tiled-layout-max-columns`
- `#()` format expansion with `run-shell -N` arguments
- `display-message -C`, `capture-pane -M`
- `window-size` values, `DECSET 2026`, `default-client-command`
- `scroll-on-clear`, `fill-character`
- More troubleshooting entries (paste timeout, no sessions, freeze on attach, no colour, escape delay, server crash, modified keys)
- Full `.tmux.conf` reference config with status bar, TPM plugins, alert monitoring
- Format modifiers table (`t:`, `b:`, `d:`, `=`, `p`, `s/`, `q:`, `e|op|`, ternary, `W:`, `P:`)
- Empty panes (`tmux splitw -I`), piping flags table
- Control mode notifications expanded
- Quick reference: Control Mode Protocol section

**What changed:** The reference config went from a bare skeleton to a full production-ready `.tmux.conf`. Troubleshooting grew from 10 entries to 18. The features section absorbed the remaining 3.7-rc additions.

---

## File 4: tmux-research-v3-ref.md — 192 lines

A spinoff of v3. Extracted just the config and reference material into a compact reference document.

**Sections:**
- .tmux.conf — Reference Configuration (full config, ~100 lines)
- Quick Reference (prefix commands, common commands, control mode protocol, troubleshooting)

**What it was:** A cut-down reference meant to be used as a quick lookup. Dropped the research sections entirely. Kept the full `.tmux.conf`, all troubleshooting entries, control mode protocol summary, and basic command reference.

---

## File 5: tmux-guide-v4.md — 714 lines

A major rewrite. Shifted from "research notes" to "walkthrough-first guide." Everything is numbered and structured as a progressive guide.

**Sections:**
1. Core Concepts
2. Quick Start Walkthroughs (4 walkthroughs: session lifecycle, multi-pane dev workspace, copy-paste with vi keys, quick pane navigation)
3. Key Bindings Reference (default bindings + essential custom bindings)
4. Control Mode — Programmatic tmux (starting, protocol, notifications, example script, format subscriptions, flow control)
5. tmux 3.5-3.7 Features (all features with version tags)
6. Scripting tmux (targets, idempotent startup, special targets, capture-pane flags, empty panes, piping)
7. Format Variables (key variables, useful modifiers)
8. tmux + Local AI Integration (6 patterns: context extraction, observer-worker, real-time tailing, multi-agent, control mode client, live capture + LLM review)
9. Ecosystem Tools (9 tools with descriptions)
10. .tmux.conf — Reference Configuration (full config)
11. Configuration File Recipes (portable config, checking config)
12. Troubleshooting

**What changed:**
- Walkthrough-first structure instead of reference-first
- Numbered sections for easy navigation
- Control mode got a worked example script
- AI patterns expanded to 6 patterns (added Python control mode client, live capture with md5diff)
- Ecosystem table included descriptions, not just names
- Added portable config (`-q` flag, `%if` version conditionals)
- Added configuration checking (`tmux source -n`, `source -v`, `-f/dev/null`)

---

## File 6: tmux-walkthroughs.md — 523 lines

A companion to v4. Dedicated walkthrough section with runnable examples.

**Sections:**
1. Setting Up AI Dev Workspace (llama-server + GPU monitor + logs in one session)
2. Control Mode — Automated LLM Output Capture (Python script monitoring pane changes)
3. tmuxp — Session-as-Code for AI Workflows (full YAML definition)
4. Remote tmux — SSH Workflow (remote server setup, SSH attach, systemd persistence)
5. Multi-Agent Coordination with tmux (isolated servers, layouts, cross-agent communication, monitoring)
6. tmux + Armada — Fleet Management (install, usage, dashboard)
7. tmux Control Mode — Python Client (full TmuxControlClient class)
8. Monitoring Agent Output with tmux (monitor-silence, custom bash monitor)
9. tmux + Ollama Integration (one-shot analysis, continuous monitoring)

**What it was:** Practical, runnable walkthroughs focused on AI/developer setups. Each had a goal, setup code, usage instructions. The Python client class was the most complete standalone code block.

---

## File 7: tmux-unified.md — Final

Merged all six into one document. Removed duplicates, filled gaps, verified against tmux 3.7-rc CHANGES.

**Sections:**
1. Core Concepts
2. Quick-Start Walkthroughs (A-D)
3. Key Bindings Reference
4. Control Mode — Programmatic tmux
5. Scripting tmux
6. Format Variables
7. tmux 3.5–3.7 Features (all features with version tags)
8. tmux + Local AI Integration (patterns A-H)
9. tmuxp — Session-as-Code
10. .tmux.conf — Reference Configuration
11. Ecosystem Tools
12. Troubleshooting

**What was consolidated:**
- v1's foundational research
- v2's ecosystem table and config recipes
- v3's expanded features, `get-clipboard`, troubleshooting depth
- v3-ref's full config reference and troubleshooting
- v4's walkthrough-first structure and portable config
- v6's runnable AI walkthroughs (merged into pattern A-H)
