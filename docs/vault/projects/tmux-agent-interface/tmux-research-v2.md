---
title: "Tmux Research V2"
tags:
  - projects
modified: 2026-06-26
  - tmux-agent-interface
  - tmux-research-v2
---

# Tmux — Research Notes

**tmux** (Terminal Multiplexer) runs a background server that manages sessions, windows, and panes. Detach/reattach terminals, preserve long-running jobs, and feed pane output to local LLMs — all programmable via control mode.

> Latest stable: tmux 3.6b (May 2026). Release candidate 3.7-rc is available. Target this document: 3.5+.

---

## Core Concepts

| Term | Description |
|------|-------------|
| **Server** | Background daemon managing all state. Auto-starts on first tmux command. |
| **Session** | Named group of windows (e.g. `dev`, `server`). Survives client disconnects. |
| **Window** | Full-screen view within a session, split into panes. |
| **Pane** | Single terminal area within a window. Runs one process. |
| **Client** | Terminal emulator connected to the server. |
| **Prefix** | Key combo to trigger tmux commands (default: `Ctrl+b`). |

### Unique Identifiers

Stable IDs never change — use in scripts:
- Session: `$N` (e.g. `$0`)
- Window: `@N` (e.g. `@0`)
- Pane: `%N` (e.g. `%0`)

---

## tmux 3.6+ Features

### Floating Panes (3.7-rc)

Floating panes sit above the tiled layout like popups but are non-modal — they behave like real panes with full escape sequence support.

```tmux
# Create floating pane (bound to * by default in 3.7-rc)
bind * new-pane

# Move/resize with mouse; second status line lists all panes when:
set -g status-format 2
```

### `remain-on-exit` Key (3.7-rc)

Keeps the pane alive after exit until a key is pressed (new value: `key`). Previously only `on` (always keep) and `fail` (keep on non-zero exit) existed.

```tmux
set -g remain-on-exit key    # pane stays visible until you press a key
```

### Line Numbers in Copy Mode (3.7-rc)

```tmux
set -g copy-mode-line-numbers absolute   # history line 1 = 1
# Options: off, default, absolute, relative, hybrid
# hybrid = current line absolute, others relative
```

### Bracket-Paste Detection (3.7-rc)

tmux now uses bracket-paste escape sequences (`ESC[200~` / `ESC[201~`) instead of heuristic guessing. Fixes paste issues with Windows Terminal, Terminal.app, and others.

### OSC 9;4 Progress Bar (3.7-rc)

tmux now handles the `ESC]9;4;...ESC\` OSC sequence (iTerm2 / Windows Terminal inline progress). Available as `#{pane_progress}` format.

### `#()` Format Expansion (3.7-rc)

Run-shell arguments after the shell command expand as `#{1}`, `#{2}`, etc.:
```tmux
run-shell -N 'echo #{1} #{2}' foo bar  # #{1} = "foo", #{2} = "bar"
```

---

## Control Mode — AI Agent Integration

Control mode is a text-only protocol between tmux and external programs (terminals, scripts, AI agents). Designed for iTerm2 integration but the most powerful interface for programmatic control.

### Starting Control Mode

```bash
tmux -C new-session -s mysession    # single -C: canonical mode (for testing)
tmux -CC new-session -s mysession   # double -CC: no canonical mode (for apps)
```

The `-CC` flag sends a DSC sequence that listening terminals can detect. An empty line (Enter) detaches the client.

### The Protocol

Commands produce wrapped responses:
```
%begin <timestamp> <command_num> <flags>
%end <timestamp> <command_num> <flags>
```

Output from panes arrives as:
```
%output %pane_id content
```

### Notifications

Control mode clients receive on changes:
- `%window-add @id` / `%window-close @id`
- `%session-changed $id name` / `%sessions-changed`
- `%pane-mode-changed %id`
- `%output %id text`
- `%client-active` / `%client-detached`

### Format Subscriptions (3.5+)

Subscribe to any format and get notified on change (once/second max). Ideal for monitoring GPU usage, model health, or build progress:

