---
title: "System State"
tags:
  - system-state
---

# System State

**Type:** State document (not a changelog — describes current truth at a point in time)
**Updated:** 2026-06-21 (session: stale paths, GitHub push, sync safety, tmux, restorable archives, AI maintenance guide)

## Hardware

| Component | Spec |
|-----------|------|
| CPU | 16 cores |
| GPU 0 | RTX 3060 (12GB, sm_86) |
| GPU 1 | Tesla P40 (24GB, sm_61) |
| RAM | — |
| Storage SSD | — |
| Storage HDD | — |

## OS

| Property        | Value                                            |
| --------------- | ------------------------------------------------ |
| Distro          | Debian 13 Trixie (primary) / CachyOS (dual-boot) |
| DE              | KDE Plasma 6 (Wayland)                           |
| Shell (Debian)  | bash (default), omz/zsh and fish/tide            |
| Shell (CachyOS) | fish                                             |

## GPU Assignment

| GPU | Port | Purpose | CUDA_VISIBLE_DEVICES |
|-----|------|---------|---------------------|
| RTX 3060 | 8080 | Small/medium LLMs, SD Forge | 0 |
| Tesla P40 | 8081 | Large LLMs (30B-70B Q4) | 1 |

Nvidia driver: 580.159.04 (CachyOS) / 580.142 (Debian) — same 580.x branch.
CUDA: 12.9 (CachyOS) / 12.4 (Debian) — intentional per-distro.

## Running Services (Typical)

| Service             | Port      | GPU       | Start Command                |
| ------------------- | --------- | --------- | ---------------------------- |
| llama-server (text) | 8080-8088 | varies    | `llama-loader` or `llmstart` |
| TextGen WebUI       | 7861      | see below | `textgen`                    |
| SD Forge Neo        | 7860      | RTX 3060  | `sdxl`                       |
| Pi-hole             | 53/80     | N/A       | LXC 104                      |
| SearXNG             | 8888      | N/A       | LXC 108                      |
| Cosmos              | —         | N/A       | LXC 111                      |
| LibreNMS            | —         | N/A       | LXC 202                      |

## Directory Layout — Canonical Paths

```
~/vault/                          # Source of truth (git) — pushed to InnerTic/vault.git
  docs/vault/                     #   Knowledge (docs by subject)
  dotfiles/                       #   Canonical dotfiles + scripts
    scripts/                      #     All startup scripts (canonical)
    shell/                        #     .bashrc, .zshrc, config.fish
    git/                          #     .gitconfig
    ssh/                          #     ssh config
    tmux/                         #     .tmux.conf (linked to ~/.tmux.conf)
  script-reference/               #   Restorable archives of every script (.md with checksums)
    llama-loader/core/dialects/   #     36 archives total, mirroring dotfiles/scripts/ tree
    forge-llm.md
    ...
  infra/                          #   CONTRACT.md + schema validator
  docs/vault/reference/
    dual-repo-workflow.md         #   Full push/sync/archive/restore instructions
    ai-vault-maintenance.md       #   AI agent guide with authority levels (0-5)
  docs/vault/projects/
    llama-loader/                 #   Knowledge tree: architecture, incidents, changelog
      architecture/               #     compiler-authority, ir-schema, execution-planner
      incidents/                  #     np-flag-regression, tensor-split-migration
      changelog/CHANGELOG.md      #     version history
      INDEX.md

~/dotfiles/                       # Symlink → /mnt/workspace/dotfiles/ (separate git repo, dotfiles.git)
~/infra/                          # Read-only mirror of vault/dotfiles/scripts/ (flat)
  vault-snapshot.sh               #   Batch archive by project name
  vault-restore.sh                #   Restore single script from archive (verify + write + git preview)
  vault-restore-all.sh            #   Bulk disaster recovery
  archive-script.sh               #   Create restorable archive of a single script
  textgen-start.sh                #   TextGen WebUI launcher
  forge-start.sh                  #   SD Forge Neo launcher
  llama-server.sh                 #   llama-server wrapper (custom CUDA build)
  llama-loader/                   #   Interactive model selector (full dir)
  healthcheck.sh                  #   System health check
  ...

~/.local/bin/
  llama-loader -> ~/infra/llama-loader/llama-loader.sh

~/.tmux.conf -> ~/dotfiles/tmux/.tmux.conf   # tmux 3.5a, mouse on, 256-color, vi copy mode
```

## Startup Scripts

| Alias | Script | What it starts |
|-------|--------|----------------|
| `sdxl` | `~/infra/forge-start.sh` | SD Forge Neo on :7860 |
| `textgen` | `~/infra/textgen-start.sh` | TextGen WebUI on :7861 |
| `llmstart` | `~/infra/llama-server.sh` | llama-server (thin wrapper) |
| `llm` | `~/.local/bin/llama-loader` | Interactive GGUF model selector |
| `llmk` | `pkill -f llama-server` | Kill llama-server |
| `textkill` | `pkill -f "server.py"` | Kill TextGen |
| `llmcheck` | `curl 127.0.0.1:8080/v1/models \| jq` | Check running model |

## tmux

- tmux 3.5a installed
- Config: `vault/dotfiles/tmux/.tmux.conf` → `~/.tmux.conf` (symlink)
- Mouse on, 256-color/truecolor, vi copy mode, 50000-line history
- `|` splits horizontally, `-` splits vertically, `hjkl` for pane navigation
- `Shift+H/J/K/L` for resize
- Status bar: session name, user@host, timestamp
- Auto-starts `main` session

