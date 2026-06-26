---
source: dotfiles/scripts/toggle-gpu-profile.sh
restorable: true
checksum: adc732064976fe6d91bd06cbc8b5aecd104aebefe3b3baa275865ece6316151f
last_verified: 2026-06-21
tags:
  - toggle-gpu-profile
modified: 2026-06-26
---

# toggle-gpu-profile.sh

```bash
#!/bin/bash
# Quick toggle between Steam and AI GPU modes.
# Detects current mode from kernel cmdline and switches to the opposite.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOGGLE="$SCRIPT_DIR/toggle-p40.sh"

if grep -q "vfio" /proc/cmdline; then
  echo "Currently in AI mode (VFIO). Switching to Steam (DPM)..."
  exec sudo "$TOGGLE" dpm
else
  echo "Currently in Steam mode. Switching to AI (VFIO)..."
  exec sudo "$TOGGLE" vfio
fi
```

## Restore

```bash
vault-restore toggle-gpu-profile
```
