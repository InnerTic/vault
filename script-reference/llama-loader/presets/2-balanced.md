---
source: dotfiles/scripts/llama-loader/presets/2-balanced.sh
restorable: true
checksum: a4b1062a71fbced2b4fa0ea44823aa84a65015e69ea155e412a38f1f3350ddc8
last_verified: 2026-06-21
tags:
  - llama-loader
---

# 2-balanced.sh

```bash
# ============================================================
# PRESET 2: Balanced
# Moderate context, dual-GPU split — general purpose.
# ============================================================
CTX_SIZE=32768
TENSOR_SPLIT="20,80"
NGL=60
NP_VAL=2
PORT=8080
```

## Restore

```bash
vault-restore 2-balanced
```
