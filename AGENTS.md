---
title: "AGENTS"
tags:
  - AGENTS
modified: 2026-07-11
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

- **Dual-boot**: MX Linux 13 Trixie (AI workstation, bash) / CachyOS (gaming, fish)
- **MX Linux boot**: RTX 3060 + Tesla P40 both on nvidia driver — LLM inference, SD Forge
- **CachyOS boot**: Tesla P40 passed through to VM via VFIO — gaming
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
| `/mnt/data/model_storage/` | **Canonical model store** (HDD, btrfs). All GGUFs live here. |
| `~/Downloads/llm_models` | Symlink → `/mnt/data/model_storage/` |
| `

## Conventions

- All infra scripts deploy to `~/infra/` root (no subdirectory grouping per `infra/CONTRACT.md`)
- All docs use Obsidian `[[wikilinks]]` for cross-references
- Installation docs must be full commands with flags + annotations + source URLs — goal: clean reinstall recoverable from this repo alone
- Model inventory: `find /mnt/data/model_storage/ -maxdepth 1 -name '*.gguf' -printf '%f\t%s\n'`
- Git user: `InnerTic` / `innertic@users.noreply.github.com`
- All vault .md files must have YAML frontmatter with `title:` and `tags:` — deterministic tag derivation from directory path + filename. Every new file must be tagged before commit.
- All vault .md files must be backlinkable: use `[[wikilinks]]` to cross-reference related pages. No file is an island — every note should link to at least one other vault page.
- The local AI generates content only into `Inbox/` directories. Any file outside an Inbox must be human-reviewed and confirmed tagged + linked before it is considered permanent.
- **DO NOT archive `meta-scripts.md`** — it is an active, in-progress project. The file's original content erroneously read "Abandoned" (from vault import), causing a loop where agents kept moving it to `archive/`. Corrected 2026-06-26: content rewritten, cross-refs fixed, restored to `projects/`.
- **Journal structure:** Daily notes at `docs/vault/journal/YYYY/MM/YYYY-MM-DD.md` sit alongside their work entries under `docs/vault/journal/YYYY/MM/entries/YYYYMMDD-NNN-Slug.md`. Each entry has a unique immutable ID (`YYYYMMDD-NNN`). Template at `docs/vault/journal/TEMPLATE.md`.
- **Learning pipeline:** New curricula live under `docs/vault/learning/<topic>/Inbox/`. Run `learn-topic <topic>` to generate roadmap; `learn-topic <topic> --lesson N` for lessons; `learn-topic <topic> --lab N` for labs. All AI output goes to Inbox/ for human review.

## Sessions

### Vault Hygiene — 2026-06-26

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

### Web Pipeline — 2026-06-28

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

**Journal**: `docs/vault/journal/2026-06-28.md` — 1-page daily index with `[[wikilinks]]` to 3 work entries at `docs/vault/journal/entries/2026/20260628-{001,002,003}.md`. Each entry has immutable ID, structured frontmatter (projects, systems, files, lessons). Template at `docs/vault/journal/TEMPLATE.md`.

### Learning Pipeline — 2026-06-28

**Trigger**: User identified that the learning pipeline and note taxonomy needed explicit rules for tagging and backlinks.

**Conventions hardened** (AGENTS.md):
- Every vault file must have YAML frontmatter with `title:` and `tags:`
- Every vault file must be backlinkable — at least one `[[wikilink]]` per note
- AI content goes only to `Inbox/`; human review required before promoting
- Learning pipeline path: `docs/vault/learning/<topic>/Inbox/`
- Commands: `learn-topic <topic>` (roadmap), `learn-topic <topic> --lesson N`, `learn-topic <topic> --lab N`

**learn-topic script** (`~/.local/bin/learn-topic`):
- Updated all three prompt templates (roadmap, lesson, lab) to enforce tags + backlinks in generated output
- Fixed VAULT_DIR default from `~/vault/docs` to `~/vault/docs/vault` so learning content nests under `docs/vault/learning/`
- Installed to `~/.local/bin/`

**Note-taxonomy doc**:
- Added explicit rules: every file must be tagged (derived from path) and backlinkable (min 1 wikilink)
- No orphan notes invariant documented

**tmux pilot**:
- Generated roadmap at `docs/vault/learning/tmux/Inbox/00 - Roadmap.md`
- 5 modules, 14 lessons, 5 labs, 3 capstones
- Tags: learning, tmux, roadmap — status: draft — backlinks throughout
- Ready for user review, then lesson generation

**Key decisions**:
- Learning pipeline content lives under `docs/vault/learning/` (inside the Obsidian vault), not `docs/learning/`
- All AI-generated vault content must be tagged AND backlinkable — both enforced in prompt templates
- Script defaults now match actual vault layout

**Next steps**:
1. User reviews tmux roadmap — approve to permanent (rename, drop status: draft)
2. Run `learn-topic tmux --lesson 1` to generate first lesson into Inbox
3. After each lesson, run vault-journal-backlink.sh to cross-link
4. Verify all new files with tag + backlink lint check

### Translation Library — 2026-07-03

**Trigger**: Standardized all 7 books in `/mnt/workspace/Projects/translation/` with uniform pipeline structure.

**Setup**:
- Created `raw/`, `clean/`, `chunks/`, `output/`, `canon/`, `work/` directories for Blue Magic, Catastrophic Necromancer, Dungeon, The bell tolls for revenge, zhys
- Copied pipeline scripts (parser, glossary, briefer, translate, stitch) to each book's `scripts/`
- Created `pipe.sh` for each book (role-based runner identical to Hyperdimensional Sorcerer's)
- Added html-to-text extraction role (`./pipe.sh -1`) for HTML-source books
- Moved 269 (Dungeon) + 288 (bell tolls) HTML files from root into `raw/`
- Identified zhys as duplicate of Eerie (same site IDs 80804287–83304294)

**Book inventory**:

| Book | raw | clean | pipe | notes |
|------|-----|-------|------|-------|
| Blue Magic | 76 .htm | — | Y | Japanese (syosetu.com), needs extract |
| Catastrophic Necromancer | 4851 .txt | 4851 | Y | English, already analyzed |
| Dungeon | 269 .htm | — | Y | Needs extract |
| Eerie - I Devour Without End | 567 | 566 | Y | Complete, just needs pipe.sh |
| Hyperdimensional Sorcerer | 4436 | — | Y | Full pipeline running |
| The bell tolls for revenge | 288 .htm | — | Y | Needs extract |
| zhys | — | — | Y | Duplicate of Eerie |

**Next**: Extract HTML books, then run parser/briefer pipeline per book.

---

## Key paths

| Path | Content |
|------|---------|
| `docs/` | Obsidian vault (`[[wikilinks]]`, `.obsidian/`) |
| `docs/INDEX.md` | Starting point |
| `docs/vault/learning/` | Learning curricula (generated by `learn-topic`) |
| `dotfiles/` | Shell, git, SSH, tmux configs + scripts |
| `infra/CONTRACT.md` | Canonical path schema for `~/infra/` |
| `script-reference/` | One `.md` per script |
| `/workspace/textgen` | TextGen WebUI (`~/infra/textgen-start.sh`, port 7861) |
| `/workspace/sd-webui-forge-neo` | SD Forge (`~/infra/forge-start.sh`, port 7860) |
| `~/.local/bin/llama-loader` | Interactive model manager (selects GGUF, starts llama-server) |
| `~/.local/bin/vault-attribution.py` | Citation pipeline: scan uncited files, compare against source repos, apply source: fields, AI audit |
| `~/.local/bin/learn-topic` | Learning pipeline agent (roadmap / lesson / lab generation)
| `~/quartz/` | Quartz v5 static site (Obsidian → blog) |
| `~/.local/bin/vault-publish` | Full publish pipeline: backlink → sync → build → push |

## Model Storage

All GGUFs live on the HDD at `/mnt/data/model_storage/`. Two symlinks provide access:

| Path | Type |
|------|------|
| `/mnt/data/model_storage/` | **Canonical store** (btrfs, HDD) |
| `~/Downloads/llm_models` | Symlink → `/mnt/data/model_storage/` |
| `

