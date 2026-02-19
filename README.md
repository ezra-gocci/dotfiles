# dotfiles

macOS development environment — single command setup after factory reset.

## Quick Start

```bash
curl -fsSL https://raw.githubusercontent.com/ezra-gocci/dotfiles/main/bootstrap.sh | bash
```

Run this on a fresh macOS right after Setup Assistant completes. It installs everything automatically.

## What Happens

The bootstrap script runs through these phases:

1. **Xcode CLI Tools** — installed non-interactively
2. **Homebrew** — installed non-interactively
3. **Git + Ansible** — installed via Homebrew
4. **Dotfiles repo** — cloned to `~/.dotfiles`
5. **Ansible playbook** — configures the entire system:

| Step | What | How |
|------|------|-----|
| Packages | 50+ CLI tools, 15 GUI apps, 3 nerd fonts | `brew bundle` from Brewfile |
| Configs | zsh, git, nvim, tmux, starship, wezterm, atuin, btop, mise, zed, ssh, iterm2 | symlink / copy |
| Git | user, editor, delta pager, default branch | `git config` |
| Neovim | custom config with lazy.nvim | symlink |
| macOS | keyboard, trackpad, Finder, Dock, Safari, screenshots, energy, hot corners | `defaults write` + `pmset` |
| Dock | remove defaults, add preferred apps | `dockutil` |
| Claude | Code settings, Desktop config, project memory | file copy |
| Hostname | ComputerName, HostName, LocalHostName | `scutil` |

## Ansible Tags

Re-run specific parts without running everything:

```bash
cd ~/.dotfiles/ansible
ansible-playbook main.yml -i inventory.yml --tags dock --ask-become-pass
```

Available tags: `homebrew`, `dotfiles`, `git`, `neovim`, `macos`, `dock`, `claude`, `post-restore`

Dry run (preview changes): `ansible-playbook main.yml -i inventory.yml --check`

## Alternative: Bash-Only Install

If you prefer not to use Ansible, the standalone bash script still works:

```bash
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install gh && gh auth login
gh repo clone ezra-gocci/dotfiles ~/.dotfiles
cd ~/.dotfiles && ./install.sh
```

## Pre-Reset Backup

Before factory resetting, back up everything:

```bash
cd ~/.dotfiles
./scripts/backup.sh
```

Interactive 4-phase backup: inventory → selection → execute → manifest + push to GitHub.

| Item | Destination | Method |
|------|-------------|--------|
| Homebrew packages | `Brewfile` in repo | `brew bundle dump` |
| Dotfile configs | repo directories | file copy |
| SSH keys | iCloud | encrypted zip |
| Personal files | iCloud | `rsync` |
| Git repos | GitHub | verify pushed |
| Claude configs | repo `claude/` dir | file copy |
| App preferences | repo (iTerm2 plist) | `defaults export` |

## Repository Structure

```
dotfiles/
├── bootstrap.sh            # One-command setup (curl | bash)
├── install.sh              # Standalone bash restore (no Ansible)
├── ansible/
│   ├── main.yml            # Ansible playbook
│   ├── requirements.yml    # Galaxy dependencies
│   ├── inventory.yml       # localhost
│   ├── vars/main.yml       # All configurable variables
│   └── tasks/              # Task files (homebrew, dotfiles, git, etc.)
├── scripts/backup.sh       # Pre-reset backup
├── .env                    # Config toggles
├── Brewfile                # Homebrew packages
├── macos/defaults.sh       # macOS system defaults
├── zsh/.zshrc              # Shell config
├── git/.gitconfig          # Git config
├── nvim/                   # Neovim (init.lua + lazy-lock)
├── tmux/.tmux.conf         # tmux
├── starship/starship.toml  # Prompt
├── wezterm/wezterm.lua     # Terminal
├── atuin/config.toml       # Shell history
├── btop/btop.conf          # Resource monitor
├── mise/config.toml        # Language versions
├── zed/settings.json       # Zed editor
├── ssh/config              # SSH (no keys)
├── iterm2/                 # iTerm2 plist
├── claude/                 # Claude Code + Desktop configs
├── manifests/              # Backup manifests (JSON)
└── docs/                   # Guides
```

## Customization

Edit `ansible/vars/main.yml` for Ansible, or `.env` / `.env.local` for bash:

- **Dock apps** — change the app list and order
- **Hot corners** — configure all 4 corners (Mission Control, Desktop, Screen Saver, etc.)
- **Hostname** — set machine name
- **Energy** — display sleep timers for battery and charger
- **Config toggles** — enable/disable individual tool configs
- **Neovim** — choose between custom, LazyVim, kickstart, or none

## CLI Tools

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
