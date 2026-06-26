---
title: "Tmux Unified"
tags:
  - projects
modified: 2026-06-26
  - tmux-agent-interface
  - tmux-unified
---

# tmux — Unified Reference (tmux 3.5+)

**tmux** (Terminal Multiplexer) runs a background server managing sessions, windows, and panes. Detach/reattach terminals, preserve long-running jobs, and feed pane output to local LLMs — all programmable via control mode.

> **Version target:** tmux 3.5+ (your system: 3.5a). Latest: 3.7-rc (2026-06-12). Check `tmux -V`.

---

## 1. Core Concepts

| Term | Description |
|------|-------------|
| **Server** | Background daemon managing all state. Auto-starts on first tmux command. |
| **Session** | Named group of windows. Survives client disconnects. |
| **Window** | Full-screen view within a session, split into panes. |
| **Pane** | Single terminal area within a window. Runs one process. |
| **Client** | Terminal emulator connected to the server. |
| **Prefix** | Key combo to trigger tmux commands (default: `Ctrl+b`). |

### Identifiers

Stable IDs never change — use in scripts:
- Session: `$N` (e.g. `$0`)
- Window: `@N` (e.g. `@0`)
- Pane: `%N` (e.g. `%0`)

### Environment Variables

Each pane exports:
- `TMUX` — socket path + internal data. Check `$TMUX` to detect if inside tmux.
- `TMUX_PANE` — pane ID.

---

## 2. Quick-Start Walkthroughs

### 2a. Basic Session Lifecycle

```bash
# Create and attach to a named session
tmux new -s myproject

# Inside tmux: prefix+d to detach (session keeps running in background)
# Later: reattach
tmux attach -t myproject

# List sessions
tmux ls

# Kill a session (or: prefix + W, then y)
tmux kill-session -t myproject
```

### 2b. Multi-Pane Dev Workspace

```bash
# Start detached session in a specific directory
tmux new-session -d -s dev -c ~/projects/myapp

# Split into two panes (top/bottom)
tmux split-window -v -t dev:0

# Split again (left/right)
tmux split-window -h -t dev:0.1

# Send commands to specific panes
tmux send-keys -t dev:0.0 'npm run dev' Enter
tmux send-keys -t dev:0.1 'npm test' Enter
tmux send-keys -t dev:0.2 'tail -f logs/app.log' Enter

# Select a specific pane
tmux select-pane -t dev:0.2

# Attach and see everything
tmux attach -t dev
```

### 2c. Copy-Paste Workflow (Vi Keys)

```bash
# Enter copy mode: prefix + [
# Navigate with vi keys: h, j, k, l
# Start selection: v (character) or C-v (rectangle)
# Copy: y (copies to tmux buffer)
# Paste: ] (pastes from tmux buffer)
# With clipboard integration, also copies to system clipboard:
# prefix + ] pastes from system clipboard (set-clipboard on)
```

### 2d. Quick Pane Navigation

```
# Vim-style movement (prefix + h/j/k/l):
prefix + h    move left
prefix + j    move down
prefix + k    move up
prefix + l    move right

# Resize (prefix + Shift+h/j/k/l):
prefix + H    resize left  5 cells
prefix + J    resize down  5 cells
prefix + K    resize up    5 cells
prefix + L    resize right 5 cells

# Rotate panes: prefix + o
# Swap panes: prefix + { or }
# Zoom current pane: prefix + z
```

---

## 3. Key Bindings Reference

### Default Bindings (prefix = Ctrl+b)

| Binding | Action |
|---------|--------|
| `d` | Detach |
| `n` / `p` | Next / previous window |
| `<0-9>` | Jump to window by number |
| `%` | Split horizontal (left/right) |
| `"` | Split vertical (top/bottom) |
| `z` | Toggle pane fullscreen |
| `x` | Kill pane (with confirm) |
| `w` | Window list (interactive picker) |
| `s` | Session list |
| `q` | Show pane numbers briefly |
| `o` | Rotate panes forward |
| `!` | Break pane into new window |
| `:` | Command prompt |
| `?` | List key bindings |
| `[` | Enter copy mode |
| `]` | Paste buffer |
| `-` | Delete most recent copy buffer |
| `#` | List paste buffers |
| `=` | Choose buffer to paste from |
| `f` | Prompt to search all open windows |
| `C-h` | Builtin help for current copy mode |
| `C-[` | Escape (same bindings, tmux 3.7+) |
| `I` | Window info (debug) |

### Essential Custom Bindings (add to `.tmux.conf`)

