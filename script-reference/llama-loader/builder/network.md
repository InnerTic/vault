---
source: dotfiles/scripts/llama-loader/builder/network.sh
restorable: true
checksum: 623e74345596310db1f81ac5b0712c77c9019ca421dd3699e01c739762a97eac
last_verified: 2026-06-21
tags:
  - llama-loader
modified: 2026-06-26
  - builder
  - network
---

# network.sh

```bash
# ============================================================
# BUILDER: Network
# Prompts for server port.
# ============================================================
LAST_PORT=$(resolve_default "port" "8080")
echo
read -p "Port [${LAST_PORT}]: " PORT_IN
PORT=${PORT_IN:-$LAST_PORT}
```

## Restore

```bash
vault-restore network
```
