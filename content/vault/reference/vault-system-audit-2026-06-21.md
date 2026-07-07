---
title: "Vault System Audit 2026 06 21"
tags:
  - reference
modified: 2026-06-26
---

# VAULT SYSTEM AUDIT — COMPLETE REPORT

**Date:** 2026-06-21
**Auditor:** opencode
**Final Result:** **WARN** — 13 findings (4 HIGH, 4 MED, 5 LOW) — 6 system_backup stale refs FIXED

---

## PHASE 1: STRUCTURE — PASS

| Check | Result |
|---|---|
| Total files in vault | 256 (253 git-tracked) |
| Markdown files | 155 |
| Top-level dirs | `docs/`, `dotfiles/` (+ 3 root files) |
| Orphan directories | None |
| Mixed runtime+docs | `vault/dotfiles/` (by design), `docs/vault/scripts/` (by design), `docs/vault/system/` (by design) |

**Verdict:** Clean structure. No structural issues.

---

## PHASE 2: MIRROR CONSISTENCY — PASS

| Mirror | vs Vault | Result |
|---|---|---|
| `~/dotfiles/` | `vault/dotfiles/` | ZERO DIFF |
| `~/infra/` | `vault/dotfiles/scripts/` | ZERO DIFF |

**Verdict:** Both mirrors are perfect projections of vault.

---

## PHASE 3: CROSS-REFERENCE — FAIL (6 broken paths, 2 FIXED)

### HIGH — Execution paths that will fail

| # | File | Path | Issue |
|---|---|---|---|
| H1 | `docs/vault/hardware/gpu/tesla-p40-vfio.md:33` | `/home/ken/infra/system/toggle-p40.sh` | infra has flat layout — `toggle-p40.sh` at root, not in `system/` |
| H2 | `docs/vault/scripts/REBUILD_SCRIPT.sh:225` | `~/infra/services/llama-server.sh` | infra has flat layout — no `services/` subdir |
| H3 | `docs/vault/system/rebuild-script.sh:227` | `~/infra/services/llama-server.sh` | Same path issue |
| H4 | `docs/vault/scripts/REBUILD_SCRIPT.md:228` | `~/infra/services/llama-server.sh` | Same path issue |
| H5 | `docs/vault/system/rebuild-notes.md:61` | `~/infra/services/forge-start.sh` | infra has flat layout — `forge-start.sh` at root |
| H6 | `docs/vault/system/debian-setup-hoops.md:88,203` | `~/infra/services/llama-server.sh`, `~/infra/services/forge-start.sh` | Flat layout issue |

### HIGH — Missing dependency file

| # | File | Path | Issue |
|---|---|---|---|
| H7 | `docs/vault/scripts/package-install.sh:12` | `$HOME/dotfiles/docs/system_backup/pkglist-apps.txt` | **FIXED** — now uses `$HOME/vault/docs/vault/software/packages/pkglist-debian.txt` (package-install.md:15) |
| H8 | `docs/vault/scripts/REBUILD_SCRIPT.sh:39-41` | `~/dotfiles/docs/system_backup/pkglist-apps.txt` | **FIXED** — now uses `~/dotfiles/pkglist/debian.txt` (REBUILD_SCRIPT.md:42,44) |

### MED — Stale doc references

| # | File | Issue |
|---|---|---|
| M1 | `docs/vault/system/debian-setup-hoops.md:216-217,241` | References `docs/system_backup/` paths | **FIXED** — file no longer contains stale refs (now references `pkglist-debian.txt` directly) |
| M2 | `docs/vault/scripts/live-env-setup.sh:66` | `$HOME_DIR/dotfiles/docs/system_backup/pkglist-apps.txt` | **FIXED** — source live-env-setup.md already uses `dotfiles/pkglist/debian.txt` |
| M3 | `docs/vault/scripts/live-env-setup.md:69` | Same broken path | **FIXED** — already uses `$HOME_DIR/dotfiles/pkglist/debian.txt` |
| M4 | `docs/vault/context/INDEX.md:36` | References `system_backup/` | **FIXED** — now references `archive/` |

### LOW — Cosmetic references

| # | File | Issue |
|---|---|---|
| L1 | `docs/vault/system/workspace-symlink-strategy.md:74-80` | References `/mnt/workspace/dotfiles/` — valid on Akuma, not cross-repo |
| L2 | `docs/vault/QUICK-START.md:29-35` | Same `/mnt/workspace/dotfiles/` path — valid on Akuma |
| L3 | `docs/vault/system/backup-checklist.md:17` | `~/dotfiles/` as backup source — still valid as mirror |
| L4 | `docs/vault/system/system-memory.md:155,187` | `cd ~/dotfiles && ./bootstrap.sh` — still valid |
| L5 | `docs/vault/reference/key-locations.md:83` | References `/mnt/workspace/docs/Documents/system_backup/` — historical | **FIXED** — marked as archived in vault/archive/ |

