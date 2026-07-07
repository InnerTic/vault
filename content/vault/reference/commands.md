---
title: "Commands"
tags:
  - reference
modified: 2026-06-26
---

# =============================================================================
# QUICK REFERENCE COMMANDS
# Last updated: 2026-06-22
# Source of truth: vault/dotfiles/docs/quick-commands.txt
# Quick view: quickhelp (cat ~/dotfiles/docs/quick-commands.txt)
# =============================================================================
#
# Aliases defined in all three shells (.bashrc, .zshrc, config.fish)
# Canonical source: vault/dotfiles/shell/.{bashrc,zshrc,config.fish}
# Synced to: ~/dotfiles/shell/ → symlinked to ~/.{bashrc,zshrc,config.fish}
# Underlying scripts at:
#   ~/.local/bin/llama-loader          (llm → interactive model selector)
#   ~/.local/bin/test-llma-loader      (test-llm → test model loader)
#   ~/infra/     (textgen-start.sh, llama-server.sh, forge-start.sh, forge-llm.sh)
# =============================================================================

# =============================================================================
# LLAMA.CPP MODEL SELECTOR (INTERACTIVE)
# =============================================================================
llm                     # Launch interactive model selector (lists all .gguf in
                        # ~/Downloads/llm_models/, pick by number, starts llama-server)
                        # Alias: llm → llama-loader → ~/.local/bin/llama-loader
                        # Uses llama-server from text-gen venv (not standalone build)
llmstart                # Same as llm (alternative alias)
llm list                # List models without starting server

# =============================================================================
# LLAMA.CPP QUICK CONTROLS
# =============================================================================
llmcheck                # Check which model is running:
                        #   curl http://127.0.0.1:8080/v1/models
llmk                    # Kill llama-server (alias: llmk → does nothing currently)
                        # Manual: pkill -f llama-server

# API endpoint (once server is running):
#   http://127.0.0.1:8080/v1                  — OpenAI-compatible API base
#   http://127.0.0.1:8080/v1/chat/completions — Chat endpoint
#   http://127.0.0.1:8080/v1/models           — List loaded model

# =============================================================================
# LLAMA.SWAP (ALTERNATIVE — not yet installed)
# =============================================================================
# llama-swap is a Go proxy that lets you hot-swap models without restarting
# the server. Install if you need to switch models frequently.
#   https://github.com/mostlygeek/llama-swap

# =============================================================================
# FORGE (SD WebUI) — Image Generation
# =============================================================================
sdxl                    # Start Forge WebUI on port 7860
                        # Alias → ~/infra/forge-start.sh
                        # Path: /workspace/sd-webui-forge-neo
sdxlkill                # Kill Forge: pkill -f "launch.py\|webui.py"
URL: http://172.16.5.1:7860

# =============================================================================
# TEXT GENERATION WEBUI
# =============================================================================
textgen                 # Start TextGen WebUI on port 7861
                        # Alias → ~/infra/textgen-start.sh
                        # Path: /workspace/textgen
textkill                # Kill TextGen: pkill -f "server.py"
URL: http://172.16.5.1:7861 (Web) / :5000 (API)

# =============================================================================
# OPENCODE
# =============================================================================
oc                      # OpenCode TUI (alias for 'opencode')
ocl                     # OpenCode with local models (auto-starts llama-server)
                        # Alias → ~/.openclaw/workspace/scripts/opencode-local.sh tui (not yet migrated to ~/infra/)
oclw                    # OpenCode Web with local models
                        # Alias → ~/.openclaw/workspace/scripts/opencode-local.sh web (not yet migrated to ~/infra/)

# Models configured in opencode:
#   llama.cpp/Qwen3-VL-8B-Instruct-abliterated-v2.Q5_K_M.gguf (primary)
#   + 5 other models in ~/Downloads/llm_models/

# =============================================================================
# MODEL SWITCHING IN OPENCODE
# =============================================================================
# In TUI, use: /model <provider>/<model>
#   /model Favorites/big-pickle          — cloud (OpenRouter)
#   /model llama.cpp/<model-filename>    — local (requires llama-server running)

# =============================================================================
# QUICK HELP
# =============================================================================
quickhelp               # Show all AI-related aliases

# =============================================================================
# FASTFETCH
# =============================================================================
# Runs automatically on terminal open (configured in ~/.zshrc)
# Config: ~/.config/fastfetch/config.jsonc
# Note: Powerlevel10k instant prompt disabled to preserve fastfetch colors
# See: github.com/romkatv/powerlevel10k/issues/1834

# =============================================================================
# SSH HOSTS (from ~/.ssh/config)
# =============================================================================
ssh proxmox     # Proxmox VE host (172.16.7.1)
ssh quartz      # Quartz wiki LXC (172.16.12.17)
ssh pihole      # Pi-hole DNS LXC (172.16.12.1)
ssh openclawVM  # OpenClaw VM (172.16.12.12)

