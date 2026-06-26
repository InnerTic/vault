---
title: "Np Flag Regression"
tags:
  - projects
modified: 2026-06-26
  - llama-loader
  - incidents
  - np-flag-regression
---

# NP Flag Regression

**Date:** 2026-06-21
**Status:** Resolved
**Source:** `modes/last.sh`, `builder/concurrency.sh`, `core/dialects/llama.cpp.sh`

## Symptom

On session restore, llama-server failed with:

```
--np invalid argument
```

## Root Cause

`save_state()` stored CLI syntax instead of IR:

```bash
# BAD: stored CLI syntax
save_state() {
  cat > state <<EOF
NP_ARG="--np $NP_VAL"
GPU_ARG="--main-gpu $MAIN_GPU"
EOF
}
```

On restore, `NP_ARG` was sourced back, then mode/last.sh appended `NP_ARG` to the CLI again, producing `--np --np 1`.

The deeper cause: no distinction between IR values and CLI flags. Multiple scripts (modes, builders, runtime) all assembled their own flag strings with no single source of truth.

## Fix

1. Removed all `NP_ARG`/`GPU_ARG`/`SPLIT_ARG` from mode and builder scripts
2. Dialect compiler `core/dialects/llama.cpp.sh` became sole CLI emitter
3. `save_state()` now stores only IR values (no `--` prefixes)

## Prevention

- `assert_no_cli_leak()` runtime guard detects stray `--np` or `--main-gpu` outside the dialect compiler
- IR schema mandates values-only (no flags, no concatenation)
- Code review: no PR may contain `NP_ARG`, `GPU_ARG`, or `SPLIT_ARG` outside `core/dialects/`

## Related

- [[ir-schema]]
- [[compiler-authority]]
