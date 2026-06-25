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

## Conventions

- All infra scripts deploy to `~/infra/` root (no subdirectory grouping per `infra/CONTRACT.md`)
- All docs use Obsidian `[[wikilinks]]` for cross-references
- Installation docs must be full commands with flags + annotations + source URLs — goal: clean reinstall recoverable from this repo alone
- Model inventory: `find ~/Downloads/llm_models/ -name '*.gguf' -printf '%f\t%s\n'` (filenames drift)
- Git user: `InnerTic` / `innertic@users.noreply.github.com`
