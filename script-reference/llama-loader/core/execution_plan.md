---
source: dotfiles/scripts/llama-loader/core/execution_plan.sh
restorable: true
checksum: aecf3ba8af41dcaac7c4ce8005cb3799f149acf8af639f04c73a3fe29ceeecd6
last_verified: 2026-06-21
---

# execution_plan.sh

```bash
#!/usr/bin/env bash
# ============================================================
# LLAMA-LOADER IR  —  Intermediate Representation
# PURE VALUES ONLY.  NO CLI FLAGS.  EVER.
#
# This file is sourced by mode scripts to establish the
# canonical IR contract.  Mode scripts may override any value.
#
# RULE:  --np / -np / --flag of any kind  NEVER appears here.
#        Only variable names and raw values.
# ============================================================
# IR contract (all optional — defaults below):
NP_VAL="${NP_VAL:-1}"
NGL="${NGL:-60}"
CTX_SIZE="${CTX_SIZE:-32768}"
TENSOR_SPLIT="${TENSOR_SPLIT:-}"
MAIN_GPU="${MAIN_GPU:-0}"
PORT="${PORT:-8080}"
MODEL_PATH="${MODEL_PATH:-}"
NP_MODE="${NP_MODE:-manual}"
GPU_MODE_LABEL="${GPU_MODE_LABEL:-}"
```

## Restore

```bash
vault-restore execution_plan
```
