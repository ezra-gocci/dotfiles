# Sunshine Setup Guide

Self-hosted game streaming server (Moonlight client → Mac host).

Sunshine was set up on Masina (M1 MacBook Pro) in February 2026 with two instances — one for the built-in display and one for a virtual display.

## Install

```bash
brew tap lizardbyte/homebrew
brew install lizardbyte/homebrew/sunshine
```

## Why a Wrapper App?

macOS requires Screen Recording, Accessibility, and Input Monitoring permissions. These TCC permissions can only be granted to `.app` bundles in System Settings, not to bare CLI binaries. Sunshine ships as a Homebrew CLI binary at `/opt/homebrew/bin/sunshine`, so it can't receive permissions directly.

The solution is a minimal wrapper `.app` that:
1. Looks like a real macOS app (has `Info.plist`, bundle identifier)
2. Executes the Homebrew `sunshine` binary
3. Can be granted TCC permissions in System Settings
4. Runs as a background agent (`LSUIElement = true`, no Dock icon)

## Build the Wrapper App

### 1. Create the wrapper binary

Create `SunshineWrapper.c`:

```c
#include <stdlib.h>
#include <unistd.h>

int main() {
    setenv("SUNSHINE_CONFIG_DIR", "/Users/YOUR_USER/.config/sunshine", 1);
    execl("/opt/homebrew/bin/sunshine", "sunshine", NULL);
    return 1;  // only reached if exec fails
}
```

Compile:

```bash
clang -o SunshineWrapper SunshineWrapper.c
```

### 2. Create the .app bundle

```bash
mkdir -p ~/Applications/SunshineWrapper.app/Contents/MacOS
cp SunshineWrapper ~/Applications/SunshineWrapper.app/Contents/MacOS/
```

### 3. Create Info.plist

```bash
cat > ~/Applications/SunshineWrapper.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>SunshineWrapper</string>
    <key>CFBundleIdentifier</key>
    <string>dev.lizardbyte.sunshine.wrapper</string>
    <key>CFBundleName</key>
    <string>Sunshine</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF
```

`LSUIElement = true` makes it a background agent (no Dock icon).

## Grant Permissions (Manual — Cannot Be Automated)

Open **System Settings → Privacy & Security** and add `SunshineWrapper.app` to:

1. **Screen Recording** — required to capture the display
2. **Accessibility** — required for mouse/keyboard input forwarding
3. **Input Monitoring** — required for gamepad and keyboard capture

You must drag the app from `~/Applications/` into each permission list, or click `+` and navigate to it.

## Configuration

### Config directory: `~/.config/sunshine/`

#### `sunshine.conf`

```ini
port = 47990
https_port = 48990
output_name = 10
stream_audio = disabled
```

- `port` — Web UI port (access at `https://localhost:47990`)
- `https_port` — Streaming port
- `output_name` — Display index to capture. Use the Sunshine web UI to identify display numbers, or check `log` output for "Detected display" lines
- `stream_audio` — Set to `disabled` if audio causes issues or isn't needed

#### `apps.json`

```json
{
    "apps": [
        {
            "image-path": "desktop.png",
            "name": "Desktop"
        },
        {
            "auto-detach": true,
            "cmd": [],
            "detached": [""],
            "elevated": false,
            "exclude-global-prep-cmd": false,
            "exit-timeout": 5,
            "image-path": "",
            "name": "Small Desktop",
            "output": "Virtual 19:9",
            "wait-all": true
        },
        {
            "detached": ["open steam://open/bigpicture"],
            "image-path": "steam.png",
            "name": "Steam Big Picture",
            "prep-cmd": [
                {
                    "do": "",
                    "undo": "open steam://close/bigpicture"
                }
            ]
        }
    ],
    "env": {
        "PATH": "$(PATH):$(HOME)/.local/bin"
    }
}
```

Apps define what the Moonlight client can launch:
- **Desktop** — streams the main display as-is
- **Small Desktop** — streams a virtual display (useful for different resolution)
- **Steam Big Picture** — opens Steam in Big Picture mode, closes it on disconnect

#### `credentials/`

Contains `cacert.pem` and `cakey.pem` — auto-generated on first run. These are the TLS certificates for the web UI and streaming protocol. They are unique per installation; new ones are generated automatically.

## LaunchAgent (Auto-Start on Login)

### `~/Library/LaunchAgents/dev.lizardbyte.sunshine.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>dev.lizardbyte.sunshine</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/YOUR_USER/Applications/SunshineWrapper.app/Contents/MacOS/SunshineWrapper</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/sunshine.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/sunshine.error.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
        <key>SUNSHINE_CONFIG_DIR</key>
        <string>/Users/YOUR_USER/.config/sunshine</string>
    </dict>
</dict>
</plist>
```

Load it:

```bash
launchctl load ~/Library/LaunchAgents/dev.lizardbyte.sunshine.plist
```

Unload:

```bash
launchctl unload ~/Library/LaunchAgents/dev.lizardbyte.sunshine.plist
```

## Multi-Instance Setup (Optional)

To run two Sunshine instances (e.g., built-in display + virtual display), create a second wrapper and config:

1. Duplicate the wrapper app as `SunshineWrapper2.app` (different bundle ID: `dev.lizardbyte.sunshine2.wrapper`)
2. Point it at a separate config dir: `~/.config/sunshine2/`
3. Use different ports to avoid conflicts:

```ini
# ~/.config/sunshine2/sunshine2.conf
port = 48100
output_name = 11
stream_audio = disabled
```

4. Create a second LaunchAgent (`dev.lizardbyte.sunshine2.plist`) pointing to the second wrapper
5. Grant TCC permissions to `SunshineWrapper2.app` separately

## First-Time Pairing

1. Start Sunshine (or let the LaunchAgent start it)
2. Open `https://localhost:47990` in a browser
3. Create a username and password for the web UI
4. On the Moonlight client, add the Mac's IP address
5. Moonlight will show a 4-digit PIN — enter it in the Sunshine web UI
6. Once paired, the client can connect without the PIN

## Troubleshooting

- **Logs**: `tail -f /tmp/sunshine.log`
- **"No gamepad input available"** — normal on Mac, gamepads are forwarded from the client
- **Black screen on connect** — Screen Recording permission not granted to the wrapper app
- **Can't move mouse/keyboard** — Accessibility and Input Monitoring permissions not granted
- **"PrioritizeEncodingSpeedOverQuality not supported"** — harmless warning on M1, can be ignored
