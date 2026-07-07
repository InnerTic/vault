---
title: "2 Agentic"
source: dotfiles/scripts/llama-loader/presets/2-balanced.sh
restorable: true
tags:
  - llama-loader
modified: 2026-07-05
---

# 2-balanced.sh — Agentic Preset

```bash
# ============================================================
# PRESET 2: Agentic — tool calling / long context
# Qwen3.6 35B MoE (3B active), 262K native context
# Best tool-calling model in the stack
# 20/80 split keeps most on P40, 3060 handles 20%
# ============================================================
MODEL="Qwen3.6-35B-A3B-Uncensored-HauhauCS-Aggressive-Q4_K_M.gguf"
CTX_SIZE=262144
TENSOR_SPLIT="20,80"
NGL=99
NP_VAL=1
PORT=8080
```

## Restore

```bash
vault-restore 2-balanced
```