## llama-loader Knowledge Tree

Located at `docs/vault/projects/llama-loader/`:

| Path | Content |
|------|---------|
| `INDEX.md` | Overview + directory |
| `architecture/compiler-authority.md` | Why single CLI emitter, enforcement |
| `architecture/ir-schema.md` | IR values contract (NP_VAL, NGL, etc.) |
| `architecture/execution-planner.md` | Mode → builder → compiler flow |
| `incidents/np-flag-regression.md` | Root cause: save_state stored CLI syntax |
| `incidents/tensor-split-migration.md` | Root cause: --split renamed to --tensor-split |
| `changelog/CHANGELOG.md` | Version history |

## llama-loader Architecture

```
Mode script (last.sh / factory.sh / preset-router.sh)
  ↓ sets IR values (NP_VAL, CTX_SIZE, TENSOR_SPLIT, MAIN_GPU, …)
core/run.sh
  ↓ sources
core/dialects/llama.cpp.sh  (IR → CLI compiler)
  ↓ outputs CMD array with correct flags (-np, --tensor-split, …)
exec llama-server <flags>
```

Correct flag mappings:
- `-np` / `--parallel` (not `--np`)
- `--tensor-split` (not `--split`)
- `-c` / `--ctx-size`
- `-ngl`
- `--main-gpu`

## Vault Architecture

```
vault.git (single source of truth) — pushed to InnerTic/vault.git
  ├── docs/                    → knowledge, organized by subject
  ├── dotfiles/                → canonical dotfiles + scripts
  ├── script-reference/        → restorable archives (.md with checksums)
  └── infra/                   → CONTRACT.md + schema validator
       │
       ▼ (one-way rsync --delete via dotfiles-sync.sh)
  dotfiles.git (read-only mirror of vault/dotfiles/)
  infra.git   (read-only mirror of vault/dotfiles/scripts/)
```

**Rule:** Never modify mirrors directly. All changes go into vault/dotfiles/, then sync out.

### Sync Script (dotfiles-sync.sh)

Enhanced with:
- **Pre-flight validation** — refuses sync if source has fewer than 10 entries (guards against empty source wiping mirrors)
- **Confirmation prompt** — `--apply` asks "Proceed? [y/N]" before syncing
- **Rollback tagging** — creates `git tag pre-sync-<timestamp>` on the dotfiles mirror before syncing
- `--status` shows diff summary; `--force` skips confirmation

### Script Archive / Restore System

Every script in `dotfiles/scripts/` has a restorable archive at `script-reference/` (36 total).

Each archive is a `.md` file with YAML frontmatter:
```yaml
---
source: dotfiles/scripts/llama-loader/core/dialects/llama.cpp.sh
restorable: true
checksum: faaa8a71b33ade174dce53517d713926d43a1b32ce12e4b4d416e7257f5dda7c
last_verified: 2026-06-21
---
```

Workflow:
- `archive-script <path>` — create/update an archive
- `vault-snapshot <project>` — batch archive by project
- `vault-restore <name>` — search, verify checksum, show diff, restore with confirmation
- `vault-restore-all` — bulk disaster recovery (clone vault → restore-all → clone dotfiles → sync → bootstrap)

### AI Vault Maintenance Guide (`docs/vault/reference/ai-vault-maintenance.md`)

Defines 5 authority levels (0-5), evidence rules (3 sources minimum before code changes), confidence footers on AI-generated docs, vault distillation workflow (raw chat → curated note), and never-touch list (`.obsidian/`, `archive/`, `script-reference/`).

Core mission: *If the human disappears for 6 months, could another human or AI reconstruct the system from this vault?*

## Key Builds

- llama.cpp: `/mnt/workspace/llama.cpp/build/bin/llama-server` — CUDA 12.4, `CMAKE_CUDA_ARCHITECTURES="61;86"`
- TextGen WebUI: `/mnt/workspace/textgen/` — Python venv, CUDA 12.4 torch
- SD Forge Neo: `/mnt/workspace/sd-webui-forge-neo/` — Python venv
- llama-server bundled in TextGen venv: sm_75+ only (no P40 support)

## Network

- Hostname: Akuma
- LAN: `172.16.5.1` (br0)
- Proxmox: `.7.1`
- LXC zone: `.12.x`
- SSH key: `~/.ssh/id_ed25519` (single key for Akuma, Proxmox, containers)

## Linked LXC Containers

| ID | Name | Status |
|----|------|--------|
| 104 | pihole | running |
| 108 | searxng | running |
| 111 | cosmos | running |
| 202 | librenms | running |
| 300 | quartz-test | stopped |
| 301 | quartz-base | running |

## Shell Aliases (all 3 shells — bash/zsh/fish)

All defined identically in `vault/dotfiles/shell/`. AI aliases point to `~/infra/` (deploy mirror of vault/dotfiles/scripts/).

- `~/.zshrc` → `~/dotfiles/shell/.zshrc` (symlink through dotfiles mirror)
- `~/.config/fish/config.fish` → `~/dotfiles/shell/config.fish` (symlink through dotfiles mirror)
- `~/.bashrc` — standalone file (not a symlink; vault copy is alias-only fragment)

## Push Status

| Repo | Remote | Status |
|------|--------|--------|
| vault.git | `git@github.com:InnerTic/vault.git` | Pushed (master + tags) |
| dotfiles.git | `git@github.com:InnerTic/dotfiles.git` | Working mirror, needs separate push after sync |
