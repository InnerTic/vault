# Tmux — Research Notes

**Tmux** (Terminal Multiplexer) runs a background daemon that manages terminals, sessions, windows, and panes. It lets you detach/reattach terminals, preserve long-running jobs, and script your workflow — including feeding pane output to local LLMs and using tmux as an agent control surface.

> tmux 3.7 is the latest release (June 2026). Key new features: floating panes, `pane_pipe_pid`, `remain-on-exit`, line numbers in copy mode, bracket-paste detection, OSC 9;4 progress bar, and control mode format subscriptions.

---

## Core Concepts

| Term | Description |
|------|-------------|
| **Server** | Background daemon managing all state. Started automatically on first tmux command. |
| **Session** | A named group of windows (e.g., `dev`, `server`). Survives client disconnects. |
| **Window** | A full-screen view within a session, split into panes. |
| **Pane** | A single terminal area within a window. Each pane runs a process. |
| **Client** | The terminal emulator connected to the server. |
| **Prefix** | Key combo to trigger tmux commands (default: `Ctrl+b`). |

### Unique Identifiers

tmux assigns stable IDs to every entity. Use these in scripts — they never change:
- Session: `$0`, `$1` …
- Window: `@0`, `@1` …
- Pane: `%0`, `%1` …

---

## tmux 3.7 — New Features

### Floating Panes (`new-pane` / `Ctrl+b +`)
Floating panes overlay the tiled layout like popups, but are non-modal and support escape sequences. Created with `new-pane` (bound to `Ctrl+b +` by default). Can be moved and resized with the mouse. The second status line shows all panes when `status-format` is set to `2`.

### `remain-on-exit`
When enabled, panes aren't auto-killed when the process exits. Instead they become "dead panes" and a message appears. Use `respawn-pane` or `respawn-window` to restart them. Great for AI agent panes where you want to inspect output after the agent finishes.

```tmux
set -g remain-on-exit on
```

### Line Numbers in Copy Mode (`copy-mode-line-numbers`)
New option allowing absolute, relative, or hybrid line numbering in copy mode. Also supports custom line-number styling.

```tmux
set -g copy-mode-line-numbers absolute   # or: relative, hybrid, off
```

### `pane_pipe_pid` Format
New format variable exposing the pipe file descriptor for `pipe-pane`. Useful for debugging pane piping in scripts.

### Bracket-Paste Detection
tmux now uses the bracket-paste terminal escape sequence (`\\033[200~` / `\\033[201~`) instead of heuristic guessing, fixing paste issues with Windows Terminal, Terminal.app, and others.

### OSC 9;4 Progress Bar
tmux now handles the `\\033]9;4;...\\033\\` OSC sequence used by terminals like iTerm2 and Windows Terminal to draw inline progress bars. The value is available as `#{pane_progress}`.

### `pipe-pane -I` with Shell Command
You can now pipe output into a pane via `pipe-pane -I 'echo foo'`, useful for injecting content without `send-keys`.

---

## Control Mode — AI Agent Integration

Control mode is a text-only protocol between tmux and an external program (like a terminal UI or AI agent). It was designed for iTerm2's integration with tmux, but is the most powerful interface for programmatic control.

### Starting Control Mode
```bash
tmux -C new-session -s mysession    # -C: control mode
tmux -CC new-session -s mysession   # -CC: disable canonical mode (for apps)
```

### The Protocol
Every tmux command is wrapped in `%begin` / `%end` (success) or `%begin` / `%error` (failure), each with timestamp, command number, and flags. Output from panes arrives as `%output %pane_id content`.

### Notifications
Control mode clients receive notifications on changes:
- `%window-add @id` — new window
- `%window-close @id` — window closed
- `%session-changed $id name` — session changed
- `%sessions-changed` — any session created/destroyed
- `%pane-mode-changed %id` — copy mode toggled
- `%output %id text` — pane output (when attached)

### Format Subscriptions
You can subscribe to any format and get a `%subscription-changed` notification whenever its value changes (at most once/second). This is ideal for monitoring GPU usage, model health, or build progress from an AI agent.

```
refresh-client -B gpu_monitor:%* '#{pane_width}x#{pane_height}'
# → %subscription-changed gpu_monitor %0 80x24
```

