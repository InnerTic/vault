---
title: "Tensor Split Migration"
tags:
  - projects
modified: 2026-06-26
  - llama-loader
  - incidents
  - tensor-split-migration
---

# Tensor-Split Migration

**Date:** 2026-06-21
**Status:** Resolved
**Source:** `builder/concurrency.sh`, `builder/gpu.sh`, `core/dialects/llama.cpp.sh`

## Symptom

Multi-GPU tensor splitting silently fell back to single GPU:

```
llama_model_load: using single GPU (GPU 0) for all layers
```

## Root Cause

The old flag `--split` was renamed to `--tensor-split` in llama.cpp build b1-64b38b5, but `run.sh` bypassed the dialect compiler with hardcoded flags:

```bash
# BAD: run.sh had hardcoded buggy flags
ARGS+=(--np "$NP")
ARGS+=(--split "$TENSOR_SPLIT")    # --split is dead, should be --tensor-split
```

The dialect compiler at `core/dialects/llama.cpp.sh` was orphaned (never called) — `run.sh` had its own inline flag assembly with the old syntax.

## Fix

1. Wired `run.sh` → dialect compiler
2. Replaced `--split` with `--tensor-split` in the dialect compiler
3. Removed all inline flag assembly from `run.sh`

## Display String Drift

Display strings also used wrong names:

| Field | Old (wrong) | Correct |
|-------|-------------|---------|
| Parallel | `--np` | `-np` |
| Split | `--split` | `--tensor-split` |

Fixed in `display()` across mode scripts.

## Related

- [[np-flag-regression]]
- [[compiler-authority]]
