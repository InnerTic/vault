---
title: "Healthcheck"
source: dotfiles/scripts/healthcheck.sh
restorable: true
checksum: 476a3ae36b7034f128e78d15d86169236c259f0983f655c143927e3026d45685
last_verified: 2026-06-21
tags:
  - healthcheck
modified: 2026-06-26
---

# healthcheck.sh

```bash
#!/bin/bash
# Debian — replaced pacman -Q with dpkg -l
set -euo pipefail

echo "=== Shell ==="
echo "SHELL=$SHELL"
echo "Running: $(ps -p $$ -o comm=)"

echo
echo "=== NVIDIA ==="
nvidia-smi

echo
echo "=== Session ==="
echo "$XDG_SESSION_TYPE"

echo
echo "=== NVIDIA packages ==="
dpkg -l | grep nvidia || echo "(none)"

echo
echo "=== libinput ==="
dpkg -l libinput 2>/dev/null | awk '/^ii/ {print "libinput " $3}' || echo "libinput not installed"

echo
echo "=== CUDA ==="
command -v nvcc && nvcc --version
```

## Restore

```bash
vault-restore healthcheck
```
