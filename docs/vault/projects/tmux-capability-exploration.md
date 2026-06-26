---
title: "Tmux Capability Exploration"
tags:
  - projects
---

# tmux — Full Capability Exploration

**Status:** Exploring
**Date:** 2026-06-21

## Current State

- tmux **not installed**
- No `~/.tmux.conf`
- No `vault/dotfiles/tmux/` directory
- Bootstrap module `50-tmux.sh` exists but references config that doesn't exist
- `opentmux` plugin listed in opencode plugins

## What tmux Can Do for You

### 1. Agent Interface (already scoped)

Split pane: watch model execute in one pane, intervene from the other. Full audit in scrollback.

### 2. Service Dashboard

One tmux window per service, all running persistently:
```
Window 0: llama-server (model logs streaming)
Window 1: Forge Neo (SD output)
Window 2: TextGen WebUI (server logs)
Window 3: shell (general use)
```
Detach/reattach — services keep running. No more lost terminals.

### 3. Session Persistence

SSH into Akuma, reattach to the same session you left yesterday. Work survives disconnects, reboots (with tmux-resurrect), laptop closures.

### 4. Scripted Layouts (tmuxinator / tmuxp)

One command spawns your entire dev environment:
```bash
tmuxp load ai-workstation
# Opens: 3 panes — model output | shell | watch dashboard
```

### 5. Broadcast Mode

Send the same command to all panes at once — useful for multi-container management.

### 6. Logging

Every pane can write its scrollback to a file automatically — full audit trail of everything a model did.

### 7. Copy Mode & Search

Scroll back through hours of output, search for errors, select/copy with keyboard.

### 8. Tmux-Resurrect & Tmux-Continuum

Save/restore entire tmux state across reboots. Reboot, one command, your full workspace is back.

### 9. Pair with Local Models

Model gets its own pane. You sit in another. Describe what you want, watch it work, grab the wheel when it starts veering. You're driving, it's typing.

### 10. Floating Windows (tmux 3.2+)

Pop up a temporary terminal over your current layout — run a quick command, check a log, dismiss it.

## What Needs Building

| Asset | Current |
|-------|---------|
| `vault/dotfiles/tmux/.tmux.conf` | Missing — needs recreation |
| tmux installation | `apt install tmux` |
| Bootstrap module | `50-tmux.sh` exists but won't activate (no config) |
| Service dashboard layout script | New |
| Agent split-pane layout script | New |
| Tmux-resurrect setup | New |

## Open Questions

- Prefix key: Ctrl+b (default) or Ctrl+a (screen muscle memory)?
- Mouse mode: on or off?
- Status bar: what info (hostname, session name, time, GPU temp via script)?
- 256 color / true color support?
- Clipboard sync with system clipboard?
