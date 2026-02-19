# Modern CLI Tools Guide

## 🍺 What is Homebrew Bundle (Brewfile)?

A **Brewfile** is like a `package.json` or `requirements.txt` for Homebrew. It lists all the packages you want installed, and you can install everything with one command:

```bash
brew bundle install --file=Brewfile
```

This makes it easy to:
- Set up a new Mac quickly
- Share your tool setup with teammates
- Keep track of what you have installed
- Restore your environment after reinstalling macOS

## 📦 What Gets Installed with Homebrew

When you install Homebrew, it also installs:
- **Xcode Command Line Tools** - Essential compilers and build tools (Git, make, clang, etc.)
- **Homebrew itself** - The package manager

## 🦀 Modern Rust-Based CLI Tools (Included in Brewfile)

### File Navigation & Search

| Old Tool | New Tool | Description | Command Example |
|----------|----------|-------------|-----------------|
| `ls` | **eza** | Modern ls with colors, icons, git integration | `eza --icons -l` |
| `find` | **fd** | Fast, user-friendly find | `fd pattern` |
| `grep` | **ripgrep** (rg) | Extremely fast recursive search | `rg "TODO"` |
| `cd` | **zoxide** (z) | Smart cd that learns your habits | `z projects` |
| `tree` | **broot** | Interactive tree navigator | `broot` |

### File Viewing & Processing

| Old Tool | New Tool | Description | Command Example |
|----------|----------|-------------|-----------------|
| `cat` | **bat** | Cat with syntax highlighting & line numbers | `bat file.py` |
| `hexdump` | **hexyl** | Modern hex viewer with colors | `hexyl binary_file` |
| `jq` | **jq** | JSON processor (not Rust, but essential) | `cat data.json \| jq '.key'` |

### System Monitoring

| Old Tool | New Tool | Description | Command Example |
|----------|----------|-------------|-----------------|
| `top`/`htop` | **bottom** (btm) | Beautiful system monitor | `btm` |
| `ps` | **procs** | Modern process viewer | `procs` |
| `du` | **dust** | Disk usage analyzer | `dust` |
| `df` | **duf** | Disk usage with nice formatting | `duf` |
| `iftop` | **bandwhich** | Network bandwidth monitor | `bandwhich` |

### Development Tools

| Tool | Description | Use Case |
|------|-------------|----------|
| **git-delta** | Better git diffs with syntax highlighting | `git diff` (auto-used) |
| **tokei** | Fast code statistics | `tokei` in any repo |
| **hyperfine** | Command benchmarking | `hyperfine 'command1' 'command2'` |
| **tealdeer** (tldr) | Simplified man pages | `tldr tar` |

### Text Processing

| Old Tool | New Tool | Description |
|----------|----------|-------------|
| `sed` | **sd** | Modern sed with easier syntax |
| `cut`/`awk` | **choose** | Simpler alternative to cut/awk |

### Network Tools

| Tool | Description | Example |
|------|-------------|---------|
| **dog** | Modern dig DNS lookup | `dog example.com` |
| **httpie** | Better curl/wget | `http GET api.github.com` |
| **gping** | Ping with graph | `gping google.com` |

## 🚀 Essential Developer Tools (Also Included)

### Version Control
- **git** - Latest version (not the outdated macOS one)
- **gh** - GitHub CLI for managing repos/PRs from terminal
- **git-delta** - Beautiful git diffs

### Version Managers
- **mise** - Universal version manager (replaces nvm, pyenv, rbenv, etc.)

### Shell Enhancements
- **zsh** - Latest Zsh shell
- **zsh-autosuggestions** - Fish-like autosuggestions
- **zsh-syntax-highlighting** - Syntax highlighting as you type
- **fzf** - Fuzzy finder (Ctrl+R for history, Ctrl+T for files)
- **oh-my-posh** - Beautiful, fast prompt themes

## 📊 Size Comparison (Why Rust Tools are Better)

```
Traditional Tools:
  grep:     ~200KB
  find:     ~100KB
  top:      ~50KB
  Total:    ~350KB, but often SLOWER

Modern Rust Tools:
  ripgrep:  ~5MB
  fd:       ~3MB
  bottom:   ~6MB
  Total:    ~14MB, but 10-100x FASTER
```

The slight size increase is worth it for the massive performance and UX improvements!

## 💡 Real-World Performance Differences

### Search Speed (ripgrep vs grep)
```bash
# Search entire Linux kernel source (~1GB)
time grep -r "TODO" linux/     # ~60 seconds
time rg "TODO" linux/           # ~3 seconds (20x faster!)
```

### File Finding (fd vs find)
```bash
# Find all Python files
time find . -name "*.py"        # ~5 seconds
time fd ".py$"                  # ~0.5 seconds (10x faster!)
```

