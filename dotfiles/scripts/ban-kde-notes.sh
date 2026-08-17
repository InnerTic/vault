#!/usr/bin/env bash
# ============================================================
# ban-kde-notes.sh — Remove + permanently ban KDE Sticky Notes
#
# Target: org.kde.plasma.notes plasmoid
#   Config:  ~/.config/plasma*.desktop-appletsrc  (globbed, survives renames)
#   Data:    ~/.local/share/plasma_notes (globbed)
#   Plasmoid: discovered under /usr/share, /usr/lib, /usr/local/share,
#             ~/.local/share (Plasma 5/6 agnostic)
#
# Ban strategy (idempotent, update-safe):
#   1. Strip every org.kde.plasma.notes applet from ALL plasma desktop configs
#   2. Delete notes data dirs (user-level)
#   3. Remove user-local plasmoid copies (survive as long as user exists)
#   4. Neutralize the system plasmoid:
#        file plasmoid (dpkg) -> dpkg-divert (permanent, survives apt upgrades)
#        dir plasmoid         -> move to .disabled (dpkg can't divert dirs)
#        rpm / unknown        -> move to .disabled
#
# Usage:
#   ./ban-kde-notes.sh            # user-level cleanup; auto-sudo for system ban
#   sudo ./ban-kde-notes.sh       # everything, no re-exec
#
# Env overrides:
#   NOTES_PLUGIN=org.kde.plasma.notes   # change plugin id if renamed upstream
# ============================================================
set -euo pipefail

PLUGIN_ID="${NOTES_PLUGIN:-org.kde.plasma.notes}"

say()  { echo "==> $*"; }
warn() { echo "WARN: $*" >&2; }

# Resolve the real user context (we may be plain user, sudo, or direct root)
resolve_user() {
  if [ -n "${REAL_HOME:-}" ]; then
    REAL_USER="${REAL_USER:-$(id -un)}"
    return 0
  fi
  if [ -n "${SUDO_USER:-}" ]; then
    REAL_USER="$SUDO_USER"
  elif [ "${EUID:-$(id -u)}" -eq 0 ]; then
    REAL_USER="${SUDO_USER:-root}"
  else
    REAL_USER="${USER:-$(id -un)}"
  fi
  REAL_HOME=$(getent passwd "$REAL_USER" 2>/dev/null | cut -d: -f6)
  [ -n "$REAL_HOME" ] || REAL_HOME="$HOME"
}

# Candidate roots for plasmoid installs across Plasma 5/6 + distro layouts
PLASMOID_ROOTS=(
  "/usr/share/plasma/plasmoids"
  "/usr/share/plasma6/plasmoids"
  "/usr/lib/plasma/plasmoids"
  "/usr/lib64/plasma/plasmoids"
  "/usr/local/share/plasma/plasmoids"
  "/usr/local/share/plasma6/plasmoids"
)

