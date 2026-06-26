---
title: "CONTRACT"
tags:
  - infra
---

# INFRA PATH CONTRACT — Canonical Layout

This document defines the ONLY valid execution paths for `~/infra/`.
All vault docs, scripts, and configs MUST reference infra paths that conform to this schema.
Any path not listed here is a schema violation.

## Schema version: 1.0
## Last validated: 2026-06-21

## Canonical layout

```
~/infra/                          # Executable deployment root
├── forge-start.sh                # SD WebUI Forge starter
├── healthcheck.sh                # System health check
├── llama-server.sh               # llama.cpp server wrapper
├── check-fixes.sh                # Runtime fix application
├── toggle-gpu-profile.sh         # GPU profile switcher
├── toggle-p40.sh                 # P40 passthrough toggle
├── toggle-p40.example.yaml       # P40 config example
├── live-env-setup.sh             # Live ISO environment setup
├── link-workspace.sh             # Workspace symlink manager
├── build-gold-lxc.sh             # Gold LXC template builder
├── lxc-bootstrap.sh              # LXC environment bootstrap
├── lxc-provision.sh              # LXC provisioner
├── test-cleanup-backups.sh       # Backup cleanup test
├── llama-loader.old              # Legacy llama-loader
│
├── bootstrap/                    # System bootstrap profiles
│   ├── bootstrap.sh              #   Desktop profile
│   ├── debian.sh                 #   Debian profile
│   ├── cachyos.sh                #   CachyOS profile
│   ├── container.sh              #   Container profile
│   ├── proxmox.sh                #   Proxmox profile
│   ├── server.sh                 #   Server profile
│   ├── lib/common.sh             #   Shared bootstrap lib
│   └── lib/runner.sh             #   Module runner
│   └── modules/                  #   Bootstrap modules
│       ├── 10-sudo-lecture.sh    #     Sudo lecture disable
│       ├── 12-containers.sh      #     Container tooling
│       ├── 20-shell.sh           #     Shell config
│       ├── 30-git.sh             #     Git config
│       ├── 40-fastfetch.sh       #     Fastfetch config
│       ├── 50-tmux.sh            #     Tmux config
│       └── 60-ssh.sh             #     SSH config
│
├── llama-loader/                 # llama-loader modular system
│   ├── llama-loader.sh           #   Entry point
│   ├── lib/common.sh             #   Shared library
│   ├── builder/                  #   IR builders
│   │   ├── concurrency.sh
│   │   ├── context.sh
│   │   ├── gpu.sh
│   │   └── network.sh
│   ├── core/                     #   Core execution
│   │   ├── run.sh
│   │   ├── execution_plan.sh
│   │   └── dialects/llama.cpp.sh
│   ├── introspect/evaluate.sh    #   System evaluation
│   ├── modes/                    #   Execution modes
│   │   ├── factory.sh
│   │   ├── custom.sh
│   │   ├── last.sh
│   │   └── preset-router.sh
│   ├── presets/                  #   Preset configurations
│   │   ├── 1-small.sh
│   │   ├── 2-balanced.sh
│   │   ├── 3-long-context.sh
│   │   └── 4-rag-server.sh
│   └── state/state.json          #   Runtime state
│
└── lxc/                          # LXC component scripts
    ├── core.sh
    ├── fonts.sh
    ├── fish.sh
    ├── zsh.sh
    └── aliases.sh
```

## Path set (machine-parsable)

```
forge-start.sh
healthcheck.sh
llama-server.sh
check-fixes.sh
toggle-gpu-profile.sh
toggle-p40.sh
toggle-p40.example.yaml
live-env-setup.sh
link-workspace.sh
build-gold-lxc.sh
lxc-bootstrap.sh
lxc-provision.sh
test-cleanup-backups.sh
llama-loader.old
bootstrap/bootstrap.sh
bootstrap/debian.sh
bootstrap/cachyos.sh
bootstrap/container.sh
bootstrap/proxmox.sh
bootstrap/server.sh
bootstrap/lib/common.sh
bootstrap/lib/runner.sh
bootstrap/modules/10-sudo-lecture.sh
bootstrap/modules/12-containers.sh
bootstrap/modules/20-shell.sh
bootstrap/modules/30-git.sh
bootstrap/modules/40-fastfetch.sh
bootstrap/modules/50-tmux.sh
bootstrap/modules/60-ssh.sh
llama-loader/llama-loader.sh
llama-loader/lib/common.sh
llama-loader/builder/concurrency.sh
llama-loader/builder/context.sh
llama-loader/builder/gpu.sh
llama-loader/builder/network.sh
llama-loader/core/run.sh
llama-loader/core/execution_plan.sh
llama-loader/core/dialects/llama.cpp.sh
llama-loader/introspect/evaluate.sh
llama-loader/modes/factory.sh
llama-loader/modes/custom.sh
llama-loader/modes/last.sh
llama-loader/modes/preset-router.sh
llama-loader/presets/1-small.sh
llama-loader/presets/2-balanced.sh
llama-loader/presets/3-long-context.sh
llama-loader/presets/4-rag-server.sh
llama-loader/state/state.json
lxc/core.sh
lxc/fonts.sh
lxc/fish.sh
lxc/zsh.sh
lxc/aliases.sh
```

## Contract rules

1. All infra scripts live at `~/infra/` root — no subdirectory grouping (services/, system/, proxmox/)
2. Scripts with internal module trees (llama-loader/, bootstrap/, lxc/) keep their internal structure
3. No script references `~/infra/services/*` — they are at `~/infra/*`
4. No script references `~/infra/system/*` — they are at `~/infra/*`
5. No script references `~/infra/proxmox/*` — they are at `~/infra/*`
6. The full path set above is the ONLY valid reference space

## Validation command

```bash
# Check if a given infra path is canonical:
grep -Fx "path/to/file" ~/vault/infra/CONTRACT.md
```