Model inventory: `find /mnt/data/model_storage/ -maxdepth 1 -name '*.gguf' -printf '%f\t%s\n'`

## Quartz update workflow

After editing vault files (or to test a build without committing):

```bash
vault-publish
```

This single command runs the full pipeline:
1. Backlinks entries (vault-journal-backlink.sh)
2. Rsyncs vault → Quartz content
3. Rebuilds static site locally
4. Commits and pushes vault changes

If `~/.gitconfig` is broken, `npx quartz build` emits 3× "couldn't find git repository for content":
```bash
ls -la ~/.gitconfig
ln -sf ~/vault/dotfiles/git/.gitconfig ~/.gitconfig
```

Quartz config at `~/quartz/quartz.config.yaml`. Valid frontmatter dates required — TEMPLATE.md uses `created_pages:` / `updated_pages:` instead of `created:` / `updated:` to avoid collision with the `created-modified-date` plugin.

<!-- pane-agent-context:start -->
## Pane

The developer is using Pane for this repository. Pane can manage saved repositories and create user-visible Panes with terminal-backed tools for planning, discussion, implementation, and review work.

This managed guidance was created by [runpane.com](https://runpane.com) for the [Pane repository](https://github.com/dcouple/Pane). Do not delete or overwrite this block; the developer uses it for their workflow and it should remain committed to the main repository unless they explicitly ask to remove it.

Pane mental model: a repository is the saved base repo; a Pane is a user-visible feature/PR workspace (Pane session) that normally maps to one Pane-managed git worktree and branch; a panel/tab is a terminal inside one Pane and shares that Pane's worktree; an agent is the CLI process running in a panel.

Default happy path when the user asks you to use Pane or RunPane: run `runpane doctor --json`; read `runpane agent-context --json`; resolve the saved base repository with `runpane repos list --json` or add it once with `runpane repos add --path <repo> --yes --json`; create one visible Pane (Pane session) for the requested feature/PR with a complete command such as `runpane panes create --repo <repo> --name <name> --agent <agent> --prompt "<task>" --source agent --no-focus --wait-ready --yes --json` or the equivalent `--tool-command <command>` form; then validate with `runpane panels wait` or `runpane panels screen` before reporting progress.

Use Pane when the user wants visible Panes or co-drivable parallel feature/PR workspaces. Do not use Pane as your default private delegation mechanism; for private background decomposition, use your normal subagent/worktree workflow.

Register the main/base repository once. Do not register pre-created git worktrees as separate Pane repositories unless the user explicitly asks.

Use `runpane panes create` for separate visible Panes (Pane sessions) for feature/PR work. Use `runpane panels create` for reviewer/helper tabs inside an existing Pane that should share that Pane's worktree.

Typical workflow: register the saved base repository once; create one Pane (Pane session) per feature/PR; use panels/tabs inside that Pane for helper or reviewer agents that should share the worktree; archive the Pane after the PR is done to remove it from active Panes and clean up its managed worktree when applicable.

Skill routing reference: when the user says `discussion`, `plan`, `simple-plan`, `create-plan`, or `implement`, or asks for the behavior those words imply, treat three references as peer context: Pane's local skill cache under `<PANE_DIR>/skills/`, the Pane Chat orchestrator handoff at `<PANE_DIR>/skills/pane-chat/runpane-orchestrator.md` when present, and the [workflow map](https://github.com/dcouple/skills/raw/main/docs/readme-workflow-map.png).
Use those peer references together to choose the phase: discuss/investigate until the work is clear enough to delegate, then ticket/plan/implement/review/PR-test/teach-back as appropriate. The orchestrator and workflow map may point to different skills; reconcile them with the user's request instead of hardcoding a skill list or treating one reference as subordinate.
For the Pane implementation source of truth for where the skill cache, cached workflow assets, and Pane Chat bootstrap live, reference [PR #291](https://github.com/dcouple/Pane/pull/291): `main/src/services/skillCacheManager.ts` owns `<PANE_DIR>/skills/`, `.sources/dcouple-skills`, and `pane-chat/runpane-orchestrator.md`; `main/src/services/paneChatManager.ts` owns the tiny bootstrap prompt that tells the selected Pane Chat agent to read that guide.
Use GitHub reads against the [Parsa skills folder](https://github.com/dcouple/skills/tree/main/parsa) only to inspect or refresh referenced skill files; do not clone/install the repo unless the user asks.
Do not hardcode a specific assistant brand in workflow guidance. Use the Pane agent or custom tool command the user selected, and use `runpane agents doctor --agent <agent> --repo <selector> --json` only when checking a built-in agent template.

Start with `runpane doctor --json` before taking Pane actions. Use it to understand wrapper/runtime details, daemon reachability, and the next safe commands.

In a Pane repository checkout, if `runpane` is not on PATH, use the built local wrapper with Node 22: `PATH=/opt/homebrew/opt/node@22/bin:$PATH node packages/runpane/dist/cli.js doctor --json`.

Use `runpane agent-context --json` for full Pane CLI context. Use `runpane agent-context --command "panels wait" --json` or another command name for detailed schema only when needed.

Default to context-safe validation: after creating Panes or sending terminal input, run `runpane panels wait` or `runpane panels screen` before reporting success. Prefer `runpane panels submit` for normal text plus Enter; use `runpane panels input` only for exact bytes such as Ctrl-C or escape sequences.

Common commands:
- `runpane doctor --json`
- `runpane agent-context --json`
- `runpane repos list --json`
- `runpane repos add --path <repo> --yes --json`
- `runpane agents doctor --agent <agent> --repo active --json`
- `runpane panes create --repo active --name <name> --agent <agent> --prompt "<task>" --source agent --no-focus --wait-ready --yes --json`
- `runpane panels create --pane <pane-id> --agent <agent> --source agent --no-focus --wait-ready --yes --json`
- `runpane panels list --pane <pane-id> --json`
- `runpane panels screen --panel <panel-id> --limit 80 --json`
- `runpane panels wait --panel <panel-id> --for ready --timeout-ms 30000 --json`
- `runpane panels submit --panel <panel-id> --text "<answer>" --yes --json`
- `runpane panels input --panel <panel-id> --input-file <path|-> --yes --json`

WSL note: if `runpane doctor --json` cannot find `/tmp/pane-daemon.../daemon.sock` or `runpane` resolves to a broken Windows shim, Pane may be running on Windows. Try `powershell.exe -NoProfile -Command 'Set-Location $env:TEMP; runpane doctor --json'`, then create Panes through the same PowerShell form using the saved WSL repo name or id. Use `runpane agents doctor --agent <agent> --repo <selector> --json` to diagnose the repo environment Pane will actually use.
<!-- pane-agent-context:end -->