# =============================================================================
# QUARTZ WIKI — Update after vault changes
# =============================================================================
update-wiki              # Rebuild Quartz site on LXC (172.16.12.17):
                         #   cd ~/vault && git add -A && git commit -m "msg" && git push && ssh quartz "/home/ken/scripts/update-wiki.sh"
                         # Or: ssh quartz "/home/ken/scripts/update-wiki.sh"

# =============================================================================
# VAULT — Script management
# =============================================================================
sync-dotfiles             # Push vault → dotfiles mirror:
                          #   cd ~/vault && git pull
                          #   ~/vault/dotfiles/dotfiles-sync.sh --force
vault-snapshot <script>   # Archive dotfiles/scripts/<script> to vault/script-reference/ as restorable .md
vault-restore <script>    # Restore a single script from vault/script-reference/ back to dotfiles/scripts/
vault-restore-all         # Disaster recovery: restore ALL scripts from vault/script-reference/
check-fixes               # Quality gate — check pending bugs before running apt upgrade

# =============================================================================
# VAULT MAINTENANCE — Local LLM tools (saves tokens on online models)
# =============================================================================
vault-llm.sh audit        # Full vault audit: format + fonts + backlinks (uses local llama.cpp)
vault-llm.sh format       # Check frontmatter, long lines, trailing whitespace, broken wikilinks
vault-llm.sh fonts        # Check heading hierarchy, excessive H1, missing H1
vault-llm.sh backlinks    # Analyze cross-references with local LLM
vault-llm.sh check <file> # Analyze a single file with local LLM (backlinks + formatting + content)
vault-llm.sh rewrite <file> # Rewrite file with local LLM (shows diff, asks approval before writing)
vault-llm.sh fix <file>   # Auto-fix trailing whitespace, long lines, missing frontmatter

# =============================================================================
# FREQUENTLY USED COMMANDS (from shell history)
# =============================================================================
tmux            # Terminal multiplexer (tmux 3.5a)
lsd             # Modern ls replacement (lsd -lah, lsd --tree)
fastfetch       # System info (runs on terminal open)
fish            # Default interactive shell
batcat          # Cat with syntax highlighting (batcat)
fdfind          # Fast file search (fdfind)

# =============================================================================
# NETWORK / SYSTEMS
# =============================================================================
# Akuma: 172.16.5.1   Proxmox: 172.16.7.1
# pihole: 172.16.12.1 MikroTik: 172.16.88.1
# Quartz: 172.16.12.17 ZimaBoard: 172.16.1.1

# =============================================================================
# PYTHON VENV (always use, never system Python)
# =============================================================================
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
pip freeze > requirements.txt   # Save current state

# =============================================================================
# OS SYNC (between Debian 13 and CachyOS)
# =============================================================================
# Source of truth is vault.git. On each OS, to sync:
#   cd ~/vault && git pull             # get latest from GitHub
#   ~/vault/dotfiles/dotfiles-sync.sh --force  # push vault → dotfiles mirror
#
# Symlinks already in place (from bootstrap), so changes take effect immediately:
#   ~/dotfiles/shell/.bashrc → ~/.bashrc          (both OS)
#   ~/dotfiles/shell/.zshrc  → ~/.zshrc           (both OS)
#   ~/dotfiles/shell/config.fish → ~/.config/fish/config.fish  (CachyOS default)
#   ~/dotfiles/ssh/config    → ~/.ssh/config      (both OS)
#
# First-time setup on CachyOS (if not bootstrapped):
#   git clone git@github.com:InnerTic/vault.git ~/vault
#   cd ~/vault/dotfiles && ./dotfiles-sync.sh --force
#   cd ~/vault/dotfiles && ./bootstrap-arch.sh    # creates symlinks

# =============================================================================
# GIT (dotfiles repo)
# =============================================================================
# Repo: git@github.com:InnerTic/dotfiles.git
# Update: cd ~/dotfiles && git pull
# Push changes: cd ~/dotfiles && git add -A && git commit -m "msg" && git push
# NOTE: dotfiles.git is a mirror — edit in vault.git, not directly here

# =============================================================================
# DOCKER
# =============================================================================
# No Docker. All AI tools run natively with CUDA.

# =============================================================================
# BACKUPS
# =============================================================================
# Mega (rclone): ~/.local/bin/rclone
# Push: ~/.openclaw/workspace/scripts/mega-push.sh [LEGACY — no longer maintained]
# Pull: ~/.openclaw/workspace/scripts/mega-pull.sh [LEGACY — no longer maintained]

# =============================================================================
# HISTORICAL — REMOVED / CHANGED
# =============================================================================
# openclaw                  → Not currently installed (venv exists but needs reinstall)
# ~/Documents/select_llama_model.sh → Deleted, replaced by llama-loader (~/.local/bin/)
# alias llma='/home/ken/llama.cpp/build/bin/llama-server' → llama.cpp not built standalone
# llmakill (old alias)      → Not set, use pkill manually
# tmux commands             → tmux not installed
