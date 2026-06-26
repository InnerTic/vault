---
title: "Tmux Walkthroughs"
tags:
  - projects
modified: 2026-06-26
  - tmux-agent-interface
  - tmux-walkthroughs
---

# tmux Walkthroughs — Practical Guides

Step-by-step walkthroughs for common tmux workflows, focused on AI/developer setups.

---

## 1. Setting Up AI Dev Workspace

Goal: Create a multi-pane workspace for running a local LLM + agent pipeline.

### Step 1: Start the server

```bash
tmux new-session -d -s ai-dev -x200 -y60
```

### Step 2: Create the layout

```bash
# Window 0: Model serving
tmux rename-window -t ai-dev:0 model

# Split into two panes vertically
tmux split-window -v -t ai-dev:0.0
tmux split-window -h -t ai-dev:0.0

# Rename panes
tmux select-pane -t ai-dev:0.0
tmux send-keys -t ai-dev:0.0 'llama-server -m ~/models/llama-3.1-8b.Q4_K_M.gguf -c 8192 -ngl 99' Enter
# Top-left: llama-server

tmux select-pane -t ai-dev:0.1
tmux send-keys -t ai-dev:0.1 'watch -n 5 nvidia-smi' Enter
# Top-right: GPU monitor

tmux select-pane -t ai-dev:0.2
tmux send-keys -t ai-dev:0.2 'tail -f logs/llama.log' Enter
# Bottom: log viewer
```

### Step 3: Add agent window

```bash
# Create new window
tmux new-window -t ai-dev:1 -n agent

# Split into worker + observer
tmux split-window -v -t ai-dev:1.0

tmux send-keys -t ai-dev:1.0 'python3 agent.py --model http://localhost:8080' Enter
tmux send-keys -t ai-dev:1.1 'tail -f logs/agent.log' Enter
```

### Step 4: Attach and go

```bash
tmux attach -t ai-dev
```

**Result:** You now have a workspace with:
- Window 0: Model serving + GPU monitoring + logs
- Window 1: AI agent + log observer

---

## 2. Control Mode — Automated LLM Output Capture

Goal: Have a Python script continuously monitor a tmux pane and feed changes to a local LLM.

### Setup

```python
#!/usr/bin/env python3
"""Monitor tmux pane and pipe new output to ollama."""
import subprocess, sys, hashlib, time

def capture_pane(pane_id):
    """Capture pane history."""
    proc = subprocess.run(
        ['tmux', 'capture-pane', '-t', pane_id, '-S-', '-E-', '-p', '-e'],
        capture_output=True, text=True
    )
    return proc.stdout

def send_to_llm(text):
    """Send text to local LLM for analysis."""
    proc = subprocess.run(
        ['ollama', 'run', 'llama3.2', 'Analyze this output:\\n' + text],
        input='', capture_output=True, text=True
    )
    return proc.stdout

# Configuration
pane_id = '%0'  # Adjust to your pane ID
hash_before = hashlib.md5(b'').hexdigest()
interval = 2  # seconds

print(f"Monitoring pane {pane_id} every {interval}s...")
print("Press Ctrl+C to stop.\n")

try:
    while True:
        output = capture_pane(pane_id)
        hash_after = hashlib.md5(output.encode()).hexdigest()

        if hash_after != hash_before:
            print(f"--- Change detected at {time.strftime('%H:%M:%S')} ---")
            # Show last 20 lines of new output
            lines = output.strip().split('\n')[-20:]
            analysis = send_to_llm('\n'.join(lines))
            print(analysis)
            print()

        hash_before = hash_after
        time.sleep(interval)
except KeyboardInterrupt:
    print("\nStopped.")
```

### Usage

```bash
# Find your pane ID
tmux list-panes -F '#{pane_id} #{pane_title}'

# Run the monitor
python3 monitor.py
```

---

## 3. tmuxp — Session-as-Code for AI Workflows

Goal: Define your AI workspace in YAML and recreate it with one command.

### Step 1: Install tmuxp

```bash
pip install tmuxp
```

### Step 2: Create workspace definition

