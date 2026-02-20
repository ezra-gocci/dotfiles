#!/bin/bash
#
# macOS System Preferences
#
# Apply sensible macOS defaults
#

echo "Applying macOS defaults..."

# Close System Preferences to prevent overriding
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# ============================================
# General UI/UX
# ============================================

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" "

# Save to disk (not to iCloud) by default
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# ============================================
# Appearance
# ============================================

# Set appearance to Auto (light/dark)
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# Set sidebar icon size to Small
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

# Scroll bar: jump to the spot that's clicked
defaults write NSGlobalDomain AppleScrollerPagingBehavior -int 1

# ============================================
# Trackpad, mouse, keyboard
# ============================================

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Trackpad: set firm click
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 2
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 2

# Trackpad: enable three-finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Trackpad: set tracking speed
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 1.5

# Enable spring-loading
defaults write NSGlobalDomain com.apple.springing.enabled -bool true

# Increase sound quality for Bluetooth headphones/headsets
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

# Enable full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Disable press-and-hold for accent characters (enable key repeat)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Globe key: Change Input Source
defaults write com.apple.HIToolbox AppleFnUsageType -int 1

# ============================================
# Input Sources
# ============================================

# Configure keyboard input sources: ABC, Russian-PC, Armenian-HM QWERTY
defaults write com.apple.HIToolbox AppleEnabledInputSources -array \
  '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 252; "KeyboardLayout Name" = ABC; }' \
  '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = 19458; "KeyboardLayout Name" = RussianWin; }' \
  '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = -28161; "KeyboardLayout Name" = "Armenian-HM QWERTY"; }' \
  '{ "Bundle ID" = "com.apple.CharacterPaletteIM"; InputSourceKind = "Non Keyboard Input Method"; }' \
  '{ "Bundle ID" = "com.apple.inputmethod.EmojiFunctionRowItem"; InputSourceKind = "Non Keyboard Input Method"; }'

# ============================================
# Language & Region
# ============================================

# Preferred languages: English, Russian, Armenian
defaults write NSGlobalDomain AppleLanguages -array "en-AM" "ru-AM" "hy-AM"

# Locale: English (Armenia)
defaults write NSGlobalDomain AppleLocale -string "en_AM"

# Metric system
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricSystem -bool true
defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"

# Date format: y/M/d
defaults write NSGlobalDomain AppleICUDateFormatStrings -dict 1 "y/M/d"

# ============================================
# Finder
# ============================================

# Show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Avoid creating .DS_Store files on network or USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Use list view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the ~/Library folder
chflags nohidden ~/Library

# Show the /Volumes folder
sudo chflags nohidden /Volumes

# ============================================
# Dock
# ============================================

# Set the icon size of Dock items
defaults write com.apple.dock tilesize -float 36

# Enable magnification
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -float 84

# Dock position: left
defaults write com.apple.dock orientation -string "left"

# Minimize effect: Genie
defaults write com.apple.dock mineffect -string "genie"

# Title bar double-click: Zoom
defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Maximize"

# Don't minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool false

# Don't automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

# Remove the auto-hiding Dock delay
defaults write com.apple.dock autohide-delay -float 0

# Remove the animation when hiding/showing the Dock
defaults write com.apple.dock autohide-time-modifier -float 0

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Animate opening applications
defaults write com.apple.dock launchanim -bool true

# Show indicators for open applications
defaults write com.apple.dock show-process-indicators -bool true

# Don't show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# ============================================
# Desktop Icons
# ============================================

# Desktop stacks grouped by Kind
defaults write com.apple.finder DesktopViewSettings -dict-add GroupBy -string Kind

# ============================================
# Desktop & Stage Manager
# ============================================

# Disable Stage Manager
defaults write com.apple.WindowManager GloballyEnabled -bool false

# Disable tiled window margins
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

# Disable iPhone Widgets
defaults write com.apple.chronod remoteWidgetsEnabled -bool false

# ============================================
# Window Management
# ============================================

# Close windows when quitting application
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# ============================================
# Menu Bar
# ============================================

# Auto-hide menu bar in full screen only
defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreenOnly -bool true

# ============================================
# Siri
# ============================================

# Disable Siri
defaults write com.apple.assistant.support "Assistant Enabled" -bool false

# ============================================
# Accessibility
# ============================================

# Zoom: enable scroll gesture with Control modifier
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true