### Flow Control
Enable with `refresh-client -f pause-after=30`. When a pane falls behind, tmux sends `%pause` and stops streaming output. Resume with `refresh-client -A '%0:continue'`.

---

## Scripting tmux

### Targets
Most commands accept `-t target`. The format is `session:window.pane`. Any part may be omitted:
```bash
tmux send-keys -t=mysession:0.1 'python server.py' Enter    # specific pane
tmux capture-pane -t%0 -p                                     # specific pane by ID
tmux neww -dPF '#{pane_id}' -t=mysession:0                    # new pane, print ID
```

Special target tokens:
- `{last}` — last window/pane
- `{next}` / `{previous}` — relative navigation
- `{top}` / `{bottom}` / `{left}` / `{right}` — spatial

### Key Scripting Commands
```bash
# Create layout programmatically
tmux new-session -d -s agent -x200 -y50
tmux split-window -t agent:0 -v
tmux split-window -t agent:0 -v

# Send text to pane
tmux send-keys -t agent:0.0 'cd ~/projects && python agent.py' Enter

# Capture pane output (entire history)
tmux capture-pane -t agent:0 -S- -E- -p

# Check if session exists (idempotent startup)
tmux has-session -t mysession 2>/dev/null || tmux new -s mysession

# Loop over all panes
tmux list-panes -a -F '#{pane_id}' | while read pid; do
    echo "Pane $pid: $(tmux capture-pane -t$pid -p | tail -5)"
done
```

### Respawn Panes
When `remain-on-exit` is on, use `respawn-pane` or `respawn-window` to restart:
```bash
:respawn-pane -k top    # kill existing, start new command
:respawn-pane            # restart original command
```

### Piping Pane Output
```bash
# Pipe all future pane output to a file
:pipe-pane 'cat >~/panelog'

# Stop piping
:pipe-pane

# One-shot toggle binding
bind P pipe-pane -o 'cat >~/panelog'
```

---

## tmux + AI Agent Workflows

### 1. The Context-Extraction Loop

Use `capture-pane` to grab terminal history and feed it to a local LLM:
```bash
# Grab last 50 lines of the agent pane
tmux capture-pane -t agent:0.1 -S-50 > context.txt

# Pipe to ollama for analysis
tmux capture-pane -t agent:0.1 -S-50 | ollama run llama3.2 "Analyze this output and suggest fixes:"

# Or use a Python script for structured parsing
tmux capture-pane -t agent:0.1 -p -S- | python3 parse_agent_output.py
```

### 2. The Observer-Worker Split

Two-pane setup: one for the AI worker, one for the human or monitoring agent:
```bash
tmux new-session -d -s ai-dev
tmux split-window -v -t ai-dev:0
tmux send-keys -t ai-dev:0.0 'python3 agent.py' Enter          # Worker
tmux send-keys -t ai-dev:0.1 'tail -f logs/agent.log' Enter    # Observer
tmux select-pane -t ai-dev:0.0
tmux attach -t ai-dev
```

### 3. Control Mode for Automated Agents

A full control-mode client can drive tmux without any user interaction:
```bash
# Start a control-mode session
tmux -CC new-session -d -s agent

# Create panes
tmux -CC new-session -t agent neww -n model
tmux -CC new-session -t agent neww -n shell

# Send commands to specific panes
echo -e "send-keys -t %0 'python server.py' Enter\nsend-keys -t %1 'npm run dev' Enter" \
    | tmux -Ldefault -C attach-session

# Monitor via format subscriptions
echo -e "refresh-client -B gpu:%* '#{pane_width}x#{pane_height}'" \
    | tmux -Ldefault -C attach-session
```

### 4. Real-World tmux AI Projects