---

## PHASE 4: EXECUTION SAFETY — PASS (2 notes)

| Check | Result |
|---|---|
| Shebangs present | All scripts have shebangs (mix of `#!/bin/bash` and `#!/usr/bin/env bash`) |
| Hardcoded /home/ken paths | None found in infra scripts |
| Scripts calling other repos | `lxc/zsh.sh` clones powerlevel10k from GitHub (upstream, acceptable) |
| `live-env-setup.sh` clones dotfiles from GitHub (mirror source, acceptable) |

**Notes:**
1. Inconsistent shebangs (`/bin/bash` vs `/usr/bin/env bash`) — cosmetic only
2. `lxc-bootstrap.sh:9` references GitHub raw URL for curl-pipe-bash — expected for LXC bootstrap pattern

---

## PHASE 5: SYNC INTEGRITY — PASS

| Check | Result |
|---|---|
| dotfiles mirror drift | ZERO DRIFT |
| infra mirror drift | ZERO DRIFT |
| `--delete` scope | Excludes `.git` — safe |

**Verdict:** Sync mechanism works correctly. No drift detected.

---

## PHASE 6: BOOTSTRAP COMPLETENESS — WARN

| Check | Result |
|---|---|
| Profiles | 6: debian, cachyos, container, proxmox, server, desktop |
| Modules | 7: sudo-lecture, containers, shell, git, fastfetch, tmux, ssh |
| Per-distro bootstrap | 6 bootstrap*.sh files at dotfiles root |
| Auto-detect env type | Manual profile selection (no auto-detect) |

**Gap:** `pkglist-apps.txt` missing — scripts that depend on a machine-parseable package list will fail. Package lists exist as `.md` files in `vault/software/packages/` but no script extracts them. Core bootstrap (shell/git/ssh) works without this.

---

## PHASE 7: FAILURE MODE ANALYSIS — WARN (4 gaps)

| # | Issue | Severity |
|---|---|---|
| F1 | **No pre-flight validation in sync script** — `rsync --delete` could wipe mirrors if vault source is empty/corrupted | HIGH |
| F2 | **No rollback mechanism** — mirror state not versioned; no git tag upon sync | MED |
| F3 | **No remote/backup for vault.git** — `git remote -v` returns nothing; local disk failure = total loss | HIGH |
| F4 | **No confirmation prompt in sync script** — `--apply` runs immediately without `Are you sure?` | LOW |

---

## AUDIT SUMMARY

```
PHASE 1: Structure       ██████████  PASS   (clean, no structural issues)
PHASE 2: Mirror sync     ██████████  PASS   (zero diff on both mirrors)
PHASE 3: Cross-refs      ████████░░  FAIL   (6 broken paths, system_backup refs FIXED)
PHASE 4: Execution       ██████████  PASS   (clean, minor shebang inconsistency)
PHASE 5: Sync integrity  ██████████  PASS   (zero drift)
PHASE 6: Bootstrap       ████████░░  WARN  (pkglist-apps.txt missing)
PHASE 7: Failure mode    ████████░░  WARN  (no backup, no rollback, no validation)

FINAL: WARN — 13 findings (4 HIGH, 4 MED, 5 LOW) — 6 system_backup stale refs FIXED
```

**Key questions answered:**
- Is vault still the compiler input? **YES** — vault is sole source of truth
- Are dotfiles + infra still pure outputs? **YES** — mirrors are perfect projections
- Has runtime leaked back into source? **NO** — no runtime leakage detected

**Critical path forward:**
1. FIX infra path references (`~/infra/services/*` → `~/infra/*`, `/home/ken/infra/system/` → `/home/ken/infra/`)
2. ~~FIX `pkglist-apps.txt` — either recreate from `.md` or update scripts to use vault paths~~ **DONE** — scripts now reference `dotfiles/pkglist/debian.txt` and `vault/docs/vault/software/packages/pkglist-debian.txt`
3. ~~FIX `docs/system_backup` stale references~~ **DONE** — all 6 system_backup stale refs updated to `archive/` or correct pkglist paths
4. ADD pre-flight validation to sync script
5. ADD rollback mechanism (git tags on sync)
6. SET UP remote for vault.git
