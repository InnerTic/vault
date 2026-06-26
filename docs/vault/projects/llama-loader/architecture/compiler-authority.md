---
title: "Compiler Authority"
tags:
  - projects
---

# Compiler Authority

**Type:** Architecture
**Updated:** 2026-06-21
**Source:** `dotfiles/scripts/llama-loader/core/dialects/llama.cpp.sh`

Enforce single-authority CLI generation: only `core/dialects/llama.cpp.sh` produces CLI flags. Everything else is IR or state.

## Pipeline

```
modes/*
   ↓ (IR only — pure values)
builder/*
   ↓ (enriched IR)
core/dialects/llama.cpp.sh    ← ONLY CLI AUTHORITY
   ↓
core/run.sh
   ↓
llama-server
```

## Why

Before this contract, multiple scripts emitted their own CLI flags:

- `modes/last.sh` and `modes/factory.sh` both had `NP_ARG="--np $NP_VAL"` and `GPU_ARG="--main-gpu $MAIN_GPU"`
- `builder/concurrency.sh` had its own `SPLIT_ARG="--tensor-split $TENSOR_SPLIT"`
- Each used different flag names (`--np` vs `-np`, `--split` vs `--tensor-split`)
- Result: `--np invalid argument` errors, GPU assignment drift, ABI breaks on llama.cpp updates

## Contract

`core/dialects/llama.cpp.sh` is the sole CLI emitter:

```bash
compile_cli() {
  local MODEL="$MODEL_PATH" CTX="$CTX" NGL="$NGL"
  local NP="$NP" SPLIT="$TENSOR_SPLIT"
  local MAIN_GPU="$MAIN_GPU" PORT="$PORT"
  ARGS=()
  ARGS+=(-m "$MODEL")   ARGS+=(-c "$CTX")   ARGS+=(-ngl "$NGL")
  [[ -n "$NP" ]]    && ARGS+=(-np "$NP")
  [[ -n "$SPLIT" ]] && ARGS+=(--tensor-split "$SPLIT")
  ARGS+=(--main-gpu "$MAIN_GPU")
  ARGS+=(--host 0.0.0.0)   ARGS+=(--port "$PORT")
}
```

## Rules

- **NO** `NP_ARG="--np $NP"` or `GPU_ARG="--main-gpu 0"` in any mode/builder script
- Mode scripts export only IR values: `NP=1 NGL=60 CTX=32768 TENSOR_SPLIT="10,90" MAIN_GPU=0 PORT=8080 MODEL_PATH="..."`
- `assert_no_cli_leak()` runtime guard scans modes/builders for CLI syntax

## Enforcement

```bash
assert_no_cli_leak() {
  local leaks
  leaks=$(grep -R -- "--np\|-np\|--main-gpu\|--tensor-split" ../modes ../builder 2>/dev/null || true)
  if [[ -n "$leaks" ]]; then echo "FATAL: CLI leakage"; echo "$leaks"; exit 1; fi
}
```

## Evolution

| Date | Change |
|------|--------|
| 2026-06-21 | Initial contract established. `NP_ARG`/`GPU_ARG`/`SPLIT_ARG` removed from all mode/builder scripts. Dialect compiler wired into `run.sh`. |
