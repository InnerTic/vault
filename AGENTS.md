---
title: "AGENTS"
tags:
  - AGENTS
modified: 2026-06-26
---

# vault.git — Single source of truth for Akuma

Personal knowledge vault, system config, and documentation repo. **Not a software project.** No build system, no package manager, no tests.

## Two-repo architecture

| Repo | Role | Clone |
|------|------|-------|
| `vault.git` | Source of truth | `~/vault` |
| `dotfiles.git` | Read-only mirror of `vault/dotfiles/` | `~/dotfiles` |

After editing anything under `dotfiles/`, sync the mirror:
```bash
cd ~/vault && git pull
~/vault/dotfiles/dotfiles-sync.sh --force
```
Then boot the other OS and repeat.

## Host Akuma

- **Dual-boot**: Debian 13 Trixie (bash) / CachyOS (fish)
- **GPU 0**: RTX 3060 (12 GB, sm_86) — small/medium LLMs + SD Forge
- **GPU 1**: Tesla P40 (24 GB, sm_61) — large LLMs (30B–70B Q4)
- llama.cpp built with `CMAKE_CUDA_ARCHITECTURES="61;86"`
- `nvidia-smi --id=0` to isolate RTX 3060 from P40

## Key paths

| Path | Content |
|------|---------|
| `docs/` | Obsidian vault (`[[wikilinks]]`, `.obsidian/`) |
| `docs/INDEX.md` | Starting point |
| `dotfiles/` | Shell, git, SSH, tmux configs + scripts |
| `infra/CONTRACT.md` | Canonical path schema for `~/infra/` |
| `script-reference/` | One `.md` per script |
| `/workspace/textgen` | TextGen WebUI (`~/infra/textgen-start.sh`, port 7861) |
| `/workspace/sd-webui-forge-neo` | SD Forge (`~/infra/forge-start.sh`, port 7860) |
| `~/.local/bin/llama-loader` | Interactive model manager (selects GGUF, starts llama-server) |
| `~/.local/bin/vault-attribution.py` | Citation pipeline: scan uncited files, compare against source repos, apply source: fields, AI audit |

## Conventions

- All infra scripts deploy to `~/infra/` root (no subdirectory grouping per `infra/CONTRACT.md`)
- All docs use Obsidian `[[wikilinks]]` for cross-references
- Installation docs must be full commands with flags + annotations + source URLs — goal: clean reinstall recoverable from this repo alone
- Model inventory: `find ~/Downloads/llm_models/ -name '*.gguf' -printf '%f\t%s\n'` (filenames drift)
- Git user: `InnerTic` / `innertic@users.noreply.github.com`
- All vault .md files should have YAML frontmatter with `title:` and `tags:` — deterministic tag derivation from directory path + filename
- **DO NOT archive `meta-scripts.md`** — it is an active, in-progress project. The file's original content erroneously read "Abandoned" (from vault import), causing a loop where agents kept moving it to `archive/`. Corrected 2026-06-26: content rewritten, cross-refs fixed, restored to `projects/`.
- **Journal structure:** Daily notes at `journal/YYYY-MM-DD.md` are 1-page indexes with `[[wikilinks]]` to work entries at `journal/entries/YYYY/YYYYMMDD-NNN-Slug.md`. Each entry has a unique immutable ID (`YYYYMMDD-NNN`). Template at `journal/TEMPLATE.md`.

## Sessions

### 2026-06-26 — Vault tag/formatting audit + full frontmatter fix

**Trigger**: User noticed missing tags and misformatted text across vault.

**Scan** (local Qwen3.6-35B on P40, 12 batches of 20, ~30 min):
- 240 .md files scanned
- 150 missing frontmatter, 36 had frontmatter but no tags, 54 OK
- 112 files with long lines (>120 chars), 15 with trailing whitespace

**Fix** (`/tmp/vault-fix-frontmatter.sh`):
- 186 files fixed (150 got full frontmatter + tags, 36 got tags added)
- Tags derived from directory components + filename (e.g. `software/ai-tools/llama-setup.md` → `software, ai, llama-setup`)
- Remaining issues: long lines (cosmetic), some titles need human review

**Dotfiles sync**: Added `node_modules/`, `.serena/`, `quartz-data/`, `scripts/archive/` to `dotfiles/.gitignore`, synced mirror and pushed (`deb@0f8655c`).

### 2026-06-28 — Meta-scripts abortloop fix + Citation pipeline + Web Pipeline

**Trigger**: User reported meta-scripts.md was repeatedly archived by agents despite being active. User requested local web fetching solution after SearXNG API returned 403.

**Meta-scripts fix**:
- File had `status: abandoned` and "Abandoned" in title/body since vault import (`382849c`)
- Agents kept moving it to `archive/`; user corrected twice across two days
- Fixed: moved back to `projects/`, rewrote content, fixed 6 cross-refs in map, knowledge-audit, projects README, scripts README, changelog
- Added DO NOT ARCHIVE rule to AGENTS.md conventions

**Citation pipeline** (`~/.local/bin/vault-attribution.py`):
- 5-phase CLI: scan, fetch, compare, apply, audit
- Line-level Jaccard similarity (≥90% auto, ≥50% review)
- Local AI audit via llama-server for remaining uncited files
- 242 vault files: 38 cited, 204 uncited

**Web Pipeline** (`/mnt/workspace/web-pipeline/`):
- 3-tier escalation: Firecrawl → Playwright Stealth → Persistent Browser
- Persistent: `chromium.launchPersistentContext` with profile at `profiles/default/`, Xvfb for non-headless display, `--force-dark-mode`
- Cache: MD5-hashed, 10-min TTL
- MCP server wired in `opencode.jsonc` as `web-pipeline` tool `web_fetch`
- Tested: example.com (stealth ✓), HN (stealth ✓), qidian.com (persistent, rendered real content)
- Logger: per-fetch `.md` notes with YAML frontmatter + aggregated `journal.md` with `[[wikilinks]]`
- Cleanup: `cleanup.js` removes fetch notes older than 24h

**Journal**: `docs/vault/journal/2026-06-28.md` — 1-page daily index with `[[wikilinks]]` to 3 work entries at `journal/entries/2026/20260628-{001,002,003}.md`. Each entry has immutable ID, structured frontmatter (projects, systems, files, lessons). Template at `journal/TEMPLATE.md`.

**Key decisions**:
- Pipeline lives at `/mnt/workspace/web-pipeline/` (not `/opt/` — no sudo)
- Persistent browser profile at `/mnt/workspace/web-pipeline/profiles/default/`
- No raw page content in logs — metadata only in journal, content in cache
- Per-fetch notes cleaned after 24h
