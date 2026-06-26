---
title: "Llama Loader Overview"
tags:
  - projects
modified: 2026-06-26
---

# llama-loader Knowledge Base

**Status:** Active
**Updated:** 2026-06-21

llama-loader is a modular launch system for llama.cpp `llama-server`. It enforces a strict IR → dialect → CLI pipeline and provides preset management, GPU selection, and persistent state.

## Structure

```
architecture/          — design decisions, contracts, schemas
  compiler-authority.md   single CLI emission point
  ir-schema.md            IR values contract
  execution-planner.md    mode → IR → compiler flow

changelog/              — version history, breaking changes
  CHANGELOG.md

incidents/              — bugs, regressions, root cause analyses
  np-flag-regression.md
  tensor-split-migration.md

snapshots/              — timestamped contextual captures of key files
  2026-06-21-llama.cpp.sh.md
```

## Source of Truth

Live code lives in `dotfiles/scripts/llama-loader/`. This tree captures *why* it works the way it does.

## Related

- [[llama-loader-compiler-contract]] (original project doc, superseded by this tree)

## Archive

- `archive/compiler-contract-implementation-plan.md` — raw implementation plan for single-authority CLI generation
