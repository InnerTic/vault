---
title: "Tmux Agent Interface"
tags:
  - projects
modified: 2026-06-26
---

# tmux + Local Models — Collaborative Agent Interface

**Status:** Proposed
**Date:** 2026-06-21

## Concept

Use tmux as the primary interface for working with local models. The model gets a tmux pane where it executes commands. The user watches in another pane, follows along, and intervenes/corrects before anything screws up.

```
┌─────────────────────────────┬──────────────────────────────┐
│  User pane                  │  Model pane                  │
│  (watch, follow, interject) │  (llama-server / opencode    │
│                             │   executing commands)        │
│  "no wait, use --dry-run"   │  $ rm -rf /etc              │
│  "Ctrl+C that"              │  (paused, waiting)           │
│  "try --flag instead"       │  $ corrected-command        │
└─────────────────────────────┴──────────────────────────────┘
```

## Why

- **Watch mode** — see exactly what the model is doing, in real time
- **Intervention** — Ctrl+C, type corrections, redirect before damage
- **Teaching** — show the model the right way, it learns from your corrections
- **No autonomy risk** — model never runs unsupervised
- **Session persistence** — tmux survives detach, model keeps working
- **Scriptable** — tmux commands can be sent programmatically

## How It Works

1. Open tmux session with split panes
2. Left pane: user's shell (watching)
3. Right pane: model's execution environment
4. User describes the task verbally (in chat), model executes in its pane
5. If model starts going wrong: user Ctrl+C, corrects, model continues
6. Full audit trail in tmux scrollback buffer

## Implementation Ideas

- `tmux new -s agent-session` — create session
- Send commands to model pane via `tmux send-keys -t agent-session:0.1`
- Capture output via `tmux capture-pane -t agent-session:0.1`
- Script wrapper that opens tmux layout, launches model, pipes commands
- Could wrap opencode's tool calls to execute in tmux pane instead of directly

## Existing Assets

- Bootstrap module: `vault/dotfiles/scripts/bootstrap/modules/50-tmux.sh` — links `tmux/.tmux.conf` → `~/.tmux.conf`
- `opentmux` plugin listed in `vault/docs/vault/software/opencode/plugins.md`
- Multiple vault docs reference tmux (commands.md, dev-setup.md, cachyos-package-list.md)

**Current state:** tmux not installed. No `~/.tmux.conf`. No `vault/dotfiles/tmux/` directory. Config was lost in workspace reorg.

## Next Steps

1. Install tmux
2. Recreate `vault/dotfiles/tmux/.tmux.conf` (mouse support, status bar, keybindings, pane splitting)
3. Set up the split-pane workflow with llama-server/opencode in model pane
4. Script a `tmux-agent` launcher that opens the layout automatically

## Directory

`vault/projects/tmux-agent-interface/`
