# Update macOS settings playbook to match desired configuration

## Context
After factory reset, the Ansible playbook applies some macOS defaults but is missing many settings the user wants. The user provided ~20 screenshots showing their desired configuration. This plan updates `ansible/tasks/macos.yml`, `ansible/vars/main.yml`, `ansible/tasks/dock.yml`, and `macos/defaults.sh` to capture ALL settings from the screenshots, ensuring a single playbook run restores the full environment.

## Settings parsed from all screenshots

### 1. Dock Apps (user explicitly specified)
**Only these 5 apps:** Finder, Safari, Chrome, Zed, Obsidian

### 2. Desktop & Dock (3 screenshots)
- Position: **Left**
- Size: **36** (small)
- Magnification: **ON**, large size ~84
- Minimized window animation: **Genie Effect**
- Title bar double-click: **Zoom**
- Minimize windows into application icon: **OFF**
- Auto-hide Dock: **ON**
- Animate opening applications: **ON**
- Show indicators for open apps: **ON**
- Show suggested/recent apps: **OFF**
- **Desktop & Stage Manager:**
  - Show items: On Desktop ☐, In Stage Manager ☑ (one screenshot) / On Desktop ☑ (another)
  - Click wallpaper to show desktop: Only in Stage Manager
  - Stage Manager: **OFF**
  - Show recent apps in Stage Manager: **OFF**
  - Show windows from application: All at Once
- **Widgets:**
  - Show Widgets: On Desktop ☑
  - Dim widgets on desktop: Automatically
  - iPhone Widgets: **OFF**
  - Default web browser: Safari
- **Windows:**
  - Prefer tabs: In Full Screen
  - Ask to keep changes when closing: **OFF**
  - Close windows when quitting: **ON**
  - Drag to left/right edge to tile: **ON**
  - Drag to menu bar to fill: **ON**
  - Hold ⌥ while dragging to tile: **ON**
  - Tiled windows have margins: **OFF**
