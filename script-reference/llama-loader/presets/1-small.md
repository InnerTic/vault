---
source: dotfiles/scripts/llama-loader/presets/1-small.sh
restorable: true
checksum: ebb59630b285f8fc7c9a23a5b86476ea4175be118514acef977bcc408279cecb
last_verified: 2026-06-21
tags:
  - llama-loader
modified: 2026-06-26
  - presets
  - 1-small
---

# 1-small.sh

```bash
# ============================================================
# PRESET 1: Small / Fast
# Lightweight inference — low VRAM, fast response.
# ============================================================
CTX_SIZE=8192
TENSOR_SPLIT="30,70"
NGL=30
NP_VAL=1
PORT=8080
```

## Restore

```bash
vault-restore 1-small
```
