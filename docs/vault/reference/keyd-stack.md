---
title: "Keyd Stack"
tags:
  - reference
  - keyd-stack
aliases: [keyd-setup, keyd-debug, keyd-troubleshoot]
modified: 2026-07-17
---

# keyd — Key Remapping Stack

Install, diagnostics, Caps→Hyper→F24 pipeline, and dual-interface keyboard handling.

---

## 1. Install

### 1.1 CachyOS / Arch

```bash
sudo pacman -S keyd
sudo systemctl enable --now keyd
# or: pkexec pacman -S keyd
```

### 1.2 Debian / MX Linux (build from source)

The Debian/MX package installs a daemon-only build (`/usr/bin/keyd.rvaiya`) missing the CLI tools. Always build from source:

```bash
git clone https://github.com/rvaiya/keyd
cd keyd
make
sudo make install
sudo systemctl enable --now keyd
```

**What you get vs distro package:**

| Component | Distro package (Debian) | Arch package / Upstream build |
|---|---|---|
| Daemon (`keyd` service) | ✔ (renamed binary) | ✔ |
| `keyd monitor` | ❌ | ✔ |
| `keyd-application-mapper` | ❌ | ✔ |
| Config reload helpers | ❌ | ✔ |

---

## 2. Verify install

```bash
which keyd                          # should be /usr/local/bin/keyd
keyd monitor                        # if this fails, see section 3
systemctl status keyd               # daemon must be active
```

---

## 3. Permissions: `failed to open /dev/input/eventX`

This is the #1 issue after installing. It means `keyd monitor` cannot read raw input devices.

### 3.1 Add user to input group

```bash
sudo usermod -aG input $USER
```

**You must log out and back in** (or reboot) — group membership does NOT apply to the current session.

### 3.2 Verify

```bash
groups                              # must include 'input'
```

### 3.3 Test

```bash
keyd monitor                        # run without sudo after group fix
```

Expected output: key events appear live. Press keys to verify.

### 3.4 Fallback: udev rule (if group fix alone doesn't work)

```bash
sudo tee /etc/udev/rules.d/99-keyd.rules > /dev/null << 'EOF'
KERNEL=="event*", GROUP="input", MODE="660"
EOF
sudo udevadm control --reload-rules
sudo udevadm trigger
```

Verify:

```bash
ls -l /dev/input/event0             # expected: crw-rw---- 1 root input
```

---

## 4. Working Config: Caps → Hyper → F24 (CachyOS / KDE Wayland)

### 4.1 Find the correct device ID

Keyboards with multiple USB interfaces (common on gaming keyboards) create multiple evdev nodes. Caps Lock may come from only ONE of them. Using `[ids] *` can cause conflicts.

**Find which interface emits Caps Lock:**

```bash
# Stop keyd, grab each keyboard device, test Caps
python3 << 'PY'
import evdev
from evdev import ecodes
from select import select
import time, os

for name in sorted(os.listdir("/dev/input")):
    if not name.startswith("event"): continue
    p = f"/dev/input/{name}"
    try:
        d = evdev.InputDevice(p)
        keys = d.capabilities().get(ecodes.EV_KEY, [])
        if ecodes.KEY_CAPSLOCK not in keys: continue
        d.grab()
        print(f"Testing {p}: {d.name} — press Caps now...")
        end = time.time() + 4
        saw = False
        while time.time() < end:
            r,_,_ = select([d.fd], [], [], 0.3)
            if not r: continue
            for e in d.read():
                if e.type == ecodes.EV_KEY and e.code == ecodes.KEY_CAPSLOCK:
                    print(f"  CAPS on {p}")
                    saw = True
        if not saw:
            print(f"  (no CAPS on {p})")
        d.ungrab()
    except Exception as e:
        print(f"  skip {p}: {e}")
PY
```

**On Akuma**: Caps Lock emits only on `258a:010c:3d952825` (BY Tech Gaming Keyboard input0), not on `258a:010c:1d20ac0e` (input1). Using `*` in `[ids]` caused both interfaces to match, and the conflict prevented layer activation.

### 4.2 Config (CachyOS / Akuma)

```bash
sudo mkdir -p /etc/keyd
sudo tee /etc/keyd/default.conf > /dev/null << 'EOF'
[ids]
258a:010c:3d952825

[main]
capslock = overload(hyper, noop)

[hyper]
space = f24
EOF
```

**Why `overload(hyper, noop)` not `layer(hyper)`**: `overload` provides tap/hold semantics — hold Caps activates the hyper layer, tap does nothing (`noop`). `layer(hyper)` alone didn't activate on this keyboard.

### 4.3 Apply

```bash
sudo systemctl restart keyd
```

### 4.4 Verify

```bash
keyd monitor
# Hold Caps + press Space → should see f24 down / f24 up
```

### 4.5 Generic config template (for other keyboards)

```bash
[ids]
<your-device-id-from-step-4.1>

[main]
capslock = overload(hyper, noop)

[hyper]
space = f24
```

---

## 5. Known failure: why `[ids] *` + `capslock = hyper` failed

**Resolved 2026-07-17.** The root cause was dual-interface keyboard conflict, not KDE Wayland interception.

### What happened

