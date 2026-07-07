---
title: "Tmux Research V3"
tags:
  - projects
modified: 2026-06-26
---

# Tmux — Research Notes (v3)

**tmux** (Terminal Multiplexer) runs a background server that manages sessions, windows, and panes. Detach/reattach terminals, preserve long-running jobs, and feed pane output to local LLMs — all programmable via control mode.

> Latest stable: tmux 3.6b (May 2026). Release candidate 3.7-rc is available. Target this document: 3.5+ (recommended: 3.7+ for full feature set).

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

### Special Environment Variables

Each pane sets two variables:
- `TMUX` — socket path + internal data. Check `$TMUX` to detect if running inside tmux.
- `TMUX_PANE` — pane ID (e.g. `%11`).

---

## tmux 3.6 / 3.7 Features

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

### Other Notable 3.6/3.7 Additions

- `kill-session -g` — kill all sessions in a session group
- `focus-follows-mouse` — auto-focus pane under mouse (3.7)
- `selection_mode` — explicitly set selection mode in copy mode
- `tiled-layout-max-columns` — configure max columns in tiled layout
- `get-clipboard` — request clipboard from terminal and forward to pane
- `DECSET 2026` — synchronized output mode (prevents screen tearing)
- `#()` format expansion with `run-shell -N` arguments
- `display-message -C` — update pane while message is displayed (3.3+)
- `capture-pane -M` — use copy mode screen content (3.6)
- `source -N` — pass arguments to shell command after `#()`
- `window-size` values: `largest`, `smallest`, `latest`, `manual`
- `default-client-command` — set default command when tmux starts without arguments

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
On failure: `%error` replaces `%end`.

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
- `%window-pane-changed @window %pane`
- `%session-window-changed $session @window`

### Format Subscriptions (3.5+)

Subscribe to any format and get notified on change (once/second max). Ideal for monitoring GPU usage, model health, or build progress:

```bash
echo -e "refresh-client -B gpu:%* '#{pane_width}x#{pane_height}'" \
    | tmux -Ldefault -C attach-session
# -> %subscription-changed gpu %0 80x24
```

Subscription format: `name:type:format` where type is empty (session), `%*` (all panes), `@*` (all windows).

### Flow Control (3.2+)

Pause a pane when output buffers too far behind:
```bash
refresh-client -f pause-after=30   # pause after 30s of backlog
refresh-client -A '%0:continue'    # resume pane %0
```

When paused, `%output` becomes `%extended-output %pane delay_ms : content`.

### Advanced Control Mode: get-clipboard

tmux 3.6+ supports `get-clipboard` — request clipboard from the terminal and forward to the requesting pane:

```tmux
set -g get-clipboard on    # request clipboard from terminal
# Then use: tmux set-buffer -w 'content'  to set from outside
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

Special targets: `{last}`, `{next}`, `{previous}`, `{top}`, `{bottom}`, `{left}`, `{right}`, `{top-left}`, `{bottom-right}`, `{up-of}`, `{down-of}`, etc.

### Idempotent Session Startup

```bash
tmux has-session -t mysession 2>/dev/null \
  || tmux new-session -d -s mysession -x200 -y50
```

### Creating Layouts

```bash
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

### capture-pane Flags

| Flag | Effect |
|------|--------|
| `-p` | Output to stdout |
| `-S-` | Start from beginning of history |
| `-E-` | End at last line |
| `-e` | Include escape sequences for colour/attributes |
| `-C` | Escape nonprintable chars as octal |
| `-N` | Preserve trailing spaces |
| `-J` | Join wrapped lines (preserves trailing spaces) |
| `-M` | Use copy mode screen (3.6+) |
| `-l` | Send literally (no key name lookup) |

### Empty Panes (3.3+)

```bash
# Empty pane with content injected via stdin
echo "hello" | tmux splitw -I

# Empty pane with escape sequences
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

## Formats — Quick Reference

Formats use `#{variable}` syntax. The `display-message` command is the best way to debug:

```bash
tmux display -p '#{pane_id}'      # print value
tmux display -a                   # list all known format variables
tmux display -vp '#{pid}'         # verbose expansion trace
```

### Key Format Variables

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
#{pane_progress}      # Progress bar value (OSC 9;4, 3.7)
#{pane_pipe_pid}      # Pipe FD (3.7)
#{bracket_paste_flag} # Bracket paste support (3.7)
#{socket_path}        # Socket path
#{version}            # tmux version
#{pane_in_mode}       # Is pane in copy/choose mode?
#{mouse_any_flag}     # Pane's app has mouse enabled
#{alternate_on}       # Is alternate screen active?
#{selection_mode}     # Copy mode selection mode
#{buffer_full}        # Paste buffer full?
#{t:window_activity}  # Human-readable activity time
```

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

### 6. tmux + Local AI Project Ecosystem

| Project | Description |
|---------|-------------|
| [mux](https://github.com/tony/mux) | TUI tmux session manager for AI coding |
| tmuxp | Session-as-code YAML layouts |
| [tmux-logging](https://github.com/ChrisDill/tmux-logging) | Automatic session logging |
| [tmux-scp](https://github.com/ChrisDill/tmux-scp) | SCP files from tmux panes |

### 7. Tmux + LLM Integration Patterns

**Pattern A: Live Capture + LLM Review**
```bash
# Watch a pane and send diffs to LLM
while sleep 3; do
  before=$(tmux capture-pane -t agent:0.1 -S- -p | md5sum)
  after=$(tmux capture-pane -t agent:0.1 -S- -p | md5sum)
  [ "$before" != "$after" ] && tmux capture-pane -t agent:0.1 -S- -p \
    | ollama run llama3.2 "New output from agent. Any issues?"
done
```

**Pattern B: Multi-Agent Coordination**
```bash
# Create isolated tmux servers per agent
tmux -Lagent1 new -d -s agent1 -n main
tmux -Lagent2 new -d -s agent2 -n main
tmux -Lagent3 new -d -s agent3 -n main

# Cross-agent communication via tmux buffers
tmux set-buffer -t agent1 "task: check logs"
tmux show-buffer -t agent2  # read in agent2's context
```

**Pattern C: LLM-Driven tmux via Control Mode**
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

---

## Configuration File Recipes

### Create New Panes in Same Working Directory

```tmux
bind '"' split-window -c "#{pane_current_path}"
bind % split-window -hc "#{pane_current_path}"
bind c new-window -c "#{pane_current_path}"
```

### Prevent Pane Movement Wrapping

```tmux
bind -r Up if -F '#{pane_at_top}' '' 'selectp -U'
bind -r Down if -F '#{pane_at_bottom}' '' 'selectp -D'
bind -r Left if -F '#{pane_at_left}' '' 'selectp -L'
bind -r Right if -F '#{pane_at_right}' '' 'selectp -R'
```

### Create a New Pane to Copy (3.2+)

Opens a new pane with the history of the active pane for easy copying:

```tmux
bind C {
    splitw -f -l30% ''
    set-hook -p pane-mode-changed 'if -F "#{!=:#{pane_mode},copy-mode}" "kill-pane"'
    copy-mode -s'{last}'
}
```

### Menu Button on Pane Border (3.7+)

```tmux
set -g pane-border-status top
set -g pane-border-format "
#{?pane_active,#[reverse],}#{pane_index} #{pane_title}
#{?#{mouse},#[align=right] #[range=control|9][Menu]#[norange],}"

bind -n MouseDown1Control9 "
    display-menu -t= -xM -yM -O -T 'Pane: #{pane_index}' \
    '#{?pane_marked,Unmark,Mark}' 'm' { select-pane -m } \
    '#{?window_zoomed_flag,Unzoom,Zoom}' 'z' { resize-pane -Z } \
    'Horizontal Split' 'h' { split-window -h } \
    'Vertical Split' 'v' { split-window -v } \
    '' \
    'Kill' 'X' { kill-pane -t= }"
```

### Portable .tmux.conf Between Versions

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

### Checking Configuration Files

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
