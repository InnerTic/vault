#!/usr/bin/env bash
# dotfiles-sync.sh — Vault → dotfiles one-way mirror sync
#
# Source of truth:   ~/vault/dotfiles/
# Mirror targets:    ~/dotfiles/ (user env)
#                    ~/infra/    (automation scripts, subtree of vault/dotfiles/scripts/)
#
# Usage:
#   ./dotfiles-sync.sh           # Dry run (show what would change)
#   ./dotfiles-sync.sh --apply   # Actually sync
#   ./dotfiles-sync.sh --status  # Show diff status only

set -euo pipefail

VAULT_SRC="$HOME/vault/dotfiles"
DOTFILES_MIRROR="$HOME/dotfiles"
INFRA_MIRROR="$HOME/infra"
RSYNC_OPTS="-av --delete --exclude=.git"

dry_run=true
case "${1:-}" in
  --apply) dry_run=false ;;
  --status) rsync -ah --dry-run --delete --exclude=.git "$VAULT_SRC/" "$DOTFILES_MIRROR/" 2>/dev/null | grep -v '/$' | head -20; exit 0 ;;
esac

echo "=== dotfiles mirror ==="
echo "Source: $VAULT_SRC"
echo "Target: $DOTFILES_MIRROR"
echo

if $dry_run; then
  echo "[DRY RUN] Would sync:"
  rsync $RSYNC_OPTS --dry-run "$VAULT_SRC/" "$DOTFILES_MIRROR/" 2>/dev/null | grep -v '/$'
  echo
  echo "Run with --apply to execute."
else
  echo "Syncing dotfiles mirror..."
  rsync $RSYNC_OPTS "$VAULT_SRC/" "$DOTFILES_MIRROR/"
  echo "Done."
fi

# infra mirror is a subset — just scripts/
echo
echo "=== infra mirror (scripts only) ==="
echo "Source: $VAULT_SRC/scripts"
echo "Target: $INFRA_MIRROR"

if $dry_run; then
  echo "[DRY RUN] Would sync:"
  rsync $RSYNC_OPTS --dry-run "$VAULT_SRC/scripts/" "$INFRA_MIRROR/" 2>/dev/null | grep -v '/$'
  echo
  echo "Run with --apply to execute."
else
  echo "Syncing infra mirror..."
  rsync $RSYNC_OPTS "$VAULT_SRC/scripts/" "$INFRA_MIRROR/"
  echo "Done."
fi
