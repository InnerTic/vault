---
title: "Execution Planner"
tags:
  - projects
modified: 2026-06-26
  - llama-loader
  - architecture
  - execution-planner
---

# Execution Planner

**Type:** Architecture
**Updated:** 2026-06-21
**Source:** `dotfiles/scripts/llama-loader/core/run.sh`, `builder/`, `preset-router.sh`

The execution planner is the orchestration layer that translates user intent into a running llama-server process.

## Flow

```
llama-loader.sh
  ↓ user selects mode + preset
preset-router.sh
  ↓ loads preset variables
builder/*.sh
  ↓ enriches IR (GPU split calculation, model validation, port allocation)
core/run.sh
  ↓ sources dialect compiler → builds CLI → execs llama-server
```

## Components

### Preset Router (`modes/preset-router.sh`)

Loads preset files from `presets/`. Presets define baseline IR values:

```bash
# presets/2-balanced.sh
NGL=60
CTX_SIZE=32768
NP_VAL=1
TENSOR_SPLIT="10,90"
```

### Builder Layer (`builder/*.sh`)

Each builder handles one dimension:

| Builder | Responsibility |
|---------|---------------|
| `gpu.sh` | Calculates `TENSOR_SPLIT` from VRAM, validates model fits |
| `context.sh` | Adjusts `CTX_SIZE` based on available memory |
| `concurrency.sh` | Sets `NP_VAL` based on model size |
| `network.sh` | Port availability check, port allocation |

### Runtime (`core/run.sh`)

1. Sources the selected dialect compiler
2. Calls `compile_cli()` to produce CLI args
3. Validates model path exists
4. Runs `ulimit` adjustments
5. Executes `llama-server` with `exec` (replaces shell process)

## State

`~/.config/llama-loader/` persists IR values across sessions:

```bash
load_state() {
  local state_file="$CONFIG_DIR/$CURRENT_MODE.state"
  [[ -f "$state_file" ]] && source "$state_file"
}
save_state() {
  cat > "$CONFIG_DIR/$CURRENT_MODE.state" <<EOF
MODEL_PATH="$MODEL_PATH"
NP_VAL=$NP_VAL
CTX_SIZE=$CTX_SIZE
EOF
}
```

## Evolution

| Date | Change |
|------|--------|
| 2026-06-21 | Initial architecture. Mode scripts set IR, builder enriches, dialect compiles. `save_state()` stores IR only (no CLI). |
