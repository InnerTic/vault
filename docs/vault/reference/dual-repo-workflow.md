# Vault → Dotfiles Dual-Repo Workflow

Two repos serve different purposes. This doc explains how they relate, how to push changes, and how the script archive/restore system works.

## Repo Roles

| Repo | Remote | Purpose | Path |
|------|--------|---------|------|
| **vault.git** | `git@github.com:InnerTic/vault.git` | Source of truth — docs, records, config source | `~/vault/` |
| **dotfiles.git** | `git@github.com:InnerTic/dotfiles.git` | Working scripts — live env, symlink targets, executables | `/mnt/workspace/dotfiles/` (`~/dotfiles/` → symlink) |

## How They Relate

```
vault.git (source of truth)
  ├── docs/                          → knowledge, references, project plans
  ├── dotfiles/scripts/              → canonical script source
  ├── dotfiles/shell/                → canonical shell configs
  ├── dotfiles-sync.sh               → sync vault → dotfiles mirror
  ├── script-reference/              → restorable script archives (.md)
  │   ├── llama-loader/core/dialects/llama.cpp.md
  │   ├── forge-llm.md
  │   ├── vault-restore.md
  │   └── ...
  └── docs/vault/projects/llama-loader/
      ├── architecture/              → design decisions, contracts
      ├── changelog/                 → version history
      ├── incidents/                 → bug regressions, root causes
      └── INDEX.md

dotfiles.git (working mirror)
  ├── scripts/                       → executable scripts (rsynced from vault)
  ├── shell/                         → shell configs (rsynced from vault)
  ├── bootstrap/                     → install modules
  ├── archive-script.sh              → create restorable archive
  ├── vault-snapshot.sh              → batch archive by project
  ├── vault-restore.sh               → restore single script from archive
  └── vault-restore-all.sh           → bulk disaster recovery
```

## Script Archive System (Self-Restoring Artifacts)

Every script in `dotfiles/scripts/` has a restorable archive at `vault/script-reference/`.

### Archive Format

Each archive is a markdown file with YAML frontmatter:

```markdown
---
source: dotfiles/scripts/llama-loader/core/dialects/llama.cpp.sh
restorable: true
checksum: faaa8a71b33ade174dce53517d713926d43a1b32ce12e4b4d416e7257f5dda7c
last_verified: 2026-06-21
---

# llama.cpp.sh

```bash
#!/usr/bin/env bash
# ... full script content ...
```

## Restore

```bash
vault-restore llama.cpp
```
```

The archive is both human-readable and machine-restorable.

### Archiving a Script

```bash
# Archive a single script
archive-script llama-loader/core/dialects/llama.cpp.sh

# Archive a whole project
vault-snapshot llama-loader

# Archive everything
archive-script --all

# List available targets
vault-snapshot --list
```

Creates or updates: `vault/script-reference/<path>.md`

### Restoring a Script

```bash
# Search by name (fuzzy)
vault-restore llama.cpp

# Exact path
vault-restore llama-loader/core/dialects/llama.cpp

# Preview without restoring
# (run vault-restore --list to see what's available)

# Restore everything (disaster recovery)
vault-restore-all
```

The restore process:
1. Reads YAML frontmatter for source path and expected checksum
2. Extracts the bash code block
3. Verifies checksum
4. Shows diff vs live file (if exists)
5. Asks for confirmation
6. Writes file, sets +x permissions
7. Shows git status preview

### Verifying Archive Integrity

```bash
vault-restore --status    # checksums vs code blocks
vault-restore --list      # all restorable scripts
```

## Push Workflow

### When you change docs only (no scripts)

```bash
cd ~/vault
git add -A
git commit -m "description"
git push
```

No sync needed — dotfiles.git only cares about scripts/configs, not docs.

### When you change scripts or shell configs

```bash
# 1. Edit source of truth
vim ~/vault/dotfiles/scripts/forge-llm.sh

# 2. Commit vault
cd ~/vault
git add -A
git commit -m "forge-llm: fix GPU selector"
git push

# 3. (optional) Update archive
archive-script forge-llm.sh

# 4. Sync to dotfiles mirror
~/vault/dotfiles/dotfiles-sync.sh --apply   # dry-run first to review

# 5. Commit and push dotfiles
cd /mnt/workspace/dotfiles
git add -A
git commit -m "sync from vault: forge-llm fix"
git push
```

### Quick one-liner (scripts changed)

```bash
cd ~/vault && git add -A && git commit -m "msg" && git push && \
  ~/vault/dotfiles/dotfiles-sync.sh --apply && \
  cd /mnt/workspace/dotfiles && git add -A && git commit -m "sync: msg" && git push
```

## Disaster Recovery (After Disk Failure)

```bash
# 1. Clone vault (the single source of truth)
git clone git@github.com:InnerTic/vault.git ~/vault

# 2. Restore all scripts from archives
~/vault/dotfiles/scripts/vault-restore-all

# 3. Clone dotfiles mirror
git clone git@github.com:InnerTic/dotfiles.git ~/dotfiles

# 4. Sync to match
~/vault/dotfiles/dotfiles-sync.sh --apply

# 5. Bootstrap environment
~/dotfiles/bootstrap.sh
```

This restores every script exactly as archived, with checksum verification.

## Lifecycle

```
Live Script (dotfiles/)
     ↓
archive-script.sh
     ↓
Restorable Archive (vault/script-reference/*.md)
     ↓
git commit + push (vault.git)
     ↓
git clone (new machine)
     ↓
vault-restore-all
     ↓
Live Script (dotfiles/)
```

## Important Rules

- **NEVER** edit files directly in `/mnt/workspace/dotfiles/` — edit in `~/vault/`, then sync
- **NEVER** edit `~/.zshrc` or `~/.config/fish/config.fish` directly — they're symlinks to dotfiles repo
  - Edit `~/vault/dotfiles/shell/.zshrc`, sync, then push dotfiles
- `~/.bashrc` is a standalone file (not synced) — the vault copy is an alias-only fragment
- Always run `dotfiles-sync.sh` in dry-run mode first before `--apply`
- Run `dotfiles-sync.sh --status` to check for drift at any time
- After changing a script, consider running `archive-script` to update its archive