- **Mission Control:**
  - Auto rearrange Spaces: **OFF** (keep playbook's current value)
  - Switch to Space with open windows: **ON**
  - Group windows by application: **OFF**
  - Displays have separate Spaces: **ON**
  - Drag to top for Mission Control: **ON**

### 3. Hot Corners (from screenshot)
- Top-right: **Quick Note** (value 14)
- Bottom-right: **Start Screen Saver** (value 5)
- Top-left & Bottom-left: **disabled** (value 0, shown as "—")

### 4. Appearance
- Appearance: **Auto** (switches automatically)
- Liquid Glass: **Tinted**
- Theme color: **Multicolor** (default)
- Text highlight color: **Automatic**
- Icon & widget style: **Tinted**, **Auto** (light/dark)
- Icon, widget & folder color: **Automatic**
- Sidebar icon size: **Small** (1)
- Tint window background with wallpaper: **ON**
- Show scroll bars: **Automatically based on mouse/trackpad**
- Click in scroll bar: **Jump to the spot that's clicked** (value 1)

### 5. Keyboard
- Key repeat rate: **Fast** (KeyRepeat 2, already in playbook)
- Delay until repeat: **Short** (InitialKeyRepeat 15, already in playbook)
- Adjust keyboard brightness in low light: **ON**
- Turn keyboard backlight off after inactivity: **After 5 Minutes**
- Press 🌐 key to: **Change Input Source**
- Keyboard navigation: **ON** (AppleKeyboardUIMode 3, already in playbook)
- Input Sources: **ABC, Armenian – HM QWERTY, Russian-PC** (already configured on system)
- Dictation: **ON**, Shortcut: Press Right Command Key Twice
- **Touch Bar:** App Controls, Show Control Strip ON, fn key shows F1-F12, Show typing suggestions ON

### 6. Trackpad (Point & Click)
- Tracking speed: **~1.5** (moderate-high)
- Click: **Firm** (FirstClickThreshold 2, SecondClickThreshold 2)
- Force Click and haptic feedback: **ON**
- Look up & data detectors: Force Click with One Finger
- Secondary click: Click or Tap with Two Fingers
- Tap to click: **ON**

### 7. Accessibility > Zoom
- Keyboard shortcuts to zoom: **OFF**
- Trackpad gesture to zoom: **ON**
- Scroll gesture with modifier keys to zoom: **ON**
- Modifier key: **Control**
- Zoom style: **Full Screen**
- Touch Bar zoom: **ON**

### 8. Accessibility > Pointer Control
- Spring-loading: **ON** (com.apple.springing.enabled = true)
- Use trackpad for dragging: **ON**
- Dragging style: **Three Finger Drag**

### 9. Language & Region
- Preferred languages: English (primary), Russian, Armenian
- Region: Armenia
- Temperature: Celsius
- Measurement: Metric
- First day of week: Monday
- Date format: y/M/d
- (Already configured on system — needs to be in playbook for restore)

### 10. Login Items
- Open at Login: **Claude**, **iTerm**

### 11. Apple Intelligence & Siri
- Apple Intelligence: **OFF** (not turned on)
- Siri: **OFF**
- Listen for: Off
- Keyboard shortcut: Hold Command Space

### 12. Displays
- Resolution: **1680 × 1050** (scaled) — set via `displayplacer` CLI
- Automatically adjust brightness: **OFF**
- True Tone: **ON**

### 13. Menu Bar
- Auto-hide menu bar: **In Full Screen Only**
- Show menu bar background: **ON**
- Recent items: **10**
- Focus, Screen Mirroring, Display, Sound, Now Playing, Timer, Weather, Text Input: **Show When Active** ☑
- Claude, iTerm allowed in menu bar: **ON**

### 14. Wallpaper
- **Macintosh** (Dynamic Wallpaper), Automatic, Spectrum color, Show on all Spaces

### 15. Lock Screen
- Turn display off on battery: **30 minutes**
- Turn display off on power adapter: **1 hour**
- Require password after screensaver: **Immediately**
- Show user name and photo: **ON**
- Show password hints: **OFF**
- Login window shows: **List of users**
- Show Sleep, Restart, Shut Down buttons: **ON**

---

## Changes

### File 1: `ansible/vars/main.yml`
Update dock_apps and add new variables:

```yaml
# Dock apps — changed from 8 apps to 5
dock_apps:
  - /System/Library/CoreServices/Finder.app
  - /Applications/Safari.app
  - /Applications/Google Chrome.app
  - /Applications/Zed.app
  - /Applications/Obsidian.app

# Dock — updated values
dock_tilesize: 36
dock_magnification: true
dock_largesize: 84
dock_orientation: left
dock_mineffect: genie
dock_autohide: true
dock_autohide_delay: 0
dock_autohide_time_modifier: 0
dock_show_recents: false
dock_minimize_to_application: false
dock_launchanim: true
dock_show_process_indicators: true

# Hot corners — changed: top-left/bottom-left to 0, top-right to 14 (Quick Note), bottom-right to 5
hot_corner_top_left: 0
hot_corner_top_right: 14     # Quick Note
hot_corner_bottom_left: 0    # None
hot_corner_bottom_right: 5   # Screen Saver

# Energy — changed: battery 30 min, charger 60 min
energy_battery_display_sleep: 30
energy_charger_display_sleep: 60
energy_charger_system_sleep: 0

# Login items
login_items:
  - /Applications/Claude.app
  - /Applications/iTerm.app

# Input sources
input_sources:
  - { name: "ABC", id: 252 }
  - { name: "RussianWin", id: 19458 }
  - { name: "Armenian-HM QWERTY", id: -28161 }
```

### File 2: `ansible/tasks/macos.yml`
Add new sections and update existing ones. Changes organized by section:

**Update existing Dock section** — add orientation, magnification, largesize, mineffect, minimize-to-application, launchanim, show-process-indicators. Keep mru-spaces **false** (auto-rearrange OFF per user confirmation).

**Add new "Appearance" section:**
- `AppleInterfaceStyleSwitchesAutomatically` = true (Auto appearance)
- Remove any `AppleInterfaceStyle` (let Auto handle it)
- `NSTableViewDefaultSizeMode` = 1 (Small sidebar icons)
- `AppleScrollerPagingBehavior` = 1 (Jump to spot clicked)

**Add new "Window Management" section:**
- `NSQuitAlwaysKeepsWindows` = false (Close windows when quitting ON)
- `EnableTiledWindowMargins` = 0 (Tiled windows have margins OFF) — com.apple.WindowManager domain

**Add new "Keyboard Input Sources" section:**
- Write `AppleEnabledInputSources` plist via `defaults write` shell command (array of dicts)

**Add new "Language & Region" section:**
- `AppleLanguages` = (en-AM, ru-AM, hy-AM)
- `AppleLocale` = en_AM
- `AppleICUDateFormatStrings` 1 = "y/M/d"
- `AppleMeasurementUnits` = Centimeters
- `AppleMetricSystem` = true
- `AppleTemperatureUnit` = Celsius

**Add new "Accessibility" section:**
- `closeViewScrollWheelToggle` = 1 (scroll gesture zoom ON)
- `closeViewTrackpadGestureZoomEnabled` = 1 (trackpad gesture zoom ON)

**Add new "Trackpad" section:**
- `TrackpadThreeFingerDrag` = 1 (both com.apple.AppleMultitouchTrackpad and bluetooth driver)
- `FirstClickThreshold` = 2, `SecondClickThreshold` = 2 (Firm click)
- `com.apple.springing.enabled` = true (Spring-loading ON)

**Add new "Siri" section:**
- `com.apple.assistant.support "Assistant Enabled"` = false

**Add new "Login Items" section:**
- Use `osascript` to add login items for Claude.app and iTerm.app

**Add "Display" section:**
- Install `displayplacer` via Homebrew (add to Brewfile if not present), use it to set 1680×1050 scaled resolution
- Disable auto-brightness via `defaults write com.apple.BezelServices dAuto -bool false` (sudo)

**Add "iPhone Widgets" setting:**
- `defaults write com.apple.chronod remoteWidgetsEnabled -bool false`

**Add "Menu Bar" section:**
- `_HIHideMenuBar` = 0, fullscreen-only auto-hide via AppleMenuBarVisibleInFullscreenOnly or NSStatusBar approach
- `NSRecentDocumentsLimit` = 10

**Update "Hot Corners"** — change values per vars above

### File 3: `macos/defaults.sh`
Mirror all Ansible changes in the bash fallback script:
- Add corresponding `defaults write` commands for every new setting
- Update changed values (dock size, hot corners, energy)

### File 4: `Brewfile`
Add `displayplacer` for display resolution management:
```ruby
brew "displayplacer"
```

### File 5: `ansible/tasks/dock.yml`
No changes needed — it already reads from `dock_apps` variable.

---

## Implementation Order
1. Update `ansible/vars/main.yml` with new variable values
2. Update `ansible/tasks/macos.yml` with new task sections
3. Update `macos/defaults.sh` to match
4. Test by running `ansible-playbook main.yml -i inventory.yml --tags macos,dock --ask-become-pass`

## Verification
```bash
# Run playbook
cd ~/.dotfiles/.claude/worktrees/silly-swartz/ansible
ansible-playbook main.yml -i inventory.yml --tags macos,dock --ask-become-pass

# Verify key settings
defaults read com.apple.dock orientation        # expect: left
defaults read com.apple.dock tilesize            # expect: 36
defaults read com.apple.dock magnification       # expect: 1
defaults read com.apple.dock wvous-tr-corner     # expect: 14
defaults read com.apple.dock wvous-br-corner     # expect: 5
defaults read NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically  # expect: 1
defaults read com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag # expect: 1
defaults read com.apple.HIToolbox AppleEnabledInputSources # expect ABC, RussianWin, Armenian-HM QWERTY
dockutil --list  # expect: Finder, Safari, Chrome, Zed, Obsidian
```
Some settings (display resolution, login items, input sources) may require logout/restart to fully take effect.