```yaml
# ~/projects/ai-workspace.yaml
session_name: ai-workspace
start_directory: ~/projects/my-ai-project

# Set environment variables for all windows
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

  - window_name: training
    layout: tiled
    panes:
      - name: training
        cmd: cd ~/projects && python3 train.py --epochs 10
      - name: loss-chart
        cmd: python3 plot_loss.py
      - name: tensorboard
        cmd: tensorboard --logdir ~/runs --port 6006

  - window_name: inference
    layout: main-horizontal
    panes:
      - name: api-client
        cmd: cd ~/projects && python3 test_inference.py
      - name: results
        cmd: tail -f ~/results/output.log

  - window_name: shell
    layout: main-horizontal
    panes:
      - name: bash
        focus: true
      - name: nvim
        cmd: nvim
```

### Step 3: Load it

```bash
tmuxp load ~/projects/ai-workspace.yaml
```

### Step 4: Export for sharing

```bash
tmuxp export ai-workspace > shared-workspace.yaml
```

---

## 4. Remote tmux — SSH Workflow

Goal: Start tmux sessions remotely and attach from anywhere.

### Setup on remote server

```bash
# Start tmux session detached
tmux new-session -d -s remote-work -x200 -y60

# Create your layout
tmux send-keys -t remote-work:0 'python3 server.py' Enter
tmux split-window -v -t remote-work:0
tmux send-keys -t remote-work:0.1 'tail -f server.log' Enter
```

### From your local machine

```bash
# SSH with X forwarding for full tmux experience
ssh -t user@remote 'tmux attach -t remote-work'

# Or with a custom socket for multiple sessions
ssh user@remote 'tmux -S /tmp/mysocket attach -t remote-work'
```

### Persistent over reboots (with systemd)

```bash
# Create user service
cat > ~/.config/systemd/user/tmux-server.service << 'EOF'
[Unit]
Description=tmux server

[Service]
ExecStart=/usr/bin/tmux new-session -d -s main
ExecStop=/usr/bin/tmux kill-server
Restart=on-failure

[Install]
WantedBy=default.target
EOF

systemctl --user enable --now tmux-server
```

---

## 5. Multi-Agent Coordination with tmux

Goal: Run multiple AI coding agents in parallel, each in isolated tmux servers.

### Step 1: Start isolated servers

```bash
# Each agent gets its own tmux server (separate socket)
tmux -Lagent1 new -d -s agent1 -n main -x200 -y60
tmux -Lagent2 new -d -s agent2 -n main -x200 -y60
tmux -Lagent3 new -d -s agent3 -n main -x200 -y60
```

### Step 2: Set up agent layouts

```bash
# Agent 1: Backend work
tmux send-keys -t agent1:0 'cd ~/projects/backend && python3 main.py' Enter
tmux split-window -v -t agent1:0
tmux send-keys -t agent1:0.1 'cd ~/projects/backend && pytest' Enter

# Agent 2: Frontend work
tmux send-keys -t agent2:0 'cd ~/projects/frontend && npm run dev' Enter
tmux split-window -v -t agent2:0
tmux send-keys -t agent2:0.1 'cd ~/projects/frontend && npm test' Enter

# Agent 3: Data processing
tmux send-keys -t agent3:0 'cd ~/projects/data && python3 pipeline.py' Enter
tmux split-window -v -t agent3:0
tmux send-keys -t agent3:0.1 'cd ~/projects/data && python3 monitor.py' Enter
```

### Step 3: Cross-agent communication

```bash
# Set a buffer in agent1
tmux -Lagent1 set-buffer -t agent1 "TASK: check frontend logs"

# Show buffer from agent2
tmux -Lagent2 show-buffer -t agent1

# Or use a shared file
echo "TASK: check logs" > ~/shared-tasks/agent1-task.txt
echo "TASK: review PRs" > ~/shared-tasks/agent2-task.txt
```

### Step 4: Monitor all agents

```bash
# Quick status check
for agent in agent1 agent2 agent3; do
    echo "=== $agent ==="
    tmux -L$agent list-panes -t $agent -F '#{pane_id} #{pane_title}'
    tmux -L$agent capture-pane -t $agent:0 -S-5 -p
    echo
done
```

---

## 6. tmux + Armada — Fleet Management