```tmux
# Reload config without restart
bind r source-file ~/.tmux.conf \; display "Config reloaded"

# Copy to system clipboard (requires xclip/xsel)
bind -T copy-mode-vi y send -X copy-pipe-and-cancel "xclip -selection clipboard"

# Better splits
bind | split-window -h
bind - split-window -v

# Confirm before killing session
bind-key -T prefix W confirm-before -p "Kill session #S? (y/n)" kill-session
```

---

## 4. Control Mode — Programmatic tmux

Control mode is a text-only protocol between tmux and external programs. Most powerful interface for scripting and AI agent integration.

### Starting Control Mode

```bash
# Single -C: canonical mode (for testing/interactive)
tmux -C new-session -s mysession

# Double -CC: no canonical mode (for apps/scripts)
tmux -CC new-session -d -s mysession
```

The `-CC` flag sends a DSC sequence that listening terminals detect. An empty line (Enter) detaches the client.

### The Protocol

Commands produce wrapped responses:

```
%begin <timestamp> <command_num> <flags>
<output>
%end <timestamp> <command_num> <flags>
```

On failure: `%error` replaces `%end`.

### Notifications

Control mode clients receive these on events:

| Event | Format |
|-------|--------|
| Window created | `%window-add @id` |
| Window closed | `%window-close @id` |
| Session changed | `%session-changed $id name` |
| Sessions changed | `%sessions-changed` |
| Pane mode changed | `%pane-mode-changed %id` |
| Pane output | `%output %id text` |
| Client active/detached | `%client-active` / `%client-detached` |
| Window pane changed | `%window-pane-changed @win %pane` |
| Session window changed | `%session-window-changed $sess @win` |

### Format Subscriptions (3.5+)

Subscribe to any format and get notified on change (once/second max). Useful for monitoring GPU usage, build progress, or agent status:

```bash
echo -e "refresh-client -B gpu_monitor:%* '#{pane_width}x#{pane_height}'" \
    | tmux -Ldefault -C attach-session
# → %subscription-changed gpu_monitor %0 80x24
```

Subscription format: `name:type:format` where type is empty (session), `%*` (all panes), `@*` (all windows).

### Flow Control (3.2+)

Pause a pane when output buffers too far behind:

```bash
refresh-client -f pause-after=30   # pause after 30s of backlog
refresh-client -A '%0:continue'    # resume pane %0
```

When paused, `%output` becomes `%extended-output %pane delay_ms : content`.

---

## 5. Scripting tmux

### Target Format

`session:window.pane` — any part omitted uses defaults.

```bash
tmux send-keys -t=mysession:0.1 'python server.py' Enter
tmux capture-pane -t%0 -p                          # by ID
tmux neww -dPF '#{pane_id}' -t=mysession:0        # print pane ID on creation
```

### Idempotent Session Startup

```bash
tmux has-session -t mysession 2>/dev/null \
  || tmux new-session -d -s mysession -x200 -y50
```

### Special Targets

`{last}`, `{next}`, `{previous}`, `{top}`, `{bottom}`, `{left}`, `{right}`, `{top-left}`, `{bottom-right}`, `{up-of}`, `{down-of}`, `{current}` (current window), `{active}` (active pane).

### capture-pane Flags

| Flag | Effect |
|------|--------|
| `-p` | Output to stdout |
| `-S-` | Start from beginning of history |
| `-E-` | End at last line |
| `-e` | Include escape sequences (colour/attributes) |
| `-C` | Escape nonprintable chars as octal |
| `-N` | Preserve trailing spaces |
| `-J` | Join wrapped lines (preserves trailing spaces) |
| `-M` | Use copy mode screen (3.6+) |
| `-l` | Send literally (no key name lookup) |

### Empty Panes (3.3+)

```bash
# Empty pane with content injected via stdin
echo "hello" | tmux splitw -I

# Empty pane with escape sequences (colours, etc.)
printf '\033[H\033[2J\033[31mred' | tmux splitw -I

# Write to existing empty pane
P=$(tmux splitw -dPF '#{pane_id}' '')
echo "hello again" | tmux display -It$P
```

### Piping Pane Output

```bash
:pipe-pane 'cat >~/panelog'     # start piping
:pipe-pane                      # stop piping
bind P pipe-pane -o 'cat >~/panelog'   # toggle binding

# Send input to pane via pipe
:pipe-pane -I 'echo foo'
```

---

## 6. Format Variables

Formats use `#{variable}` syntax. Debug with:

```bash
tmux display -p '#{pane_id}'      # print value
tmux display -a                   # list all known format variables
tmux display -vp '#{pid}'         # verbose expansion trace
```

### Key Variables

