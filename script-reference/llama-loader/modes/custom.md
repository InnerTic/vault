---
title: "Custom"
source: dotfiles/scripts/llama-loader/modes/custom.sh
restorable: true
checksum: 09df9c73a5202f118587b54e71803804d222531f1c3a9a9f5208ba3e028f780f
last_verified: 2026-06-21
tags:
  - llama-loader
modified: 2026-06-26
---

# custom.sh

```bash
#!/usr/bin/env bash
# ============================================================
# MODE: Custom
# Interactive builder pipeline — prompts for every domain.
# Runs introspection after config is resolved.
# ============================================================
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

ensure_state_dirs

assert_clean_state

list_models
select_model

# Run builder modules (each sources into current shell)
source "$SCRIPT_DIR/builder/context.sh"
source "$SCRIPT_DIR/builder/gpu.sh"
source "$SCRIPT_DIR/builder/concurrency.sh"
source "$SCRIPT_DIR/builder/network.sh"

# Introspection
source "$SCRIPT_DIR/introspect/evaluate.sh"

show_snapshot "CUSTOM"
decision_gate

source "$SCRIPT_DIR/core/run.sh"
```

## Restore

```bash
vault-restore custom
```
