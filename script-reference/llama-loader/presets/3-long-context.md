---
title: "3 Long Context"
source: dotfiles/scripts/llama-loader/presets/3-long-context.sh
restorable: true
checksum: 8cf2c9ede8ae7ade92ad273868a032ae360938c3f9ddfeac6f6c88783a9b534e
last_verified: 2026-06-21
tags:
  - llama-loader
modified: 2026-06-26
---

# 3-long-context.sh

```bash
# ============================================================
# PRESET 3: Long Context
# Maximum context size — P40-heavy VRAM allocation.
# ============================================================
CTX_SIZE=131072
TENSOR_SPLIT="10,90"
NGL=99
NP_VAL=1
PORT=8080
```

## Restore

```bash
vault-restore 3-long-context
```
