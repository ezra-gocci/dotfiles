# Backup & Restore Guide

Complete guide for backing up before a factory reset and restoring afterward.

## Pre-Reset: Backup

### 1. Run the backup script

```bash
cd ~/.dotfiles
./scripts/backup.sh
```

The script walks you through 4 phases:

**Phase 1: Inventory** — Scans your system and reports:
- Homebrew formulae, casks, and taps count
- Dotfile configs (found vs tracked in repo)
- SSH key pairs
- Git repos and their push status
- Personal file sizes (Documents, Music, Desktop)
- iCloud Drive availability
- Claude config sizes

**Phase 2: Selection** — Interactive checklist:
```
[x] 1. Homebrew packages → Brewfile
[x] 2. Dotfile configs → git commit
[x] 3. SSH keys → encrypted zip to iCloud
[x] 4. Personal files → rsync to iCloud
[x] 5. Git repos → verify all pushed
[x] 6. Claude configs → git commit
[x] 7. App preferences → export to dotfiles
[ ] 8. Credentials (kube/docker) → iCloud
```
Toggle items with their number. Press Enter to proceed.

**Phase 3: Execute** — Runs each selected backup function.

**Phase 4: Manifest** — Creates `manifests/backup-YYYYMMDD.json`, commits all changes, and pushes to GitHub.

### 2. Verify before reset

```bash
# Check iCloud backup exists
ls ~/Library/Mobile\ Documents/com~apple~CloudDocs/mac-backup-*/

# Check GitHub has latest
gh repo view ezra-gocci/dotfiles

# Verify manifest
cat ~/.dotfiles/manifests/backup-*.json | python3 -m json.tool
```

### 3. Important: Sign out order

1. Verify iCloud sync is complete
2. Sign out of apps (Steam, Telegram, etc.)
3. Sign out of iCloud **last** (after verifying sync)

---

## Post-Reset: Restore

### 1. Initial setup

```bash
# Sign into iCloud first — wait for sync
# Then install Xcode Command Line Tools
xcode-select --install

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH (Apple Silicon)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 2. Clone and run installer

```bash
# Install gh first
brew install gh
gh auth login

# Clone dotfiles
gh repo clone ezra-gocci/dotfiles ~/.dotfiles
cd ~/.dotfiles

# Optional: customize config
cp .env .env.local
# edit .env.local if needed

# Run installer
./install.sh
```

The installer handles:
- Installing all Homebrew packages from Brewfile
- Symlinking/copying all config files
- Setting up Neovim
- Applying macOS defaults
- Restoring Claude configs
- Printing post-restore guidance

### 3. Restore SSH keys

```bash
# Find the encrypted backup in iCloud
ls ~/Library/Mobile\ Documents/com~apple~CloudDocs/mac-backup-*/ssh-keys-encrypted.zip

# Unzip (enter your backup password)
cd ~/.ssh
unzip ~/Library/Mobile\ Documents/com~apple~CloudDocs/mac-backup-*/ssh-keys-encrypted.zip

# Fix permissions
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub

# Add to agent
ssh-add ~/.ssh/id_ed25519
```

### 4. Clone repos

```bash
mkdir -p ~/Code && cd ~/Code
gh repo clone ezra-gocci/fast-forward
gh repo clone ezra-gocci/cv
gh repo clone ezra-gocci/beat-em
gh repo clone ezra-gocci/lets-dance
gh repo clone ezra-gocci/investsmart
gh repo clone ezra-gocci/claude-vault
gh repo clone ezra-gocci/perfect-start
gh repo clone ezra-gocci/leet
```

### 5. App logins

- Claude Desktop — sign in with Anthropic account
- Claude Code — `claude login`
- Tailscale — `tailscale up`
- Steam, Telegram, Obsidian — sign in manually
- Google Chrome — sign in to sync bookmarks/extensions

---

## What's Preserved vs Gone

### Preserved (available after restore)

- All CLI tools and GUI apps (via Brewfile)
- Shell, git, editor, terminal configs (via dotfiles)
- Claude Code settings, permissions, project memory
- Claude Desktop config
- SSH keys (encrypted in iCloud)
- Personal files (Documents, Music, Desktop in iCloud)
- All code repos (on GitHub)
- macOS system preferences (via defaults.sh)
- iTerm2 preferences (via plist export)
- Backup manifest with full system inventory

### Gone (expected — fresh start)

- Claude Code session history in UI
- Claude Desktop chat history in UI
- Cowork task history in UI
- Local caches, debug logs
- Browser sessions/cookies (Chrome syncs most via account)
- App-specific local state
- Docker images/containers (rebuild from Dockerfiles)

---

## Manifest Format

Each backup creates a JSON manifest in `manifests/`:

```json
{
  "schema_version": "1.0",
  "created_at": "2026-02-19T12:00:00Z",
  "machine": {
    "hostname": "MacBook-Pro",
    "macos_version": "15.3",
    "chip": "Apple M1"
  },
  "backup_items": {
    "brewfile": { "saved": true, "formulae_count": 52 },
    "configs": { "saved": true },
    "ssh_keys": { "saved": true, "location": "icloud", "encrypted": true },
    "personal_files": { "saved": true, "location": "icloud" },
    "git_repos": { "verified": true },
    "claude": { "saved": true },
    "app_prefs": { "saved": true },
    "credentials": { "saved": false, "location": "icloud" }
  }
}
```
