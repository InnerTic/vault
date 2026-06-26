---
source: dotfiles/scripts/forge-start.sh
restorable: true
checksum: f366210e38725441995f7d1b896ca6ae43ef3ca0d277150ed11856e687fb8fa8
last_verified: 2026-06-21
tags:
  - forge-start
---

# forge-start.sh

```bash
#!/bin/bash
# Debian — Start SD WebUI Forge Neo
VENV_PYTHON="/mnt/workspace/sd-webui-forge-neo/venv/bin/python3"
cd /mnt/workspace/sd-webui-forge-neo
exec "$VENV_PYTHON" launch.py --listen --port 7860 --theme dark --skip-python-version-check --enable-insecure-extension-access --medvram "$@"
```

## Restore

```bash
vault-restore forge-start
```
