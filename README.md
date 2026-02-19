# dotfiles

macOS development environment provisioning with backup/restore for factory resets.

## What This Does

- Installs 50+ CLI tools, 15 GUI apps, and 3 nerd fonts via Homebrew
- Symlinks/copies config files for zsh, git, neovim, tmux, starship, wezterm, atuin, btop, mise, zed, iTerm2, SSH
- Restores Claude Code and Claude Desktop configurations
- Applies macOS system preferences
- Backs up everything to iCloud and GitHub before a factory reset

## Quick Start

### Fresh Install (after factory reset)

```bash
# 1. Install Xcode CLT
xcode-select --install

# 2. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 3. Install gh and authenticate
brew install gh
gh auth login

# 4. Clone and install
gh repo clone ezra-gocci/dotfiles ~/.dotfiles
cd ~/.dotfiles
cp .env .env.local   # customize if needed
./install.sh
```

### Pre-Reset Backup

```bash
cd ~/.dotfiles
./scripts/backup.sh
```

This runs an interactive 4-phase backup:
1. **Inventory** — scans your system and reports what's installed
2. **Selection** — numbered checklist to toggle what gets backed up
3. **Execute** — runs the selected backup functions
4. **Manifest** — creates a JSON manifest, commits, and pushes to GitHub

## What Gets Backed Up

| Item | Destination | Method |
|------|-------------|--------|
| Homebrew packages | `Brewfile` in repo | `brew bundle dump` |
| Dotfile configs | repo directories | file copy |
| SSH keys | iCloud | encrypted zip |
| Personal files | iCloud | `rsync` |
| Git repos | GitHub | verify pushed |
| Claude configs | repo `claude/` dir | file copy |
| App preferences | repo (iTerm2 plist) | `defaults export` |
| Credentials | iCloud | file copy |

## Repository Structure

```
dotfiles/
├── install.sh              # Post-reset restore script
├── scripts/
│   └── backup.sh           # Pre-reset backup script
├── .env                    # Configuration toggles
├── Brewfile                # Homebrew packages (52 formulae, 15 casks)
├── manifests/              # Backup manifests (JSON)
├── zsh/.zshrc              # Shell config
├── git/.gitconfig          # Git config
├── tmux/.tmux.conf         # tmux config
├── starship/starship.toml  # Prompt config
├── wezterm/wezterm.lua     # Terminal config
├── nvim/                   # Neovim config (init.lua + lazy-lock)
├── atuin/config.toml       # Shell history config
├── btop/btop.conf          # Resource monitor config
├── mise/config.toml        # Language version manager config
├── zed/settings.json       # Zed editor config
├── ssh/config              # SSH config (no keys)
├── iterm2/                 # iTerm2 preferences plist
├── claude/                 # Claude Code + Desktop configs
│   ├── claude-code/        # settings.json, settings.local.json
│   ├── claude-desktop/     # Desktop app config
│   └── project-memory/     # Per-project MEMORY.md files
├── macos/defaults.sh       # macOS system preferences
├── docs/                   # Setup guides
│   ├── BACKUP_RESTORE.md   # Detailed backup/restore guide
│   ├── QUICK_START.md
│   ├── TOOLS.md
│   ├── NEOVIM.md
│   ├── MISE_LANGUAGES.md
│   └── GITHUB_INSTALL.md
└── RESTORE-CHECKLIST.md    # Quick post-reset checklist
```

## Config Management

Configs are either **symlinked** or **copied** depending on whether the app rewrites the file:

| Config | Method | Reason |
|--------|--------|--------|
| `.zshrc`, `.gitconfig`, `.tmux.conf` | symlink | user-controlled |
| `starship.toml`, `wezterm.lua` | symlink | user-controlled |
| `atuin/config.toml`, `mise/config.toml` | symlink | user-controlled |
| `zed/settings.json` | symlink | user-controlled |
| `btop/btop.conf` | copy | btop rewrites on exit |
| `nvim/lazy-lock.json` | copy | lazy.nvim rewrites |
| `ssh/config` | copy | OrbStack appends entries |
| iTerm2 plist | `defaults import` | binary plist format |

## Configuration

All components are toggleable via `.env`. Copy to `.env.local` for local overrides:

```bash
cp .env .env.local
```

Key toggles:
- `INSTALL_*` — enable/disable individual tools
- `INSTALL_*_CONFIG` — enable/disable config file linking
- `NEOVIM_SETUP` — `custom`, `lazyvim`, `kickstart`, or `none`
- `APPLY_MACOS_DEFAULTS` — apply system preference tweaks
- `DRY_RUN` — preview changes without applying

## CLI Tools Included

Modern Rust-based replacements for standard Unix tools:

| Tool | Replaces | Description |
|------|----------|-------------|
| eza | ls | File listing with icons and git status |
| fd | find | Fast file finder |
| ripgrep | grep | Fast content search |
| bat | cat | Syntax-highlighted file viewer |
| zoxide | cd | Smart directory jumping |
| btop | top/htop | Resource monitor |
| dust | du | Disk usage visualizer |
| duf | df | Disk free viewer |
| procs | ps | Process viewer |
| git-delta | diff | Syntax-highlighted git diffs |
| sd | sed | Find and replace |
| tealdeer | man/tldr | Quick command help |
| hyperfine | time | Benchmarking |
| yazi | ranger | Terminal file manager |
| lazygit | git | Git TUI |
| atuin | history | Shell history with sync |

## License

MIT