| Symptom | Cause |
|---|---|
| `a = b` worked in keyd | keyd was remapping the correct device — but only one of two interfaces |
| `capslock = hyper` did nothing | The second keyboard interface (also matching `*`) swallowed or conflicted with the Caps remap |
| `capslock = loadkeys` names failed | `compose`, `layer(hyper)` — all failed because the conflict prevented layer activation |
| Caps acted as "right click" temporarily | `compose` layer interpreted the key as a mouse event through keyd's virtual mouse |

### Why it wasn't KDE Wayland after all

The suspicion that KWin grabs evdev before keyd was incorrect. Keyd WAS seeing the device — but it was seeing TWO keyboard devices from the same physical keyboard, and only one emitted Caps Lock. Matching both with `[ids] *` caused silent conflict.

### Tested and failed configs (all resolved by device-id matching)

| Config | Result |
|---|---|
| `capslock = hyper` + `[hyper] space = f24` | Failed — layer not active |
| `capslock = layer(hyper)` + `[hyper] space = f24` | Failed — layer not active |
| `capslock = compose` + `[compose] space = f24` | Failed — Caps became right-click |
| `capslock = f24` (direct) | Failed — Caps passed through raw |
| `capslock = overload(hyper, noop)` + `[hyper] space = f24` | **Works** with correct device ID |

---

## 6. Debug when mapping fails

### 6.1 Check if keyd sees the key

```bash
keyd monitor                        # press Caps — do you see it?
```

If **yes** (keyd sees Caps) but mapping fails → config or layer activation issue.
If **no** → wrong device ID, or Caps is on a different interface.

### 6.2 Find which device emits Caps (without keyd)

```bash
# Stop keyd first, then run the device probe from section 4.1
sudo systemctl stop keyd
python3 << 'PY'  # (see 4.1 for full script)
```

### 6.3 Dual-interface keyboards

Gaming keyboards often expose multiple USB interfaces. Only one emits Caps Lock. Use the probe script in section 4.1 to find it, then match that specific ID in `[ids]`.

### 6.4 KDE keyboard interception

| Environment | Issue | Fix |
|---|---|---|
| X11 | `setxkbmap` options override | Check `setxkbmap -query` |
| Wayland | KDE keyboard shortcuts layer | Check System Settings → Keyboard → Shortcuts |
| Both | Caps may be grabbed by KDE before keyd | Set XKB option `caps:none` in `~/.config/kxkbrc` |

---

## 7. Success check (after setup)

```bash
groups | grep input                 # must include 'input'
systemctl is-active keyd            # must say 'active'
keyd monitor                        # hold Caps + press Space → f24 down/up
```

## 8. Yakuake integration

### 8.1 Install

```bash
sudo pacman -S yakuake
```

### 8.2 Shortcut binding

In `~/.config/kglobalshortcutsrc` under `[yakuake]`:

```ini
toggle-window-state=Ctrl+Space,F12,F24,Open/Retract Yakuake
```

Multiple shortcuts can be listed: `Ctrl+Space` (standard), `F12` (fallback), `F24` (keyd Caps+Space target).

### 8.3 Autostart

`~/.config/autostart/yakuake.desktop`:

```ini
[Desktop Entry]
Exec=/usr/bin/yakuake
Name=yakuake
Terminal=False
Type=Application
```

---

## 9. Key mental model

```
Hardware keypress
  │
  ▼
evdev (/dev/input/event*)    ← keyd reads here (requires correct device ID)
  │
  ▼
keyd daemon                  ← remaps according to /etc/keyd/default.conf
  │
  ▼
keyd virtual keyboard        ← emits remapped keys (e.g. f24)
  │
  ▼
KDE/Wayland                  ← shortcut system sees F24
  │
  ▼
Application (Yakuake)
```

**Four layers of failure:**

| Layer | Symptom | Debug |
|---|---|---|
| Permission | `keyd monitor` can't open devices | `groups`, `ls -l /dev/input/event0` |
| Device ID | keyd runs but Caps never seen | `python3` probe script (section 4.1) |
| Config | keyd sees Caps but no remapping | `keyd monitor`, check syntax |
| KDE shortcut | F24 emitted but Yakuake doesn't toggle | Check `kglobalshortcutsrc` |

---

## 10. Akuma-specific reference

```
Host:    Akuma (CachyOS, KDE Plasma 6 Wayland)
Keyboard: BY Tech Gaming Keyboard
Caps device: 258a:010c:3d952825 (/dev/input/event4, input0)
Ignored interface: 258a:010c:1d20ac0e (/dev/input/event7, input1)

Config: /etc/keyd/default.conf
Installed via: pacman (cachyos-extra-v3, keyd 2.6.0)

Yakuake shortcut: Ctrl+Space,F12,F24 → Open/Retract Yakuake
XKB option: caps:none (in ~/.config/kxkbrc)
Input group: ken added to 'input' + udev rule at /etc/udev/rules.d/99-keyd.rules
```

## 11. Health check

```bash
echo "=== keyd daemon ===" && systemctl is-active keyd && \
echo "=== groups ===" && groups | grep -o input || echo "MISSING: input group" && \
echo "=== binary ===" && which keyd && \
echo "=== config ===" && cat /etc/keyd/default.conf 2>/dev/null || echo "NO CONFIG"
```
