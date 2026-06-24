# IR Schema

**Type:** Reference
**Updated:** 2026-06-21
**Source:** `dotfiles/scripts/llama-loader/lib/common.sh`

The Intermediate Representation (IR) layer sits between mode selection and CLI compilation. It carries pure values only — no flags, no `--` prefixes.

## IR Variables

| Variable | Type | Example | Description |
|----------|------|---------|-------------|
| `MODEL_PATH` | string | `~/models/hermes.q4_K_M.gguf` | Full path to model file |
| `NP_VAL` | int | `1` | Parallel decodes (not `--np 1`) |
| `NGL` | int | `60` | Layers to offload to GPU |
| `CTX_SIZE` | int | `4096` | Context window size |
| `TENSOR_SPLIT` | string | `10,90` | GPU split ratio (comma-separated) |
| `MAIN_GPU` | int | `0` | Primary GPU index |
| `PORT` | int | `8080` | Server port |
| `HOST` | string | `0.0.0.0` | Bind address |

## Flow

```
Mode script         Builder            Dialect compiler
sets IR values  →  enriches IR     →  reads IR, emits CLI
NP_VAL=1            TENSOR_SPLIT       -np 1
CTX_SIZE=4098       computed from       --tensor-split "10,90"
                    GPU memory scan     --main-gpu 0
```

## Contract

- IR values are **never prefixed** with `--` or `-`
- IR values are **never string-concatenated with flags** (no `NP_ARG="--np $NP_VAL"`)
- The dialect compiler is the **sole consumer** of IR values
- All IR values must be numeric or file paths — no embedded CLI syntax

## Enforcement

```bash
assert_ir_clean() {
  local var="$1"
  if [[ "$var" =~ ^-- ]]; then
    echo "FATAL: IR value '$var' looks like a CLI flag"; exit 1
  fi
}
```
