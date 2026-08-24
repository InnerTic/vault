---
title: "GW2 Loader Symlink Fix"
tags:
  - software
modified: 2026-08-24
---

# GW2 Loader Symlink Launch — KDE Exec Regression

> Incident 2026-08-23/24. Symptom, root cause, fix, and recurrence playbook for the
> `Gw2-Simple-Addon-Loader.exe` desktop-symlink launch workflow. Related: [[gw2-multibox-wine-setup]],
> [[workarounds]].

## The workflow that broke

- Icon on Desktop: `~/Desktop/Gw2-Simple-Addon-Loader.exe` → symlink to
  `/mnt/workspace/SteamLibrary/steamapps/common/Guild Wars 2/addons/LOADER_public/Gw2-Simple-Addon-Loader.exe`
- Double-click in Dolphin → MIME handler
  `application/vnd.microsoft.portable-executable=protontricks-launch.desktop` (`~/.config/mimeapps.list`)
  → protontricks prefix picker → game launches with addons.
- After the CachyOS update of **2026-08-23**, double-click silently did nothing.

## Root cause (KIO ≥ 6.28 direct-exec regression)

- Breaking update: `pacman -Syu` 2026-08-23 ~16:45–18:37 upgraded
  `kio 6.27.0-1.1 → 6.29.0-2`, `plasma-desktop 6.6.5 → 6.7.4` (also kconfig/kservice 6.27→6.29).
- KIO commit **b358a742** (2026-06-22, "openurljob: treat x-ms-dos-executable as a native binary if
  the executable bit is set", first shipped in KIO v6.28.0; related d51a6619, 2a5be629).
- New behavior: a `.exe` **with the execute bit** is executed *directly* by KIO via binfmt_misc
  (`DOSWin` registered) — bypassing the MIME association entirely.
- Consequence for this workflow: the loader ran with its own path resolved through the symlink,
  so its working directory became `Z:\home\ken\Desktop`. It walked up looking for `Gw2-64.exe`,
  checked `Z:\home\Gw2-64.exe`, and panicked:

```
[Gw2SimpleAddonLoader] Running from addon directory: "Z:\home\ken\Desktop"
[Gw2SimpleAddonLoader] Looking for Gw2-64.exe on path: "Z:\home\Gw2-64.exe"
thread 'main' panicked at src/main.rs:101:14: called `Result::unwrap()` on an `Err`: NotFound
```

The process died instantly → looked like "double-click does nothing". The MIME association and
protontricks were never broken.

## Fix (applied & verified 2026-08-24)

Remove the execute bit from the **real target** so KIO falls back to association handling:

```bash
chmod -x "/mnt/workspace/SteamLibrary/steamapps/common/Guild Wars 2/addons/LOADER_public/Gw2-Simple-Addon-Loader.exe"
# now: -rw-r--r-- ; Wine does not need +x
```

Confirmed: double-click → protontricks picker → login client up → game running.

## Recurrence playbook

If double-click stops working again after an update:

```bash
stat -c %A "/mnt/workspace/SteamLibrary/steamapps/common/Guild Wars 2/addons/LOADER_public/Gw2-Simple-Addon-Loader.exe"
journalctl --user --since today | grep -Ei 'addon-loader|panic|NotFound'
```

- If the file shows `rwx` again → re-download re-added the exec bit → `chmod -x` it.
- If journal shows the same panic signature → wrong CWD again; check which launcher bypassed the association.
- Watch KIO commits touching `x-ms-dos-executable` / `openurljob` for behavior changes.

## Upstream status (checked 2026-08-24)

- **KDE**: no existing bug report found (bugs.kde.org searches for protontricks / .exe
  double-click since 2026-04 return nothing relevant). The change looks intentional
  (binfmt-aware design); a report could ask it to honor "Open With" preference or canonicalize symlinks.
- **Loader repo** ([SorryQuick/external-dx11-overlay](https://github.com/SorryQuick/external-dx11-overlay)):
  same panic *family* reported as #20 (Lutris, wrong parent dir) and #47 (NixOS/Lutris), both closed;
  our exact trigger (KDE/KIO executing a symlinked exe directly) is unreported there too.