Goal: Use Armada (https://github.com/rguiu/armada) for managing multiple coding agents.

### Install

```bash
pip install armada-ai
armada setup
```

### Usage

```bash
# Start the dashboard
armada

# Open http://127.0.0.1:9100

# From the dashboard:
# 1. Add a project
# 2. Create a node (select agent type: Claude Code, OpenCode, or Bash)
# 3. Attach to the node
# 4. Monitor from any device (QR code for mobile)
```

Armada handles:
- Persistent tmux sessions per agent
- Web dashboard for monitoring
- Task mailbox for inter-agent communication
- MCP server integration

---

## 7. tmux Control Mode — Python Client

Goal: Build a Python client that controls tmux via control mode protocol.

```python
#!/usr/bin/env python3
"""tmux control mode client."""
import subprocess
import re
import select
import sys

class TmuxControlClient:
    """Client for tmux control mode."""

    def __init__(self, socket_name='default', session_name=None):
        self.socket_name = socket_name
        self.session_name = session_name
        self.proc = None

    def connect(self):
        """Start control mode session."""
        cmd = ['tmux', '-L', self.socket_name, '-C', 'new-session', '-d', '-s', self.session_name or 'ctrl']
        self.proc = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        # Wait for session to be ready
        import time
        time.sleep(0.5)

    def command(self, cmd, timeout=10):
        """Send a tmux command and get response."""
        if not self.proc or self.proc.poll() is not None:
            self.connect()

        self.proc.stdin.write(cmd + '\n')
        self.proc.stdin.flush()

        # Read response
        start = time.time()
        output = ''
        while time.time() - start < timeout:
            if self.proc.stdout.readable():
                line = self.proc.stdout.readline()
                if not line:
                    break
                output += line
                if line.strip().startswith('%end') or line.strip().startswith('%error'):
                    break
            else:
                time.sleep(0.01)

        return output

    def capture(self, target, lines=-1):
        """Capture pane output."""
        return self.command(f'capture-pane -t {target} -S- -E- -p')

    def send(self, target, text, enter=True):
        """Send text to pane."""
        cmd = f'send-keys -t {target} ' + repr(text)
        if enter:
            cmd += ' Enter'
        return self.command(cmd)

# Usage
client = TmuxControlClient(socket_name='main', session_name='dev')
client.connect()
print(client.capture('0.0'))
```

---

## 8. Monitoring Agent Output with tmux

Goal: Set up alerts when an AI agent stops producing output.

### Using monitor-silence

```tmux
# In your .tmux.conf
set -g monitor-silence 300   # Alert after 5 minutes of no output
set -g visual-silence on
set -g visual-silence-style "fg=red,bg=black"
```

### Advanced: Custom silence monitor

```bash
#!/bin/bash
# monitor-agent.sh — Alert when agent pane is silent
pane_id="$1"
timeout_sec=300  # 5 minutes

while true; do
    # Get last output timestamp from pane
    last_output=$(tmux capture-pane -t $pane_id -S-100 -p | tail -1)
    current_time=$(date +%s)

    # Check for activity indicator (adjust for your agent)
    if ! tmux capture-pane -t $pane_id -p -S-50 | grep -q "running\|processing\|thinking"; then
        echo "Agent ${pane_id} may be silent. Last output: ${last_output}"
        # Send notification
        tmux display-message -t $pane_id "⚠ Agent silent for 5min"
    fi

    sleep 30  # Check every 30 seconds
done
```

Usage:
```bash
./monitor-agent.sh %0 &
```

---

## 9. tmux + Ollama Integration

Goal: Feed tmux pane output directly to Ollama for real-time analysis.

### One-shot analysis

```bash
# Capture last 100 lines and analyze
tmux capture-pane -t agent:0 -S-100 -p | ollama run llama3.2 "What does this output tell us?"
```

### Continuous monitoring

```bash
#!/bin/bash
# monitor-ollama.sh
pane="$1"

while true; do
    output=$(tmux capture-pane -t $pane -S-50 -p)

    # Only analyze if output changed
    if [ "$output" != "$last_output" ]; then
        echo "$output" | ollama run llama3.2 "New output from agent: what's happening?"
        last_output="$output"
    fi

    sleep 5
done
```

---

## 10. Quick Reference Commands

| Task | Command |
|------|---------|
| Create session | `tmux new -s name` |
| Reattach | `tmux attach -t name` |
| List sessions | `tmux ls` |
| Kill session | `tmux kill-session -t name` |
| Split vertical | `prefix + "` |
| Split horizontal | `prefix + %` |
| Copy mode | `prefix + [` |
| Paste | `prefix + ]` |
| Reload config | `prefix + r` |
| Send to pane | `tmux send-keys -t target 'cmd' Enter` |
| Capture pane | `tmux capture-pane -t target -S- -p` |
| Control mode | `tmux -CC new-session -d -s name` |
| Check version | `tmux -V` |

---

*Updated: 2026-06-22*
*Focused on practical workflows for AI/developer setups*
