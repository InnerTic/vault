---
title: "Keyd Kde Wayland F24"
tags:
  - reference
modified: 2026-07-17
---

# Why F24 worked (keyd + KDE + Wayland)

## 1. keyd is not "typing keys"

keyd acts at the **input device layer**:

```
physical key → kernel input event → virtual keyboard device
```

When you saw `f24 down / up`, keyd successfully injected a synthetic Linux input event.

## 2. The real problem was NOT keyd

Earlier failures (F12/F13/etc.) weren't because remapping failed. They failed because of:

### A) Key collision in KDE
- F12 is often bound to terminal shortcuts, desktop effects, or media layer bindings
- KDE may intercept it before global shortcut handling

### B) Wayland shortcut filtering
On Plasma Wayland, not all synthetic inputs are treated equally for global shortcuts. Some keys get ignored or deprioritized if they are common system keys, already bound in KWin, or come from virtual devices.

## 3. Why F24 specifically worked

F24 succeeds because it has three properties:

- **"Dead space" in the keymap** — rarely used by apps, rarely bound by KDE defaults, no media/system collision
- **Valid Linux input keycode** — kernel supports F1–F24, Wayland recognizes it, KDE shortcut system can bind it
- **Avoids shortcut filtering heuristics** — KDE/Wayland prioritizes real hardware keys and commonly used keys (F1–F12, media keys). F24 is "valid but irrelevant" → passes through cleanly

## 4. The actual pipeline

```
Caps Lock (held)
   ↓
keyd layer (hyper)
   ↓
maps → F24
   ↓
virtual keyboard device emits event
   ↓
Wayland accepts event
   ↓
KDE shortcut system sees F24
   ↓
Yakuake binds / toggles
```

## 5. Why earlier "F12 didn't pass through"

Because it likely got intercepted: `keyd → F12 → KDE intercept OR Wayland filter OR existing binding conflict`. It never reached the final shortcut handler in a clean way.

## 6. Core insight

This is not a remapping problem. It is an **input signal routing + shortcut arbitration problem**. Three layers compete:

| Layer   | Role                     |
| ------- | ------------------------ |
| keyd    | generates input          |
| Wayland | filters/normalizes input |
| KDE     | decides shortcut actions |

F24 simply bypasses conflict at the KDE layer.

## 7. Practical rule

> "Never use F1–F12 for synthetic control signals on KDE Wayland if F13–F24 are available"

- F1–F12 = user + app space
- F13–F24 = control plane space

## 8. Known failure (HISTORICAL — resolved 2026-07-17)

The approach `capslock = hyper` + `[hyper] space = f24` previously **did not work** on KDE Wayland. Root cause was **dual-interface keyboard conflict**, not KDE Wayland interception.

### Original symptoms (now explained)

| Symptom | Actual cause |
|---|---|
| `keyd monitor` showed raw capslock/space | Second keyboard interface conflicted with layer activation |
| Application received Meta+Space | No remapping occurred → KDE interpreted raw keys |
| All layer syntax variants failed (`hyper`, `layer(hyper)`, `compose`) | Conflict prevented any layer from activating on Caps device |

### Suspected causes (all ruled out)

- ~~KWin grabs evdev before keyd~~ — keyd WAS grabbing the device, but wrong one
- ~~`hyper` layer name not recognized~~ — `overload(hyper, noop)` works fine
- ~~Wayland filters synthetic input~~ — F24 passes through cleanly once emitted

### What actually failed

```
Caps Lock (held) → event4 (input0, 258a:010c:3d952825) ← Caps lives here
                  event7 (input1, 258a:010c:1d20ac0e) ← also matches *, no Caps
     ↓
Both interfaces matched by [ids] * → layer activation conflicted
     ↓
No remapping occurred
```

### Resolution: device-id matching

```
[ids]
258a:010c:3d952825      ← match ONLY the interface that emits Caps Lock

[main]
capslock = overload(hyper, noop)

[hyper]
space = f24
```

Finding the correct device ID was the critical debug step. See [[reference/keyd-stack]] section 4.1 for the python probe script.

---

## 9. Working config (Akuma / CachyOS)

```bash
sudo tee /etc/keyd/default.conf > /dev/null << 'CONF'
[ids]
258a:010c:3d952825

[main]
capslock = overload(hyper, noop)

[hyper]
space = f24
CONF
sudo systemctl enable --now keyd
```

And in `~/.config/kglobalshortcutsrc`:
```ini
[yakuake]
toggle-window-state=Ctrl+Space,F12,F24,Open/Retract Yakuake
```

## 10. Mental model upgrade

```
F1–F12   = human/UI interaction layer
F13–F24  = system control bus
```

keyd is now acting as a **hardware-to-control-plane compiler**.

## 11. Debug mantra

When Caps→Hyper→F24 fails, check in this order:
1. `groups | grep input` — permission
2. Python probe script → find the right device ID → update `[ids]`
3. `capslock = overload(hyper, noop)` — correct syntax for tap/hold layers
4. `keyd monitor` → verify f24 emitted
5. `grep F24 ~/.config/kglobalshortcutsrc` — Yakuake shortcut bound