# Zoom: enable trackpad gesture
defaults write com.apple.universalaccess closeViewTrackpadGestureZoomEnabled -bool true

# ============================================
# Display
# ============================================

# Set display resolution to 1680x1050 (scaled) if displayplacer is installed
if command -v displayplacer >/dev/null 2>&1; then
  DISPLAY_ID=$(displayplacer list 2>/dev/null | grep -m1 "Persistent screen id:" | awk '{print $NF}')
  if [ -n "$DISPLAY_ID" ]; then
    displayplacer "id:${DISPLAY_ID} res:1680x1050 scaling:on"
  fi
fi

# ============================================
# Login Items
# ============================================

# Add Claude and iTerm as login items
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Claude.app", hidden:false}' 2>/dev/null || true
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/iTerm.app", hidden:false}' 2>/dev/null || true

# ============================================
# Safari & WebKit
# ============================================

# Safari preferences (sandboxed — must use full plist path)
SAFARI_PLIST="$HOME/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.plist"
if [ -f "$SAFARI_PLIST" ]; then
  defaults write "$SAFARI_PLIST" UniversalSearchEnabled -bool false
  defaults write "$SAFARI_PLIST" SuppressSearchSuggestions -bool true
  defaults write "$SAFARI_PLIST" ShowFullURLInSmartSearchField -bool true
  defaults write "$SAFARI_PLIST" IncludeDevelopMenu -bool true
  defaults write "$SAFARI_PLIST" WebKitDeveloperExtrasEnabledPreferenceKey -bool true
fi

# ============================================
# Terminal
# ============================================

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# ============================================
# Time Machine
# ============================================

# Prevent Time Machine from prompting to use new hard drives as backup volume
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# ============================================
# Activity Monitor
# ============================================

# Show the main window when launching Activity Monitor
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

# Visualize CPU usage in the Activity Monitor Dock icon
defaults write com.apple.ActivityMonitor IconType -int 5

# Show all processes in Activity Monitor
defaults write com.apple.ActivityMonitor ShowCategory -int 0

# Sort Activity Monitor results by CPU usage
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

# ============================================
# TextEdit
# ============================================

# Use plain text mode for new TextEdit documents
defaults write com.apple.TextEdit RichText -int 0

# Open and save files as UTF-8 in TextEdit
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# ============================================
# Screenshots
# ============================================

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in PNG format
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# ============================================
# Hot Corners
# ============================================

# Top-left: None
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0

# Top-right: Quick Note
defaults write com.apple.dock wvous-tr-corner -int 14
defaults write com.apple.dock wvous-tr-modifier -int 0

# Bottom-left: None
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0

# Bottom-right: Screen Saver
defaults write com.apple.dock wvous-br-corner -int 5
defaults write com.apple.dock wvous-br-modifier -int 0

# ============================================
# Lock Screen
# ============================================

# Require password immediately after sleep/screensaver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# ============================================
# Energy & Display
# ============================================

# Battery: display sleep after 30 minutes
sudo pmset -b displaysleep 30

# Charger: display sleep after 60 minutes
sudo pmset -c displaysleep 60

# Charger: system never sleeps
sudo pmset -c sleep 0

# ============================================
# Hostname
# ============================================

# Load .env if available for HOSTNAME_NAME
if [ -z "$HOSTNAME_NAME" ]; then
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
    if [ -f "$DOTFILES_ROOT/.env.local" ]; then
        # shellcheck disable=SC1091
        source "$DOTFILES_ROOT/.env.local"
    elif [ -f "$DOTFILES_ROOT/.env" ]; then
        # shellcheck disable=SC1091
        source "$DOTFILES_ROOT/.env"
    fi
fi

if [ -n "$HOSTNAME_NAME" ]; then
    echo "Setting hostname to: $HOSTNAME_NAME"
    sudo scutil --set ComputerName "$HOSTNAME_NAME"
    sudo scutil --set HostName "$HOSTNAME_NAME"
    sudo scutil --set LocalHostName "$HOSTNAME_NAME"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$HOSTNAME_NAME"
fi

# ============================================
# Kill affected applications
# ============================================

echo "Restarting affected applications..."

for app in "Activity Monitor" \
    "Dock" \
    "Finder" \
    "Safari" \
    "SystemUIServer"; do
    killall "${app}" &> /dev/null || true
done

echo "✓ macOS defaults applied successfully!"
echo ""
echo "Some changes require a logout/restart to take effect."
