---
title: "Tmux Research V3 Ref"
tags:
  - projects
modified: 2026-06-26
  - tmux-agent-interface
  - tmux-research-v3-ref
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
| `?` | List key bindings (view mode) |
| `/` | Search key binding prompt |
| `r` | Reload config (with bind) |
| `C` | Copy history to new pane (with bind) |

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
%pause <pane_id>                       # Pane paused (flow control)
%continue <pane_id>                    # Pane continued
%extended-output <pane_id> <delay_ms> : <text>  # With flow control
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
| tmux says "no sessions" but sessions existed | `pkill -USR1 tmux` to recreate socket |
| tmux freezes terminal on attach | `set -g set-titles off` |
| No colour in terminal | Set `default-terminal "tmux-256color"` + `terminal-features` |
| Escape key has delay | Set `escape-time 0` (fast network) or higher (slow network) |
| tmux exits with "server exited unexpectedly" | Server crashed — enable core dumps: `ulimit -c unlimited` |
| Modified keys not working (C-Left, etc.) | Ensure `TERM` is correct; try `tmux-256color`; check `extended-keys` |

---

*Updated: 2026-06-22*
*Source: tmux/tmux.wiki (cloned), tmux CHANGES (master), online wiki pages*
*Target: tmux 3.5+ (recommended: 3.7-rc+ for full feature set)*