### Disk Usage (dust vs du)
```bash
du -sh *                        # Plain text, hard to read
dust                            # Beautiful tree with colors and percentages
```

## 🎯 Recommended Aliases (Already Added by Script)

The setup script adds these to your `~/.zshrc`:

```bash
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first -l"
alias la="eza --icons --group-directories-first -la"
alias lt="eza --icons --group-directories-first --tree"
alias cat="bat --style=auto"
alias find="fd"
alias ps="procs"
alias top="btm"
alias du="dust"
alias df="duf"
alias ping="gping"
alias cd="z"  # zoxide - learns your most-used directories
```

## 📚 Learning the New Tools

### Quick Start Commands

```bash
# eza (better ls)
eza --icons -l              # List with icons
eza --icons -la             # Include hidden files
eza --icons --tree          # Tree view
eza --icons -l --git        # Show git status

# fd (better find)
fd pattern                  # Find files matching pattern
fd -e py                    # Find all .py files
fd -H pattern               # Include hidden files
fd -t f pattern             # Only files (not directories)

# ripgrep (better grep)
rg "TODO"                   # Find TODO in all files
rg "TODO" -g "*.py"         # Only in Python files
rg "TODO" -i                # Case insensitive
rg "TODO" -C 3              # Show 3 lines of context

# bat (better cat)
bat file.py                 # View with syntax highlighting
bat -l python file.txt      # Force Python highlighting
bat -A file.txt             # Show all characters (spaces, tabs)

# zoxide (smart cd)
z projects                  # Jump to most frequent projects dir
z foo bar                   # Jump to directory matching "foo" and "bar"
zi                          # Interactive selection with fzf

# fzf (fuzzy finder)
Ctrl+R                      # Search command history
Ctrl+T                      # Find files
Alt+C                       # cd into directory
kill -9 <TAB>               # Select process to kill

# bottom (better top)
btm                         # Launch
btm -b                      # Basic mode (less fancy)
btm --battery               # Show battery info

# dust (better du)
dust                        # Show disk usage
dust -d 2                   # Limit depth to 2
dust -r                     # Reverse order (biggest first)

# git-delta (better diffs)
git diff                    # Automatically uses delta
git log -p                  # Show patches with delta
git show                    # Show commit with delta
```

## 🔄 Managing Your Brewfile

### Create Brewfile from Current System
```bash
# Dump all installed packages to Brewfile
brew bundle dump

# Dump to specific file
brew bundle dump --file=~/dotfiles/Brewfile
```

### Install from Brewfile
```bash
# Install all packages
brew bundle install

# Install from specific file
brew bundle install --file=~/dotfiles/Brewfile
```

### Check Brewfile
```bash
# Check what's installed vs what's in Brewfile
brew bundle check

# Cleanup packages not in Brewfile
brew bundle cleanup
```

## 🎨 Alternative Prompt: Starship

The Brewfile includes **starship** as an alternative to Oh My Posh. It's also written in Rust and extremely fast.

To use starship instead:
```bash
# In ~/.zshrc, replace oh-my-posh line with:
eval "$(starship init zsh)"

# Configure starship
starship preset gruvbox-rainbow > ~/.config/starship.toml
```

## 🌟 Additional Tools Worth Knowing

### Not in Brewfile but Easy to Add

```bash
# Alternative ls with icons
brew install lsd

# JSON viewer
brew install fx

# Interactive git
brew install lazygit

# Directory bookmarks
brew install jump

# Better man pages
brew install tldr

# Terminal file manager
brew install ranger

# Database CLI tools
brew install pgcli    # PostgreSQL
brew install mycli    # MySQL
brew install litecli  # SQLite
```

## 📖 Resources

- [Homebrew](https://brew.sh/)
- [Homebrew Bundle](https://github.com/Homebrew/homebrew-bundle)
- [Modern Unix Tools](https://github.com/ibraheemdev/modern-unix)
- [eza](https://github.com/eza-community/eza)
- [fd](https://github.com/sharkdp/fd)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [bat](https://github.com/sharkdp/bat)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [bottom](https://github.com/ClementTsang/bottom)
- [delta](https://github.com/dandavison/delta)

## 💰 Performance vs Size Trade-off

**TL;DR**: Modern Rust tools are slightly larger but WAY faster and more user-friendly.

| Aspect | Traditional | Modern Rust |
|--------|-------------|-------------|
| Size | Small (~KB) | Larger (~MB) |
| Speed | Baseline | 5-100x faster |
| UX | Basic | Colors, icons, helpful |
| Memory | Lower | Slightly higher but safe |
| Installation | Built-in | One `brew bundle` |

On modern Macs with 8GB+ RAM, the size difference is negligible, but the speed and UX improvements are life-changing for daily development work.

---

**Last Updated**: 2026-02-04
