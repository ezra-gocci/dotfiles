# 🚀 Quick Start Guide

Get up and running with your new development environment in 5 minutes.

## 📋 Table of Contents

- [Installation](#installation)
- [First Launch](#first-launch)
- [Testing Tools](#testing-tools)
- [Neovim Setup](#neovim-setup)
- [Common Tasks](#common-tasks)

---

## 🎯 Installation

### Step 1: Run the Installer

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/install.sh | bash
```

**What happens:**
1. Installs Xcode Command Line Tools (if needed)
2. Installs Homebrew (if needed)
3. Installs all packages from Brewfile
4. Sets up all dotfiles
5. Configures Neovim IDE
6. Backs up existing configs

**Time**: ~10-15 minutes (depending on internet speed)

### Step 2: Restart Terminal

```bash
# Option 1: Source the new config
source ~/.zshrc

# Option 2: Close and reopen terminal

# Option 3: Launch WezTerm
open -a WezTerm
```

---

## 🎨 First Launch

### WezTerm

1. **Launch WezTerm:**
   ```bash
   open -a WezTerm
   ```

2. **Verify theme:**
   - Should see Gruvbox Hard Dark colors
   - FiraCode Nerd Font with ligatures
   - GPU-accelerated rendering

3. **Test shortcuts:**
   - `⌘T` → New tab
   - `⌘D` → Split horizontally
   - `⌘⇧D` → Split vertically

### Starship Prompt

Your prompt should now show:
```
  ~/code/project main
❯ 
```

Features:
- 📁 Current directory
- 🌳 Git branch and status
- 🐍 Python version (when in Python project)
- ⚡ Fast loading (<1ms)

---

## 🧪 Testing Tools

### Test Each Tool (Copy-Paste These)

```bash
# ═══════════════════════════════════════════════════
# Modern CLI Tools Test Suite
# ═══════════════════════════════════════════════════

# 1. eza (modern ls)
echo "━━━ Testing eza (ls replacement) ━━━"
eza --icons --long --git
eza --tree --level=2
ll  # alias for eza --icons -l
la  # alias for eza --icons -la

# 2. fd (modern find)
echo "━━━ Testing fd (find replacement) ━━━"
fd README  # Find files named README
fd -e md   # Find all .md files
fd -H .git # Find hidden files

# 3. ripgrep (modern grep)
echo "━━━ Testing ripgrep (grep replacement) ━━━"
rg "TODO"           # Search for TODO
rg "function" -g "*.js"  # Search in JS files only
rg "import" -t py   # Search in Python files

# 4. bat (modern cat)
echo "━━━ Testing bat (cat replacement) ━━━"
bat README.md       # View file with syntax highlighting
bat -l python test.py  # Force Python syntax
cat README.md       # Now uses bat (aliased)

# 5. zoxide (smart cd)
echo "━━━ Testing zoxide (cd replacement) ━━━"
z ~                 # Jump to home
z dotfiles          # Jump to dotfiles (learns from history)
zi                  # Interactive directory selection

# 6. bottom (modern top)
echo "━━━ Testing bottom (top replacement) ━━━"
btm                 # Launch system monitor
# Press 'q' to quit

# 7. procs (modern ps)
echo "━━━ Testing procs (ps replacement) ━━━"
procs               # View all processes
procs chrome        # Find Chrome processes

# 8. dust (modern du)
echo "━━━ Testing dust (du replacement) ━━━"
dust                # Disk usage
dust -d 2           # Limit depth to 2

# 9. duf (modern df)
echo "━━━ Testing duf (df replacement) ━━━"
duf                 # Disk usage by filesystem

# 10. git-delta (better diffs)
echo "━━━ Testing git-delta ━━━"
git diff            # Now shows beautiful diffs
git log -p          # Logs with delta

# 11. tokei (code statistics)
echo "━━━ Testing tokei ━━━"
tokei               # Code statistics for current directory

# 12. hyperfine (benchmarking)
echo "━━━ Testing hyperfine ━━━"
hyperfine 'eza' 'ls'  # Compare speed of commands

# 13. tealdeer (tldr - simplified man pages)
echo "━━━ Testing tealdeer ━━━"
tldr tar            # Quick tar examples
tldr git            # Quick git examples

# 14. sd (modern sed)
echo "━━━ Testing sd ━━━"
echo "hello world" | sd "world" "universe"

# 15. hexyl (hex viewer)
echo "━━━ Testing hexyl ━━━"
echo "Hello" | hexyl

# 16. gping (ping with graph)
echo "━━━ Testing gping ━━━"
gping google.com    # Press Ctrl+C to stop

# 17. bandwhich (network monitor)
echo "━━━ Testing bandwhich ━━━"
sudo bandwhich      # Requires sudo, press 'q' to quit

echo ""
echo "✓ All tools tested successfully!"
```

### Quick Tool Reference

```bash
# File Operations
ll              # List files (eza)
la              # List all files including hidden
lt              # Tree view
fd "pattern"    # Find files

# Text Search
rg "pattern"    # Search in files
bat file.txt    # View file with syntax

# Navigation
z directory     # Smart cd
zi              # Interactive cd

# System Monitoring
btm             # System monitor
procs           # Process viewer
duf             # Disk usage

# Development
tokei           # Code statistics
git diff        # Beautiful diffs
tldr command    # Quick examples
```

---

## 🛠️ Neovim Setup

### First Launch

```bash
nvim
```

**What happens:**
1. Plugins auto-install (1-2 minutes)
2. LazyVim welcome screen appears
3. Wait for "Mason" to finish installing LSP servers

### Install Language Support

```vim
:LazyExtras
```

Navigate and select (press `x` to toggle):
- ✅ `lang.python` - Python support
- ✅ `lang.typescript` - TypeScript/JavaScript  
- ✅ `lang.rust` - Rust
- ✅ `lang.go` - Go
- ✅ `lang.json` - JSON
- ✅ `lang.yaml` - YAML
- ✅ `lang.markdown` - Markdown

Press `Enter` to install selected.

### Test Neovim Features

1. **Create a test file:**
   ```bash
   nvim test.py
   ```

2. **Test auto-completion:**
   ```python
   # Type this and watch IntelliSense
   import os
   os.  # <-- Auto-completion appears!
   ```

3. **Test LSP:**
   - Hover over a function: Press `K`
   - Go to definition: Press `gd`
   - Find references: Press `gr`

4. **Test file explorer:**
   - Press `<leader>e` (Space + e)
   - Navigate with `j`/`k`
   - Open file with `Enter`

5. **Test fuzzy finder:**
   - Press `<leader>ff` (Space + ff)
   - Type to search files
   - Press `Enter` to open

6. **Test Git integration:**
   - Press `<leader>gg` (Space + gg)
   - LazyGit TUI opens
   - Press `q` to quit

### Neovim Essential Shortcuts

```
NAVIGATION:
h/j/k/l     - Left/Down/Up/Right
w/b         - Forward/Backward word
gg/G        - Top/Bottom of file
0/$         - Start/End of line

EDITING:
i           - Insert mode
Esc         - Normal mode
dd          - Delete line
yy          - Copy line
p           - Paste

FILE OPERATIONS:
<leader>e   - Toggle file tree
<leader>ff  - Find files
<leader>fg  - Search in files
<leader>w   - Save file
<leader>q   - Quit

LSP:
gd          - Go to definition
gr          - Find references
K           - Hover documentation
<leader>ca  - Code actions
<leader>rn  - Rename

GIT:
<leader>gg  - LazyGit
<leader>hp  - Preview diff hunk
]c          - Next change
[c          - Previous change

DEBUGGING:
F5          - Start/Continue
F10         - Step over
F11         - Step into
<leader>b   - Toggle breakpoint
```

---

## 📋 Common Tasks

### Task 1: Open a Project

```bash
# Navigate to project
cd ~/code/my-project

# Open in Neovim
nvim .

# File tree opens automatically
# Press <leader>ff to find files
```

### Task 2: Search Project

```bash
# In Neovim: <leader>fg (Space + f + g)
# Type search term
# Press Enter to jump to match

# Or from terminal:
rg "function_name"
```

### Task 3: Debug Code

```bash
# Open file in Neovim
nvim script.py

# Set breakpoint: <leader>b
# Start debugging: F5
# Step through: F10 (over), F11 (into)
```

### Task 4: Git Workflow

```bash
# In Neovim: <leader>gg (LazyGit opens)

# Or from terminal:
git status           # Status
git add .           # Stage all
git commit -m "msg" # Commit
git push            # Push
```

### Task 5: Install New Package

```bash
# Add to Brewfile
echo 'brew "package-name"' >> ~/.dotfiles/Brewfile

# Install
cd ~/.dotfiles
brew bundle install
```

### Task 6: Update Everything

```bash
# Update Homebrew packages
brew update && brew upgrade

# Update Neovim plugins
nvim +Lazy sync +qa

# Update dotfiles
cd ~/.dotfiles && git pull
```

---

## 🎓 Learning Resources

### Neovim
```vim
:Tutor          " Built-in interactive tutorial (30 min)
:help nvim      " Complete documentation
:checkhealth    " Diagnose issues
```

### Tools
```bash
tldr eza        # Quick examples for any tool
man eza         # Full manual
eza --help      # Command help
```

### Starship
```bash
starship explain  # Explain current prompt
starship config   # Open config file
```

---

## ✅ Verification Checklist

After installation, verify:

- [ ] WezTerm launches with Gruvbox theme
- [ ] Starship prompt shows git info
- [ ] `ll` shows icons and colors
- [ ] `bat README.md` has syntax highlighting
- [ ] `z ~` works (zoxide)
- [ ] `nvim` launches LazyVim
- [ ] `gd` works in Neovim (go to definition)
- [ ] `<leader>e` opens file tree
- [ ] `<leader>gg` opens LazyGit

---

## 🆘 Quick Troubleshooting

### Command Not Found

```bash
# Reload shell config
source ~/.zshrc

# Check if tool is installed
which eza  # Should show path

# Reinstall if needed
brew install eza
```

### Neovim Issues

```bash
# Check health
nvim +checkhealth

# Reinstall plugins
nvim +Lazy clean +Lazy sync +qa

# Reset Neovim
rm -rf ~/.local/share/nvim ~/.cache/nvim
nvim  # Reinstalls everything
```

### Permission Issues

```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) $(brew --prefix)/*
```

---

## 🎉 Next Steps

1. ✅ Read [Tool Reference](TOOLS.md) for detailed tool guides
2. ✅ Read [Neovim Guide](NEOVIM.md) for advanced features
3. ✅ Customize [your setup](CUSTOMIZATION.md)
4. ✅ Learn [all keybindings](KEYBINDINGS.md)

---

**Estimated time to productive:** 30 minutes  
**Estimated time to master:** 2-4 weeks  
**Worth it?** Absolutely! 🚀
