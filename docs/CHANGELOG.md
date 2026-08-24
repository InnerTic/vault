---
title: "CHANGELOG"
tags:
  - changelog
modified: 2026-07-17
---

# Changelog (Curated)

## Changelog Policy

- Newest first.
- Recent entries are detailed.
- Older entries are condensed.
- Breaking architectural shifts are marked as milestones.
- Detailed implementation notes belong in Raw Changelog.

## 2026-08-24

- **GW2 loader launch fixed after KDE regression**: KIO ≥6.28 (CachyOS update 2026-08-23) executes
  `.exe` files with +x directly instead of honoring the protontricks MIME association, breaking the
  desktop-symlink workflow. Fix: `chmod -x` on the loader target. New note
  `software/gaming/gw2-loader-symlink-fix.md`; [[workarounds]] updated. Upstream: no KDE bug report;
  loader repo has related-but-different panic reports (#20, #47).

## 2026-07-17

milestone:
    CachyOS system restore — keyd Caps→Hyper→F24 finally working, fstab fixed

- fix(keyd): Caps→Hyper→F24 pipeline now working on KDE Wayland. Root cause: dual-interface gaming keyboard — Caps Lock only on `258a:010c:3d952825` (input0). `[ids] *` matched both interfaces, causing silent layer conflict. Fixed by matching only the Caps-emitting device ID and using `overload(hyper, noop)` instead of bare `layer(hyper)`.
- fix(fstab): `/mnt/data` UUID updated (`7E303CAF...` → `f0b1d710-...`, ntfs-3g → btrfs). `/mnt/vm-disks` UUID updated (`446695a8...` → `58f7f216-...`, partition sde3→sde4). Both were auto-mounted at `/run/media/ken/*` before fix.
- feat(system): Installed keyd + yakuake via pacman. Yakuake shortcut bound to `Ctrl+Space,F12,F24`. Caps→Hyper→F24→Yakuake pipeline complete.
- docs(vault): Rewrote keyd-stack.md (device-id probe script, working config, Akuma reference). Rewrote keyd-kde-wayland-f24.md (resolution section, debug mantra). Rewrote drives-and-mounts.md (CachyOS layout, fstab fix log, preserved Debian layout).
- system: Added ken to `input` group, udev rule `/etc/udev/rules.d/99-keyd.rules`, XKB `caps:none` in `~/.config/kxkbrc`.

## 2026-06-26

- docs(vault): add research topic — RAG + YaRN context blowup (260k → 1M+)
- docs(vault): add `modified:` dates to all 240 vault files, fix empty tags in CHANGELOG/INDEX
- infra(dotfiles): sync `.gitignore` + auto-push after rsync
- fix(quartz): rebuild with frontmatter dates — explorer + dates now correct

## 2026-06-19

milestone:
    modular architecture transition — flat script → layered pipeline with modes, state system, GPU config

- fix(core): `NP_ARG` double-prefix (`-np -np 1`) — strip flag before save, prepend on load
- fix(state): `gpu_mode` never persisted to state — added to profile + global state
- fix(mode): `last.sh` redundant `GPU_ARG` removed, GPU_MODE now loaded from state
- refactor(cli): symlink reorg — `llm` → `llama-loader.old`, `test-llm` → modular entry
- feat(shell): fish completions for `llm` and `test-llm` (port suggestions)
- docs(vault): purge CUDA 12.4/gcc9 from Arch context, split llama-setup per-distro
- docs(vault): add yakuake-keyd-f24, vlm-research, kvm-bridge-networking

## 2026-06-18

- docs(vault): dual-boot recovery, keyboard input reference
- docs(agents): trim Arch-specific refs, flatten docs table
- fix(docs): correct sde partition layout across all docs — sde1=EFI, sde2=MX root, sde3=VM-Disks
- fix(fstab): update REBUILD_SCRIPT.sh fstab block for sde3 xfs UUID

## 2026-06-17

- docs(agents): model inventory, vault conventions, GPU formula
- docs(infra): SearXNG MCP server setup

## 2026-06-16

milestone:
    planning and design phase — pipeline spec, roadmap, JSON orchestration

- feat(infra): SearXNG install + docs
- feat(planning): pipeline spec, roadmap, JSON orchestration
- cleanup(vault): model-index formatting, validation gates

## 2026-06-19

- docs: add CachyOS/Arch libvirt bridge setup (nmcli, bridge-slave, DHCP fixes) to kvm-bridge-networking
- scripts: add vm-bridge-setup.sh + vm-bridge-setup.fish (zero-touch br0 bootstrap)
- project: add meta-scripts project doc (archived 2026-06-26, reverted) — modular script orchestrator blueprint

## 2026-06-15

milestone:
    vault foundational restructure — sections, pipeline docs, model index

- refactor(vault): restructure flat docs into sections
- docs(vault): add translation-pipeline, forge, prompt enhancer projects
