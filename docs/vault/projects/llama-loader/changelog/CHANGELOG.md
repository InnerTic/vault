---
title: "CHANGELOG"
tags:
  - projects
---

# llama-loader Changelog

**Source:** `dotfiles/scripts/llama-loader/`

## 2026-06-21 — IR/Dialect Separation

**Breaking:** All `NP_ARG`/`GPU_ARG`/`SPLIT_ARG` removed from mode and builder scripts.

- Dialect compiler `core/dialects/llama.cpp.sh` wired into `run.sh` as sole CLI authority
- `run.sh` no longer assembles inline flags
- `save_state()` stores IR values only
- Display strings corrected (`--np` → `-np`, `--split` → `--tensor-split`)
- `assert_no_cli_leak()` guard added

## 2026-06-19 — Modular Restructure

- Monolithic `llama-loader.sh` split into modular architecture
- Introduced mode/preset/builder separation
- Added GPU selector, persistent state per mode
- Source: `dotfiles/scripts/llama-loader/`