```bash
echo -e "refresh-client -B gpu:%* '#{pane_width}x#{pane_height}'" \
    | tmux -Ldefault -C attach-session
# → %subscription-changed gpu %0 80x24
```

### Flow Control (3.2+)

Pause a pane when output buffers too far behind:
```bash
refresh-client -f pause-after=30   # pause after 30s of backlog
refresh-client -A '%0:continue'    # resume pane %0
```

---

## Scripting tmux

### Targets

Format: `session:window.pane`. Any part omitted uses defaults.

```bash
tmux send-keys -t=mysession:0.1 'python server.py' Enter
tmux capture-pane -t%0 -p                          # by ID
tmux neww -dPF '#{pane_id}' -t=mysession:0        # print pane ID on creation
```

Special targets: `{last}`, `{next}`, `{previous}`, `{top}`, `{bottom}`, `{left}`, `{right}`.

### Key Scripting Commands

```bash
# Idempotent session startup
tmux has-session -t mysession 2>/dev/null \
  || tmux new-session -d -s mysession -x200 -y50

# Create layout
tmux new-session -d -s agent -x200 -y50
tmux split-window -t agent:0 -v
tmux split-window -t agent:0 -v

# Send text
tmux send-keys -t agent:0.0 'cd ~/projects && python agent.py' Enter

# Capture pane history
tmux capture-pane -t agent:0 -S- -E- -p

# Loop over all panes
tmux list-panes -a -F '#{pane_id}' | while read pid; do
    echo "Pane $pid: $(tmux capture-pane -t$pid -p | tail -5)"
done
```

### Piping Pane Output

```bash
:pipe-pane 'cat >~/panelog'     # start piping
:pipe-pane                      # stop piping
bind P pipe-pane -o 'cat >~/panelog'   # toggle binding
```

---

## tmux + AI Agent Workflows

### 1. Context Extraction Loop

Grab terminal history and feed to a local LLM:

```bash
# Capture last N lines
tmux capture-pane -t agent:0.1 -S-50 > context.txt

# Pipe directly to ollama
tmux capture-pane -t agent:0.1 -S-50 -p \
  | ollama run llama3.2 "Analyze this output and suggest fixes:"

# Structured parsing via Python
tmux capture-pane -t agent:0.1 -p -S- \
  | python3 parse_agent_output.py
```

### 2. Observer-Worker Split

Two-pane setup: one for the AI worker, one for monitoring:

```bash
tmux new-session -d -s ai-dev
tmux split-window -v -t ai-dev:0
tmux send-keys -t ai-dev:0.0 'python3 agent.py' Enter          # Worker
tmux send-keys -t ai-dev:0.1 'tail -f logs/agent.log' Enter    # Observer
tmux select-pane -t ai-dev:0.0
tmux attach -t ai-dev
```

### 3. Control Mode for Automated Agents

A control-mode client drives tmux without user interaction:

```bash
# Start control-mode session
tmux -CC new-session -d -s agent

# Create windows
echo -e "new-window -n model\nnew-window -n shell" \
    | tmux -Ldefault -C attach-session

# Send commands to specific panes
echo -e "send-keys -t %0 'python server.py' Enter" \
    | tmux -Ldefault -C attach-session

# Monitor via format subscriptions
echo -e "refresh-client -B gpu:%* '#{pane_width}x#{pane_height}'" \
    | tmux -Ldefault -C attach-session
```

### 4. Real-Time Tailing-to-Agent Pattern

```bash
# Periodic capture for analysis
watch -n 2 'tmux capture-pane -t agent:0.1 -S-100 -p \
  | ollama run llama3.2 "What issues do you see?"'

# Continuous pipe to streaming LLM
:pipe-pane -I 'cat | tee ~/logs/agent.log | ollama run llama3.2 --stream'
```

### 5. tmuxp — Session-as-Code

Define reproducible AI workspaces in YAML:

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

---

## .tmux.conf — Reference Configuration