| Variable | Description |
|----------|-------------|
| `#{session_name}` / `#{session_id}` | Session name / ID ($N) |
| `#{window_name}` / `#{window_id}` | Window name / ID (@N) |
| `#{pane_id}` | Pane ID (%N) |
| `#{pane_width}` / `#{pane_height}` | Pane dimensions |
| `#{pane_current_path}` | Current working directory |
| `#{pane_title}` | Pane title |
| `#{host}` / `#{user}` | Hostname / username |
| `#{pane_progress}` | Progress bar value (OSC 9;4, 3.7) |
| `#{bracket_paste_flag}` | Bracket paste support (3.7) |
| `#{pane_in_mode}` | Is pane in copy/choose mode? |
| `#{pane_at_top}` / `#{pane_at_bottom}` / `#{pane_at_left}` / `#{pane_at_right}` | Pane position (for wrap prevention) |
| `#{pane_pipe_pid}` | Pipe file descriptor (3.7) |
| `#{socket_path}` | Socket path |
| `#{version}` | tmux version |
| `#{alternate_on}` | Is alternate screen active? |
| `#{mouse_any_flag}` | Does pane's app have mouse enabled? |
| `#{selection_mode}` | Copy mode selection mode (3.7) |
| `#{buffer_full}` | Paste buffer full? |
| `#{t:window_activity}` | Human-readable activity time |

### Useful Modifiers

| Modifier | Example | Result |
|----------|---------|--------|
| `t:` | `#{t:window_activity}` | Human-readable time |
| `b:` | `#{b:@path}` | Basename |
| `d:` | `#{d:@path}` | Directory name |
| `=` | `#{=3:@var}` | Trim to width 3 |
| `p` | `#{p9:@var}` | Pad to width 9 |
| `s/old/new/` | `#{s/abc/xyz/:@var}` | Substitute |
| `q:` | `#{q:@var}` | Quote special chars |
| `e|op|` | `#{e|+|1,2}` | Math: 1+2 |
| `?cond:yes:no` | Ternary | Conditional |
| `W:` | `#{W:#{window_name}}` | Loop all windows |
| `P:` | `#{P:#{pane_id}}` | Loop all panes |

---

## 7. tmux 3.5–3.7 Features

### Bracket-Paste Detection (3.5+)

tmux uses bracket-paste escape sequences (`ESC[200~` / `ESC[201~`) instead of heuristic guessing. Fixes paste issues with Windows Terminal, Terminal.app, and others.

Check: `#{bracket_paste_flag}` format variable.

### OSC 9;4 Progress Bar (3.7)

tmux handles the `ESC]9;4;...ESC\` OSC sequence (iTerm2 / Windows Terminal inline progress). Available as `#{pane_progress}`.

### Floating Panes (3.7)

Floating panes sit above tiled layout like popups but are non-modal — real panes with full escape sequence support. Created with `new-pane` (bound to `Ctrl+b *` by default). Moved/resized with mouse. Second status line lists all panes when `status-format` set to `2`.

```tmux
bind * new-pane
```

### `remain-on-exit` (3.6+)

Keeps the pane alive after exit until a key is pressed. Value `key` added in 3.7 (previously only `on` and `fail`).

```tmux
set -g remain-on-exit key    # pane stays visible until you press a key
```

### Line Numbers in Copy Mode (3.7)

```tmux
set -g copy-mode-line-numbers absolute
# Options: off, default, absolute, relative, hybrid
# hybrid = current line absolute, others relative
```

### Other 3.6/3.7 Additions

- `kill-session -g` — kill all sessions in a session group
- `focus-follows-mouse` — auto-focus pane under mouse (3.7)
- `selection_mode` — explicitly set selection mode in copy mode (3.7)
- `tiled-layout-max-columns` — configure max columns in tiled layout
- `#()` format expansion with `run-shell -N` arguments (3.7)
- `display-message -C` — update pane while message displayed (3.3+)
- `capture-pane -M` — use copy mode screen content (3.6+)
- `window-size` values: `largest`, `smallest`, `latest`, `manual`
- `DECSET 2026` — synchronized output mode (prevents screen tearing) (3.7)
- `default-client-command` — set default command on startup
- `command-prompt -C` — don't freeze panes (3.7)
- `command-prompt -e` — close if empty (3.7)
- `list-keys -O` / `-F` — sorting and custom format (3.7)
- `scroll-exit-on/off/toggle` commands in copy mode (3.7)
- `recentre-top-bottom` — emacs-style command in copy mode (3.7)
- `pane_pipe_pid` — pipe file descriptor format (3.7)
- `-c` works with `new-session -A` (3.7)
- `WAYLAND_DISPLAY` added to `update-environment` (3.7)
- `next`/`previous` variables for windows in `W:` loop (3.7)
- Mouse ranges `control0`–`control9` for pane state line (3.7)
- Tree mode preview customization: `tree-mode-preview-format`, `tree-mode-preview-style` (3.7)
- `OSC 52` works in popups (3.7)
- Paste added to default pane menu (3.7)
- `focus-follows-mouse` option (3.7)
- `prompt-command-cursor-style` (3.7)
- `{current}` / `{active}` for `-t` (3.7)

