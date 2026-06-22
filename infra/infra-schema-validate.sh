#!/usr/bin/env bash
# infra-schema-validate.sh — Validate docs against INFRA PATH CONTRACT
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
VAULT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONTRACT="$VAULT_ROOT/infra/CONTRACT.md"
DOCS_DIR="$VAULT_ROOT/docs"

CANONICAL_PATHS=$(sed -n '/^## Path set/,/^##/p' "$CONTRACT" | grep -v '^##' | grep -v '^$' | grep -v '^```' | sed 's/^ *//')

violations=0
declare -a violations_list

scan_refs() {
  local file="$1"
  local line="$2"
  local content="$3"
  local prefix="$4"

  # Extract path after prefix
  local rest="${content#*$prefix}"
  # Take first word after (path chars only)
  local ref=""
  ref=$(echo "$rest" | sed 's/^\/\///' | sed 's/^\([a-zA-Z0-9_\/.-]*\).*/\1/')
  
  if [ -n "$ref" ]; then
    if ! echo "$CANONICAL_PATHS" | grep -Fxq "$ref"; then
      echo "  VIOLATION: $file:$line"
      echo "    Path: ${prefix}$ref"
      echo "    NOT IN CONTRACT"
      violations=$((violations + 1))
    fi
  fi
}

echo "=== INFRA SCHEMA VALIDATOR ==="
echo "Contract: $CONTRACT"
echo "Canonical paths: $(echo "$CANONICAL_PATHS" | wc -l)"
echo

# Scan for ~/infra/ patterns
while IFS=: read -r file line content; do
  if echo "$content" | grep -q '~/infra/'; then
    scan_refs "$file" "$line" "$content" '~/infra/'
  fi
done < <(grep -rn '~/infra/' "$DOCS_DIR" 2>/dev/null | grep -v '/migration/' | grep -v 'vault-system-audit')

# Scan for /home/ken/infra/
while IFS=: read -r file line content; do
  if echo "$content" | grep -q '/home/ken/infra/'; then
    scan_refs "$file" "$line" "$content" '/home/ken/infra/'
  fi
done < <(grep -rn '/home/ken/infra/' "$DOCS_DIR" 2>/dev/null | grep -v '/migration/' | grep -v 'vault-system-audit')

echo
if [ "$violations" -eq 0 ]; then
  echo "PASS: All infra references conform to contract."
else
  echo "FAIL: $violations infra path violations found."
fi
exit $violations