# --- 1. Strip notes applets from every plasma desktop config ---------------
strip_notes_from_config() {
  local cfg_home glob pattern found=0
  cfg_home="${XDG_CONFIG_HOME:-$REAL_HOME/.config}"
  glob="$cfg_home/plasma*.desktop-appletsrc"

  # Also cover legacy ~/.kde*/share/config layout
  [ -d "$cfg_home" ] || return 0

  local tmp_ids tmp_filter cfg
  tmp_ids=$(mktemp)
  tmp_filter=$(mktemp)

  for cfg in $glob "$REAL_HOME"/.kde*/*/config/plasma*.desktop-appletsrc; do
    [ -f "$cfg" ] || continue
    found=1

    # Pass 1: find every applet ID whose plugin matches PLUGIN_ID
    awk -v plugin="$PLUGIN_ID" '
      /^\[Containments\]\[[0-9]+\]\[Applets\]\[[0-9]+\]$/ { id=$0; sub(/^\[Containments\]\[[0-9]+\]\[Applets\]\[/,"",id); sub(/\]$/,"",id); next }
      /^plugin=/ { if ($0 == "plugin=" plugin) print id }
    ' "$cfg" > "$tmp_ids"

    if [ ! -s "$tmp_ids" ]; then
      say "No $PLUGIN_ID applets in $cfg"
      continue
    fi

    local ids
    ids=$(paste -sd'|' "$tmp_ids")
    say "Removing $PLUGIN_ID (applet $ids) from $cfg"

    # Pass 2: drop those applet sections + subsections, scrub geometry refs
    awk -v ids="$ids" '
      BEGIN { split(ids, arr, "|"); for (i in arr) bad[arr[i]]=1 }
      /^\[Containments\]\[[0-9]+\]\[Applets\]\[[0-9]+\](\[|$)/ {
        key=$0; sub(/^\[Containments\]\[[0-9]+\]\[Applets\]\[/,"",key); sub(/\](\[.*)?$/,"",key)
        skip = (key in bad)
      }
      /^ItemGeometries/ {
        line=$0
        for (key in bad) { g="Applet-" key ":[^;]*;"; while (line ~ g) sub(g,"",line) }
        print line; next
      }
      /^\[/ { if (!skip) print; next }
      !skip { print }
    ' "$cfg" > "$tmp_filter"

    if ! cmp -s "$cfg" "$tmp_filter"; then
      cp "$cfg" "$cfg.ban-notes.bak"
      mv "$tmp_filter" "$cfg"
      say "  Cleaned (backup: $cfg.ban-notes.bak)"
    else
      rm -f "$tmp_filter"
      say "  Config unchanged"
    fi
  done

  rm -f "$tmp_ids"
  if [ "$found" -eq 0 ]; then
    say "No plasma desktop configs found (DE may not be KDE)"
  fi
}

# --- 2. Delete notes data (user-level) -------------------------------------
purge_notes_data() {
  local data_root dir glob="$REAL_HOME/.local/share/plasma*notes*" found=0
  for dir in $glob "$REAL_HOME"/.local/share/plasma/notes; do
    [ -e "$dir" ] || continue
    found=1
    rm -rf "$dir"
    say "Deleted $dir"
  done
  if [ "$found" -eq 0 ]; then
    say "No notes data dirs under ~/.local/share"
  fi
}

# --- 3. Remove user-local plasmoid copies ----------------------------------
purge_user_plasmoids() {
  local dir
  for dir in "$REAL_HOME"/.local/share/plasma*/plasmoids/"$PLUGIN_ID" \
             "$REAL_HOME"/.local/share/plasma*/plasmoids/*/"$PLUGIN_ID"; do
    [ -e "$dir" ] || continue
    rm -rf "$dir"
    say "Deleted user plasmoid copy $dir"
  done
}

# --- 4. Neutralize the system plasmoid (root; auto-sudo if needed) ---------
ban_system_plasmoid() {
  local dir

  if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
      say "System ban needs root — re-executing via sudo..."
      exec sudo "$0" --system-only
    else
      warn "Not root and no sudo — system plasmoid NOT banned (user cleanup done)"
      return 1
    fi
  fi

  # Find installed copies of the plasmoid
  local found=0
  for dir in "${PLASMOID_ROOTS[@]}"; do
    [ -e "$dir/$PLUGIN_ID" ] || continue
    found=1

    if [ -f "$dir/$PLUGIN_ID" ]; then
      # Single-file plasmoid -> dpkg-divert can handle it
      if command -v dpkg-divert >/dev/null 2>&1; then
        if dpkg-divert --list | grep -qF " $dir/$PLUGIN_ID "; then
          say "Already diverted: $dir/$PLUGIN_ID"
        else
          dpkg-divert --rename --add "$dir/$PLUGIN_ID"
          say "Diverted $dir/$PLUGIN_ID -> ${PLUGIN_ID}.distrib (survives apt upgrades)"
        fi
      elif command -v rpm >/dev/null 2>&1; then
        mv "$dir/$PLUGIN_ID" "$dir/$PLUGIN_ID.disabled"
        say "Moved $dir/$PLUGIN_ID -> .disabled (rpm has no file-level divert; rerun after updates)"
      else
        mv "$dir/$PLUGIN_ID" "$dir/$PLUGIN_ID.disabled"
        say "Moved $dir/$PLUGIN_ID -> .disabled (no dpkg/rpm detected)"
      fi
    else
      # Directory plasmoid -> dpkg-divert cannot divert directories.
      # Move it aside; re-run after apt updates if the package reinstalls it.
      if [ -e "$dir/$PLUGIN_ID.disabled" ]; then
        rm -rf "$dir/$PLUGIN_ID.disabled"
      fi
      mv "$dir/$PLUGIN_ID" "$dir/$PLUGIN_ID.disabled"
      say "Moved $dir/$PLUGIN_ID -> .disabled (dpkg-divert cannot divert dirs; rerun after updates)"
    fi
  done

  if [ "$found" -eq 0 ]; then
    say "System plasmoid $PLUGIN_ID not found under known roots (already gone?)"
  else
    if command -v dpkg-divert >/dev/null 2>&1; then
      dpkg-divert --list | grep -F "$PLUGIN_ID" || true
    fi
  fi
}

# --- DE-aware shell restart hint -------------------------------------------
restart_hint() {
  if pgrep -x plasmashell >/dev/null 2>&1; then
    if command -v kquitapp6 >/dev/null 2>&1; then
      say "Restarting Plasma 6 shell..."
      kquitapp6 plasmashell 2>/dev/null || true
      sleep 1
    elif command -v kquitapp5 >/dev/null 2>&1; then
      say "Restarting Plasma 5 shell..."
      kquitapp5 plasmashell 2>/dev/null || true
      sleep 1
    fi
    pgrep -x plasmashell >/dev/null 2>&1 && pkill -x plasmashell 2>/dev/null || true
    say "Plasma shell stopped — it will respawn (or log out/in to be safe)."
  else
    say "No plasmashell running — nothing to restart."
  fi
}

# --- main ------------------------------------------------------------------
resolve_user
say "Operating on user: $REAL_USER (HOME=$REAL_HOME)"

strip_notes_from_config
purge_notes_data
purge_user_plasmoids

if [ "${1:-}" = "--system-only" ]; then
  ban_system_plasmoid
  exit 0
fi

ban_system_plasmoid
restart_hint
say "Done."