| Project | Stars | Description |
|---------|-------|-------------|
| [mux](https://github.com/tony/mux) | 71⭐ | TUI tmux session manager, built for AI coding workflows |
| [agent-conductor](https://github.com/agent-conductor) | 11⭐ | CLI toolkit for spinning up, coordinating, and supervising multi-terminal AI agents |
| [tmux-worktree](https://github.com/tmux-worktree) | 25⭐ | Native tmux for parallel workflows, git worktree isolation |
| [swarm](https://github.com/swarm) | 7⭐ | Process manager for AI agent CLIs — spawns, tracks, controls multiple agents via tmux |
| [orion](https://github.com/orion) | 9⭐ | AI coding workflows: concurrent nodes per Git branch, independent tmux sessions |
| [grab](https://github.com/grab) | 17⭐ | Deterministic workflows for AI-assisted debugging (cuts repo investigation time by 70%) |
| [tmux-journal](https://github.com/tmux-journal) | 5⭐ | Automatic tmux session logger with AI-powered workflow summaries |
| [Helix-Zellij-or-Tmux-AI-REPL](https://github.com/Helix-Zellij-or-Tmux-AI-REPL) | 45⭐ | Workflow integration for AI Code Completion, AI CLIs, and REPLs |

### 5. tmuxp — Session-as-Code

tmuxp defines session layouts in YAML for reproducible AI workspaces:

```yaml
# ai-workstation.yaml
session_name: ai-workstation
start_directory: ~/projects/ai-project
windows:
  - window_name: model
    panes:
      - llama-server -m ~/models/llama-3.1-8b.Q4_K_M.gguf -c 8192
      - watch -n 5 nvidia-smi
  - window_name: agent
    panes:
      - python3 agent.py
      - tail -f logs/agent.log
  - window_name: monitor
    panes:
      - htop
  - window_name: terminal
    panes:
      - zsh
      - neovim
```

```bash
tmuxp load ai-workstation
```

### 6. The "Tailing-to-Agent" Pattern

Pipe a pane's output directly to an LLM for real-time analysis:
```bash
# In a monitor pane:
watch -n 2 'tmux capture-pane -t agent:0.1 -S-100 -p | ollama run llama3.2 "What issues do you see?"'

# Or use tmux pipe-pane for continuous logging:
:pipe-pane -I 'cat | tee ~/logs/agent.log | ollama run llama3.2 --stream'
```

---

## tmux.conf — Reference Configuration

Optimized for modern terminals, tmux 3.7+, and AI agent workflows.

```tmux
# === General ===
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",xterm*:Tc"        # TrueColor
set -g base-index 1
set -g pane-base-index 1
set -g renumber-windows on
set -g mouse on
set -g history-limit 50000                      # Large scrollback
set -g escape-time 0
set -g remain-on-exit on                        # AI agent panes stay visible after exit

# === Working Directories ===
# New panes/windows inherit parent pane's working directory
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -hc "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# === Key Bindings ===
# Config reload
bind r source-file ~/.tmux.conf \; display "Config reloaded"

# Vim-style pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Resizable with Ctrl
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Session management
bind-key -T prefix W confirm-before -p "Kill session #S? (y/n)" kill-session

# Copy mode (vi style)
setw -g mode-keys vi
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi C-v send -X rectangle-toggle
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -selection clipboard"

# Copy mode line numbers (tmux 3.7+)
set -g copy-mode-line-numbers relative

# === Status Bar ===
set -g status-interval 5
set -g status-justify centre
set -g status-left-length 40
set -g status-right-length 120
set -g status-left "#[fg=green,bold]#S #[fg=white]• #[fg=cyan]#(whoami)@#h"
set -g status-right "#[fg=yellow]%Y-%m-%d %H:%M "
set -g status-style "fg=white,bg=#1a1a2e"
set -g window-status-current-style "fg=black,bg=cyan"
set -g window-status-style "fg=white,dim"
set -g pane-border-style "fg=#444"
set -g pane-active-border-style "fg=cyan"
set -g message-style "fg=black,bg=yellow"

# === Alert Monitoring (for AI agent status) ===
set -g monitor-activity on
set -g visual-activity off
set -g monitor-bell on
set -g visual-bell off
set -g monitor-silence 300   # Alert if agent hasn't produced output in 5 min
set -g visual-silence on

# === Clipboard ===
set -g set-clipboard on

# === Plugin Management (TPM) ===
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-save-interval '15'
set -g @continuum-restore 'on'
set -g @plugin 'tmux-plugins/tmux-yank'
run '~/.tmux/plugins/tpm/tpm'
```

---

## Configuration Recipes (from tmux wiki)

### Prevent Pane Navigation Wrapping
```tmux
bind -r Up if -F '#{pane_at_top}' '' 'selectp -U'
bind -r Down if -F '#{pane_at_bottom}' '' 'selectp -D'
bind -r Left if -F '#{pane_at_left}' '' 'selectp -L'
bind -r Right if -F '#{pane_at_right}' '' 'selectp -R'
```

### Create a New Pane to Copy (tmux 3.2+)
Open the active pane's history in a new temporary pane for easy copying:
```tmux
bind C {
    splitw -f -l30% ''
    set-hook -p pane-mode-changed 'if -F "!#{==:#{pane_mode},copy-mode}" "kill-pane"'
    copy-mode -s'{last}'
}
```

### Menu Button on Pane Border (tmux 3.7+)
Add a right-click menu on the pane border:
```tmux
set -g pane-border-status top
set -g pane-border-format "
#{?pane_active,#[reverse],}#{pane_index} #{pane_title}
#{?#{mouse},#[align=right] #[range=control|9][Menu]#[norange],}"

bind -n MouseDown1Control9 "
    display-menu -t= -xM -yM -O -T 'Pane: #{pane_index}' \\
    '#{?pane_marked,Unmark,Mark}' 'm' { select-pane -m } \\
    '#{?window_zoomed_flag,Unzoom,Zoom}' 'z' { resize-pane -Z } \\
    'Horizontal Split' 'h' { split-window -h } \\
    'Vertical Split' 'v' { split-window -v } \\
    '' \\
    'Kill' 'X' { kill-pane -t= }"
```

---

## Quick Reference

### Key Bindings (prefix = Ctrl+b)

| Binding | Action |
|---------|--------|
| `d` | Detach |
| `n` / `p` | Next / previous window |
| `<number>` | Jump to window |
| `%` | Split horizontal |
| `"` | Split vertical |
| `z` | Toggle pane fullscreen |
| `x` | Kill pane (confirm) |
| `w` | Window list (tree picker) |
| `s` | Session list (tree picker) |
| `q` | Show pane numbers |
| `o` | Swap panes |
| `!` | Break pane into new window |
| `Ctrl+b +` | Create floating pane (3.7+) |
| `:command` | Command prompt (e.g., `:respawn-pane`) |

### Common Commands

```bash
tmux new -s name              # Create named session
tmux attach -t name           # Reattach to session
tmux ls                       # List sessions
tmux kill-session -t name     # Kill session

tmux split-window -h          # Horizontal split
tmux split-window -v          # Vertical split

tmux send-keys -t target 'cmd' Enter   # Type into pane
tmux capture-pane -t target -p         # Read pane output
tmux capture-pane -t target -S- -p     # Read entire history

tmux respawn-pane -k 'command'         # Restart pane with new command
tmux pipe-pane -o 'cat >logfile'       # Start piping pane output

tmux new-pane -t session:window        # Create floating pane (3.7+)
```

### Formats for Scripting

```bash
#{session_name}     # Session name
#{session_id}       # Session ID ($N)
#{window_name}      # Window name
#{window_id}        # Window ID (@N)
#{pane_id}          # Pane ID (%N)
#{pane_width}       # Pane width in columns
#{pane_height}      # Pane height in rows
#{pane_current_path} # Current working directory
#{pane_title}       # Pane title
#{host}             # Hostname
#{user}             # Username
#{pane_progress}    # Progress bar value (OSC 9;4, tmux 3.7+)
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "tmux: can't find socket" | Start server: `tmux` |
| "duplicate session" | Use `tmux attach -t name` |
| Scroll doesn't work | Press prefix then arrow keys (or use mouse mode) |
| Config changes not applying | `prefix+r` to reload |
| Paste inserts `^[` | Set `default-terminal "screen-256color"` |
| Can't copy to system clipboard | Install `xclip`/`xsel`, ensure `set-clipboard on` |
| tmux exits when SSH disconnects | Use `tmux attach`, enable resurrect |
| Pane borders invisible | Check terminal supports true color |
| Control mode hangs on exit | Use `-CC` (not `-C`) for application control |
| Agent pane output not reaching control client | Check `#{pane_in_mode}` — copy mode suppresses output |

---

*Updated: 2026-06-22*
*Target: tmux 3.5+ (recommended: 3.7+ for full feature set)*
