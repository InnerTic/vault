---
source: dotfiles/scripts/llama-loader/core/dialects/llama.cpp.sh
restorable: true
checksum: faaa8a71b33ade174dce53517d713926d43a1b32ce12e4b4d416e7257f5dda7c
last_verified: 2026-06-21
tags:
  - llama-loader
modified: 2026-06-26
  - core
  - dialects
  - llama.cpp
---

# llama.cpp.sh

```bash
#!/usr/bin/env bash
# ============================================================
# LLAMA-LOADER DIALECT  —  llama.cpp
# IR → CLI compiler.
#
# Reads IR from environment (set by mode scripts).
# Outputs a quoted argv string safe for eval.
# ============================================================

compile_cli() {
  local ARGS=()

  # model path
  ARGS+=(-m "$MODEL_PATH")

  # context size
  ARGS+=(-c "$CTX_SIZE")

  # GPU layers
  ARGS+=(-ngl "$NGL")

  # parallel slots
  ARGS+=(-np "$NP_VAL")

  # tensor split (dual-GPU only)
  if [[ -n "$TENSOR_SPLIT" ]]; then
    ARGS+=(--tensor-split "$TENSOR_SPLIT")
  fi

  # primary GPU index
  ARGS+=(--main-gpu "$MAIN_GPU")

  # host binding
  ARGS+=(--host 0.0.0.0)

  # port
  ARGS+=(--port "$PORT")

  # populate global CMD array
  CMD=("$LLAMA_SERVER" "${ARGS[@]}")
}
```

## Restore

```bash
vault-restore llama.cpp
```
