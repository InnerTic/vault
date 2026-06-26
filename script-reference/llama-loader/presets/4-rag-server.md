---
title: "4 Rag Server"
source: dotfiles/scripts/llama-loader/presets/4-rag-server.sh
restorable: true
checksum: 4bb6b298ff1b4e3cabee5eb69ffb669ea602c84a8039a1081239ed1939dc5ca8
last_verified: 2026-06-21
tags:
  - llama-loader
modified: 2026-06-26
---

# 4-rag-server.sh

```bash
# ============================================================
# PRESET 4: RAG Server
# Dedicated embedding/reranking host — batch-friendly.
# ============================================================
CTX_SIZE=16384
TENSOR_SPLIT="25,75"
NGL=60
NP_VAL=4
PORT=8080
```

## Restore

```bash
vault-restore 4-rag-server
```
