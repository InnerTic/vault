---
source: dotfiles/scripts/textgen-start.sh
restorable: true
checksum: d4b7a6092fd944b439488f2806bc2910637dec6e8b51f27ee4ed2a24be360ca5
last_verified: 2026-06-21
---

# textgen-start.sh

```bash
#!/bin/bash
# Start TextGen WebUI (oobabooga)
cd /mnt/workspace/textgen
exec ./venv/bin/python server.py --listen --listen-port 7861 --api "$@"
```

## Restore

```bash
vault-restore textgen-start
```