Optimized for modern terminals, tmux 3.5+, and AI agent workflows.

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
set -g remain-on-exit key                       # AI panes stay visible until key press
set -g scroll-on-clear on                       # Scroll into history on clear (3.3+)
set -g fill-character " "                       # Fill char for unused client areas (3.3+)

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

# Prevent wrapping
bind -r Up if -F '#{pane_at_top}' '' 'selectp -U'
bind -r Down if -F '#{pane_at_bottom}' '' 'selectp -D'
bind -r Left if -F '#{pane_at_left}' '' 'selectp -L'
bind -r Right if -F '#{pane_at_right}' '' 'selectp -R'

# Session management
bind-key -T prefix W confirm-before -p "Kill session #S? (y/n)" kill-session

# Copy mode (vi style)
setw -g mode-keys vi
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi C-v send -X rectangle-toggle
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -selection clipboard"

# Copy mode line numbers (3.7-rc)
set -g copy-mode-line-numbers relative

# Floating panes (3.7-rc)
bind * new-pane
```

---

## Quick Reference

### Prefix Commands (prefix = Ctrl+b)

| Binding | Action |
|---------|--------|
| `d` | Detach |
| `n` / `p` | Next / previous window |
| `<number>` | Jump to window |
| `%` | Split horizontal |
| `"` | Split vertical |
| `z` | Toggle pane fullscreen |
| `x` | Kill pane (confirm) |
| `w` | Window list |
| `s` | Session list |
| `q` | Show pane numbers |
| `o` | Swap panes |
| `!` | Break pane into new window |
| `*` | Floating pane (3.7-rc) |
| `:` | Command prompt |

### Common Commands

```bash
tmux new -s name              # Create named session
tmux attach -t name           # Reattach to session
tmux ls                       # List sessions
tmux kill-session -t name     # Kill session

tmux send-keys -t target 'cmd' Enter   # Type into pane
tmux capture-pane -t target -p         # Read pane output
tmux capture-pane -t target -S- -p     # Read entire history
tmux respawn-pane -k 'command'         # Restart with new command
```

### Format Variables

```
#{session_name}       # Session name
#{session_id}         # Session ID ($N)
#{window_name}        # Window name
#{window_id}          # Window ID (@N)
#{pane_id}            # Pane ID (%N)
#{pane_width}         # Pane width in columns
#{pane_height}        # Pane height in rows
#{pane_current_path}  # Current working directory
#{pane_title}         # Pane title
#{host}               # Hostname
#{user}               # Username
#{pane_progress}      # Progress bar value (OSC 9;4, 3.7-rc)
#{pane_pipe_pid}      # Pipe FD (3.7-rc)
#{bracket_paste_flag} # Bracket paste support (3.7-rc)
```

### Control Mode Protocol

```
%begin <timestamp> <cmd_num> <flags>   # Command start
%end <timestamp> <cmd_num> <flags>     # Command success
%error <timestamp> <cmd_num> <flags>   # Command failure
%output <pane_id> <text>               # Pane output
%window-add <window_id>                # Window created
%window-close <window_id>              # Window destroyed
%session-changed <session_id> <name>   # Session changed
%subscription-changed <name> <pane> <format>  # Format subscription update
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "tmux: can't find socket" | Start server: `tmux` |
| "duplicate session" | Use `tmux attach -t name` |
| Scroll doesn't work | Press prefix then arrow keys, or enable mouse |
| Config changes not applying | `prefix+r` to reload |
| Paste inserts `^[` | Set `default-terminal "screen-256color"` |
| Can't copy to clipboard | Install `xclip`/`xsel`, ensure `set-clipboard on` |
| tmux exits on SSH disconnect | Use `tmux attach`, enable resurrect |
| Pane borders invisible | Check terminal supports true color |
| Control mode hangs on exit | Use `-CC` (not `-C`) for application control |
| Agent pane output not reaching control client | Check `#{pane_in_mode}` — copy mode suppresses output |
| Partial paste lost (Terminal.app) | 3.7-rc adds a 5s paste timeout workaround |

---

*Updated: 2026-06-22*
*Target: tmux 3.5+ (recommended: 3.7-rc+ for full feature set)*
