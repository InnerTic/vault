---
source: dotfiles/scripts/llama-loader/builder/concurrency.sh
restorable: true
checksum: 40a616cb255348d4937f569232e351ee8b03eb813be26679938c859112408518
last_verified: 2026-06-21
tags:
  - llama-loader
---

# concurrency.sh

```bash
# ============================================================
# BUILDER: Concurrency
# Prompts for NP (parallel sequences) and NGL (GPU layers).
# ============================================================
LAST_NP=$(resolve_np)
echo
read -p "Parallel sequences [-np ${LAST_NP}]: " NP_IN
case "${NP_IN:-$LAST_NP}" in
  a|A|auto)
    NP_MODE="auto"
    NP_VAL="auto"
    ;;
  [2-8])
    NP_MODE="manual"
    NP_VAL="${NP_IN:-$LAST_NP}"
    validate_int "$NP_VAL" >/dev/null
    ;;
  *)
    NP_MODE="manual"
    NP_VAL="${NP_IN:-$LAST_NP}"
    validate_int "$NP_VAL" >/dev/null 2>&1 || NP_VAL="$LAST_NP"
    ;;
esac

# auto is runtime-only — resolve_np returns fallback integer on next load

LAST_NGL=$(resolve_default "ngl" "60")
echo
read -p "GPU layers [-ngl ${LAST_NGL}]: " NGL_IN
NGL=${NGL_IN:-$LAST_NGL}
```

## Restore

```bash
vault-restore concurrency
```
