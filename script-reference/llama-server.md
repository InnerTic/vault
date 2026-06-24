---
source: dotfiles/scripts/llama-server.sh
restorable: true
checksum: 4d1cba4035f49632e6c2da69235cc1e7ec6af44c877321faec4a20bd8c95e7e6
last_verified: 2026-06-21
---

# llama-server.sh

```bash
#!/bin/bash
# Debian — uses local CUDA build (supports sm_61 + sm_86, both GPUs)
# textgen-bundled binary only supports sm_75+ (no Pascal/P40)
LLAMA_BIN="/mnt/workspace/llama.cpp/build/bin"
export LD_LIBRARY_PATH="$LLAMA_BIN:$LD_LIBRARY_PATH"
exec "$LLAMA_BIN/llama-server" "$@"
```

## Restore

```bash
vault-restore llama-server
```