### Portable Config Between Versions

Use `-q` flag to suppress warnings about unknown options:

```tmux
set -gq mode-bg red    # won't error on old tmux
```

Use `%if` for version-conditional config:

```tmux
%if #{m/r:^next-,#{version}}
    set -g status-style bg=green
%elif #{e|>=|f:#{version},3.5}
    set -g status-style bg=blue
%else
    set -g status-style bg=red
%endif
```

### Checking Configuration

```bash
# Parse without executing
tmux source -n ~/.tmux.conf

# Print parsed form of each command
tmux source -v ~/.tmux.conf

# Start without config, then load manually
tmux -f/dev/null new -d
tmux source -v ~/.tmux.conf
```

---

## 8. tmux + Local AI Integration

### Pattern A: Context Extraction Loop

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

### Pattern B: Observer-Worker Split

Two-pane setup: one for the AI worker, one for monitoring:

```bash
tmux new-session -d -s ai-dev
tmux split-window -v -t ai-dev:0
tmux send-keys -t ai-dev:0.0 'python3 agent.py' Enter          # Worker
tmux send-keys -t ai-dev:0.1 'tail -f logs/agent.log' Enter    # Observer
tmux select-pane -t ai-dev:0.0
tmux attach -t ai-dev
```

### Pattern C: Real-Time Tailing-to-Agent

```bash
# Periodic capture for analysis
watch -n 2 'tmux capture-pane -t agent:0.1 -S-100 -p \
  | ollama run llama3.2 "What issues do you see?"'

# Continuous pipe to streaming LLM
:pipe-pane -I 'cat | tee ~/logs/agent.log | ollama run llama3.2 --stream'
```

### Pattern D: Multi-Agent Coordination

```bash
# Create isolated tmux servers per agent (separate sockets)
tmux -Lagent1 new -d -s agent1 -n main
tmux -Lagent2 new -d -s agent2 -n main
tmux -Lagent3 new -d -s agent3 -n main

# Cross-agent communication via tmux buffers
tmux set-buffer -t agent1 "task: check logs"
tmux show-buffer -t agent2  # read in agent2's context
```

### Pattern E: Control Mode for Automated Agents

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

### Pattern F: Live Capture + LLM Review

```bash
# Watch a pane and send diffs to LLM
while sleep 3; do
  before=$(tmux capture-pane -t agent:0.1 -S- -p | md5sum)
  after=$(tmux capture-pane -t agent:0.1 -S- -p | md5sum)
  [ "$before" != "$after" ] && tmux capture-pane -t agent:0.1 -S- -p \
    | ollama run llama3.2 "New output from agent. Any issues?"
done
```

### Pattern G: Control Mode Python Client

```python
#!/usr/bin/env python3
"""Simple LLM-driven tmux controller via control mode."""
import subprocess, sys

def tmux_cmd(cmd):
    """Send command via control mode, return output."""
    proc = subprocess.run(
        ['tmux', '-Ldefault', '-C', 'attach-session'],
        input=cmd + '\n', capture_output=True, text=True
    )
    return proc.stdout

# Example: list all sessions
result = tmux_cmd('ls -F "#{session_id} #{session_name}"')
print(result)
```

### Pattern H: Pane Silence Monitor for AI Agents

```bash
# In your .tmux.conf
set -g monitor-silence 300   # Alert after 5 minutes of no output
set -g visual-silence on
set -g visual-silence-style "fg=red,bg=black"
```

Custom monitor script:

```bash
#!/bin/bash
# monitor-agent.sh — Alert when agent pane is silent
pane_id="$1"
timeout_sec=300  # 5 minutes

while true; do
    if ! tmux capture-pane -t $pane_id -p -S-50 \
        | grep -q "running\|processing\|thinking"; then
        tmux display-message -t $pane_id "⚠ Agent silent for 5min"
    fi
    sleep 30
done
```

Usage: `./monitor-agent.sh %0 &`

---

## 9. tmuxp — Session-as-Code

Define reproducible AI workspaces in YAML:

```yaml
# ai-workstation.yaml
session_name: ai-workstation
start_directory: ~/projects/ai-project
environment:
  LLAMA_MODEL: ~/models/llama-3.1-8b.Q4_K_M.gguf

windows:
  - window_name: serving
    layout: main-vertical
    panes:
      - name: llama-server
        cmd: |
          cd ~/projects && llama-server -m $LLAMA_MODEL -c 8192 -ngl 99
      - name: gpu-monitor
        cmd: watch -n 5 nvidia-smi
      - name: logs
        cmd: tail -f ~/logs/llama-server.log

  - window_name: agent
    layout: tiled
    panes:
      - name: agent
        cmd: cd ~/projects && python3 agent.py
      - name: logs
        cmd: tail -f ~/logs/agent.log
```

```bash
# Install
pip install tmuxp

# Load
tmuxp load ai-workstation

# Export for sharing
tmuxp export ai-workstation > shared-workspace.yaml
```

---

## 10. .tmux.conf — Reference Configuration

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
set -g remain-on-exit key                       # AI panes stay visible until key press (3.6+)
set -g scroll-on-clear on                       # Scroll into history on clear (3.3+)
set -g fill-character " "                       # Fill char for unused client areas (3.3+)

# === Working Directories ===
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -hc "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"

# === Key Bindings ===
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

# Floating panes (3.7)
bind * new-pane

# Copy pane history to new pane for easy copying (3.2+)
bind C {
    splitw -f -l30% ''
    set-hook -p pane-mode-changed 'if -F "#{!=:#{pane_mode},copy-mode}" "kill-pane"'
    copy-mode -s'{last}'
}

# === Status Bar ===
set -g status-interval 5
set -g status-justify centre
set -g status-left-length 40
set -g status-right-length 120
set -g status-left "#[fg=green,bold]#S #[fg:white]• #[fg=cyan]#(whoami)@#h"
set -g status-right "#[fg=yellow]%Y-%m-%d %H:%M "
set -g status-style "fg=white,bg=#1a1a2e"
set -g window-status-current-style "fg=black,bg=cyan"
set -g window-status-style "fg=white,dim"
set -g pane-border-style "fg=#444"
set -g pane-active-border-style "fg=cyan"
set -g message-style "fg=black,bg=yellow"

# === Alert Monitoring (AI agent status) ===
set -g monitor-activity on
set -g visual-activity off
set -g monitor-bell on
set -g visual-bell off
set -g monitor-silence 300   # Alert if agent silent for 5 min
set -g visual-silence on

# === Clipboard ===
set -g set-clipboard on
set -g get-clipboard on      # Request clipboard from terminal (3.6+)

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

## 11. Ecosystem Tools

| Project | Description |
|---------|-------------|
| [tmuxp](https://github.com/tmuxp/tmuxp) | Session-as-code YAML layouts |
| [mux](https://github.com/tony/mux) | TUI tmux session manager for AI coding |
| [Armada](https://github.com/rguiu/armada) | Fleet management for coding agents. Persistent tmux sessions + web dashboard |
| [jawn-tmux](https://github.com/jamditis/jawn-tmux) | tmux session manager — visual pane attention, live sidebar |
| [tmux-logging](https://github.com/ChrisDill/tmux-logging) | Automatic session logging |
| [tmux-scp](https://github.com/ChrisDill/tmux-scp) | SCP files from tmux panes |
| [moto](https://github.com/floomhq/moto) | Terminal IDE for AI agents. Docker-first runtime, tmux integration, 60+ skills |
| [ccgram](https://github.com/alexei-led/ccgram) | Telegram ↔ tmux/herdr bridge for Claude Code, Codex CLI, Gemini CLI |
| [tmux-control](https://github.com/csheaff/tmux-control) | Emacs control-mode client for persistent tmux panes |

---

## 12. Troubleshooting

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
| Partial paste lost (Terminal.app) | 3.7 adds 5s paste timeout workaround |
| tmux says "no sessions" but sessions existed | `pkill -USR1 tmux` to recreate socket |
| tmux freezes terminal on attach | `set -g set-titles off` |
| No colour in terminal | Set `default-terminal "tmux-256color"` + `terminal-features` |
| Escape key has delay | Set `escape-time 0` (fast network) or higher (slow network) |
| tmux exits with "server exited unexpectedly" | Server crashed — enable core dumps: `ulimit -c unlimited` |
| Modified keys not working (C-Left, etc.) | Ensure `TERM` is correct; try `tmux-256color`; check `extended-keys` |

---

*Updated: 2026-06-22*
*Source: tmux/tmux CHANGES (3.7-rc), tmux wiki, ecosystem projects*
*Target: tmux 3.5+ (recommended: 3.7-rc+ for full feature set)*
