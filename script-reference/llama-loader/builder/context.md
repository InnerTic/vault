---
source: dotfiles/scripts/llama-loader/builder/context.sh
restorable: true
checksum: 5817147783820c74843a89418adc8be18e0ae015b00a6a29d38db83ed0d38c20
last_verified: 2026-06-21
tags:
  - llama-loader
modified: 2026-06-26
  - builder
  - context
---

# context.sh

```bash
# ============================================================
# BUILDER: Context
# Prompts for context size with recommendations.
# ============================================================
echo
echo "Context size options:"
echo "  1) Model max (recommended)"
echo "  2) Standard (32768)"
echo "  3) Long context (131072)"
echo "  4) Custom"

LAST_CTX=$(resolve_default "ctx" "65536")
read -p "Select context [1-4, default: $LAST_CTX]: " CTX_CHOICE

case "$CTX_CHOICE" in
  1) CTX_SIZE=65536 ;;
  2) CTX_SIZE=32768 ;;
  3) CTX_SIZE=131072 ;;
  4) read -p "Enter context size: " CTX_SIZE ;;
  *) CTX_SIZE=$LAST_CTX ;;
esac
```

## Restore

```bash
vault-restore context
```
