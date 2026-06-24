# Vault Restructure — Migration Complete

**Date:** 2026-06-22
**Status:** Complete
**Trigger:** Desktop notes had unreconciled content; vault had structural issues

## What Changed

### Structural
- Removed duplicate `.obsidian/` at vault root (kept `docs/.obsidian/`)
- Moved `VAULT-TODO.md` out of nested `docs/vault/docs/` → `docs/vault/`
- Removed duplicate package lists from `docs/vault/software/packages/` (canonical at `dotfiles/pkglist/`)
- Moved `migration/` → `archive/migration/`
- Removed archive backup dupes (`*-backup.md`), stale `.txt` command refs, superseded `ssh-key-instruction.txt`
- Moved root `CHANGELOG.md`, `CHANGELOG.raw.md` → `docs/`
- Moved `KEY_LOCATIONS.txt` → `reference/`

### Content Added

| Source | Destination | Files |
|--------|------------|-------|
| Desktop tmux research | `projects/tmux-agent-interface/` | 8 files (evolution, guides v1–v4, walkthroughs, unified ref) |
| Desktop Akuma distillation | `system/` | 5 files (raw, state, narrative, index, versions) |
| Desktop vault-evolution | `reference/` | 4 files (raw, state, narrative, index) |
| Desktop Hermes configs | `archive/` | 3 files (2 yaml + 1 diff) |
| Desktop Text File (4).txt | `projects/llama-loader/archive/compiler-contract-implementation-plan.md` | 1 file (distilled plan) |
| gguf-agent-compile.md (orphan from script-reference/) | Desktop/notes/projects/gguf-agent-compile/ | 1 file (unimplemented idea) |

### Ideas Reverted

Projects the user was unsure about moved back to `Desktop/notes/projects/`:
- `gguf-chat-template-injector/`
- `agent-prompt-compiler/`

### Docs Updated
- `map.md` — fully rewritten, all new content + previously missing files added
- `QUICK-START.md` — 4 broken wikilinks fixed
- `llama-loader/INDEX.md` — archive entry added
- `textgen-webui.md` — P40 CUDA library fix documented

## Verification

- `map.md` lists all vault files and sections
- No duplicate `.obsidian/` directories
- No nested `docs/vault/docs/` paths
- No stale `migration/` at top level
- No script-reference orphans
- Root level: only `docs/`, `dotfiles/`, `infra/`, `script-reference/`

---
Confidence: High
Sources: 3
Derived From:
  - vault-organization-audit-2026-06-22
  - Desktop notes scan
  - Session decisions
---
