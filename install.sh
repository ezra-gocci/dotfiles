#!/bin/bash
#
# macOS Development Environment Setup
# 
# Two installation methods:
#
# Method 1 (Recommended): Download and run locally
#   curl -fsSL https://raw.githubusercontent.com/ezra-gocci/dotfiles/main/install.sh -o install.sh
#   chmod +x install.sh
#   ./install.sh
#
# Method 2: Direct pipe (requires sudo password before running)
#   sudo -v && curl -fsSL https://raw.githubusercontent.com/ezra-gocci/dotfiles/main/install.sh | bash
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/ezra-gocci/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# ============================================
# Check if running with TTY
# ============================================

if [ ! -t 0 ]; then
    echo -e "${RED}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ⚠️  WARNING: Non-interactive mode detected              ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo ""
    echo -e "${YELLOW}You're running this script via pipe (curl | bash)${NC}"
    echo -e "${YELLOW}This prevents sudo password prompts from working.${NC}"
    echo ""
    echo -e "${CYAN}Recommended installation method:${NC}"
    echo ""
    echo "  1. Download the script first:"
    echo -e "     ${GREEN}curl -fsSL https://raw.githubusercontent.com/ezra-gocci/dotfiles/main/install.sh -o install.sh${NC}"
    echo ""
    echo "  2. Make it executable:"
    echo -e "     ${GREEN}chmod +x install.sh${NC}"
    echo ""
    echo "  3. Run it:"
    echo -e "     ${GREEN}./install.sh${NC}"
    echo ""
    echo -e "${CYAN}Alternative (if you trust this script):${NC}"
    echo ""
    echo "  Pre-authenticate sudo and pipe:"
    echo -e "     ${GREEN}sudo -v && curl -fsSL https://raw.githubusercontent.com/ezra-gocci/dotfiles/main/install.sh | bash${NC}"
    echo ""
    exit 1
fi

echo -e "${BLUE}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   macOS Development Environment Setup                     ║
║   Modern Rust Tools + Neovim IDE + WezTerm               ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# ============================================
# Helper Functions
# ============================================

print_step() {
    echo ""
    echo -e "${BLUE}▶ $1${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

should_install() {
    local var_name="INSTALL_${1}"
    local value="${!var_name:-true}"
    [[ "$value" == "true" ]]
}

# ============================================
# Load Initial Configuration
# ============================================

print_step "Loading initial configuration"

# Try to load config from current directory first (if running from dotfiles dir)
if [ -f ".env" ]; then
    source ".env"
    print_success "Loaded configuration from current directory"
fi

# Try to load from existing dotfiles directory
if [ -f "$HOME/.dotfiles/.env" ]; then
    source "$HOME/.dotfiles/.env"
    print_success "Loaded configuration from $HOME/.dotfiles"
fi

# Load any local overrides
if [ -f ".env.local" ]; then
    source ".env.local"
    print_success "Loaded local configuration overrides"
fi

if [ -f "$HOME/.dotfiles/.env.local" ]; then
    source "$HOME/.dotfiles/.env.local"
    print_success "Loaded local configuration from $HOME/.dotfiles"
fi

# Update DOTFILES_REPO from config if set
if [ -n "$DOTFILES_REPO_URL" ]; then
    DOTFILES_REPO="$DOTFILES_REPO_URL"
fi
: "${DOTFILES_REPO:=https://github.com/ezra-gocci/dotfiles.git}"

print_success "Repository URL: $DOTFILES_REPO"

# ============================================
# Clone or Update Repository
# ============================================

print_step "Setting up dotfiles repository"

# Clone or update dotfiles first to get configuration
if [ -d "$DOTFILES_DIR" ]; then
    print_warning "Dotfiles directory already exists, updating..."
    cd "$DOTFILES_DIR"
    git pull || print_warning "Could not update repository (continuing anyway)"
else
    print_warning "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR" || {
        print_error "Failed to clone dotfiles repository"
        print_warning "Make sure the repository URL is correct: $DOTFILES_REPO"
        print_warning "If this is a private repo, you need to authenticate first"
        exit 1
    }
    cd "$DOTFILES_DIR"
fi

# ============================================
# Load Configuration from Cloned Repository
# ============================================

print_step "Loading configuration from repository"

# Load default config
if [ -f ".env" ]; then
    source ".env"
    print_success "Loaded default configuration"
fi

# Load local config (overrides defaults)
if [ -f ".env.local" ]; then
    source ".env.local"
    print_success "Loaded local configuration"
fi

# Set defaults if not configured
: "${INSTALL_HOMEBREW:=true}"
: "${INSTALL_GIT:=true}"
: "${INSTALL_NEOVIM:=true}"
: "${INSTALL_MISE:=true}"
: "${INSTALL_STARSHIP:=true}"
: "${INSTALL_WEZTERM:=true}"
: "${BACKUP_EXISTING:=true}"
: "${SKIP_PROMPTS:=false}"
: "${VERBOSE:=false}"
: "${DRY_RUN:=false}"

# Git defaults
: "${GIT_USER_NAME:=Your Name}"
: "${GIT_USER_EMAIL:=your.email@example.com}"

if [ "$DRY_RUN" == "true" ]; then
    print_warning "DRY RUN MODE - No changes will be made"
fi

# ============================================
# Step 1: Check Requirements
# ============================================

print_step "Step 1: Checking system requirements"

if [[ ! "$OSTYPE" == "darwin"* ]]; then
    print_error "This script is for macOS only"
    exit 1
fi

macos_version=$(sw_vers -productVersion)
print_success "macOS version: $macos_version"

if ! ping -c 1 github.com &> /dev/null; then
    print_error "No internet connection detected"
    exit 1
fi

print_success "Internet connection: OK"

# ============================================
# Step 2: Request sudo access upfront
# ============================================

print_step "Step 2: Requesting administrator access"

echo ""
echo -e "${YELLOW}This script needs administrator access to:${NC}"
echo "  • Install Xcode Command Line Tools (if needed)"
echo "  • Install Homebrew (if needed)"
echo "  • Configure system settings"
echo ""

if ! sudo -v; then
    print_error "Administrator access required"
    exit 1
fi

print_success "Administrator access granted"

# Keep sudo alive throughout the script
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ============================================
# Step 3: Install Xcode Command Line Tools
# ============================================

print_step "Step 3: Installing Xcode Command Line Tools"

if xcode-select -p &> /dev/null; then
    print_success "Xcode Command Line Tools already installed"
else
    if [ "$DRY_RUN" == "false" ]; then
        print_warning "Installing Xcode Command Line Tools..."
        
        # Create a temporary file for the touch command
        touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
        
        # Find the Command Line Tools package
        PROD=$(softwareupdate -l | grep "\*.*Command Line" | tail -n 1 | sed 's/^[^C]* //')
        
        if [ -n "$PROD" ]; then
            softwareupdate -i "$PROD" --verbose
        else
            print_warning "Using xcode-select method..."
            xcode-select --install
            
            # Wait for installation (with timeout)
            echo "Waiting for Xcode Command Line Tools installation..."
            echo "Please click 'Install' in the popup window."
            
            timeout=300  # 5 minutes timeout
            elapsed=0
            while ! xcode-select -p &> /dev/null; do
                sleep 5
                elapsed=$((elapsed + 5))
                if [ $elapsed -ge $timeout ]; then
                    print_error "Installation timeout. Please install manually and run again."
                    exit 1
                fi
            done
        fi
        
        rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    fi
    print_success "Xcode Command Line Tools installed"
fi

# ============================================
# Step 4: Install Homebrew
# ============================================

print_step "Step 4: Installing Homebrew"

if command_exists brew; then
    print_success "Homebrew already installed"
    if [ "$DRY_RUN" == "false" ]; then
        print_warning "Updating Homebrew..."
        brew update
    fi
elif should_install "HOMEBREW"; then
    if [ "$DRY_RUN" == "false" ]; then
        print_warning "Installing Homebrew..."
        
        # Install Homebrew non-interactively
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    print_success "Homebrew installed"
else
    print_warning "Skipping Homebrew installation (disabled in config)"
fi

# ============================================
# Step 5: Verify Git Remote
# ============================================

print_step "Step 5: Verifying Git remote"

cd "$DOTFILES_DIR"

if [ "$DRY_RUN" == "false" ]; then
    git remote set-url origin "$DOTFILES_REPO" 2>/dev/null || true
fi
print_success "Origin remote: $DOTFILES_REPO"

# ============================================
# Step 6: Backup Existing Dotfiles
# ============================================

print_step "Step 6: Backing up existing dotfiles"

if [ "$BACKUP_EXISTING" == "true" ]; then
    mkdir -p "$BACKUP_DIR"
    
    files_to_backup=(
        "$HOME/.zshrc"
        "$HOME/.gitconfig"
        "$HOME/.tmux.conf"
        "$HOME/.config/nvim"
        "$HOME/.config/wezterm"
        "$HOME/.config/starship.toml"
        "$HOME/.config/atuin/config.toml"
        "$HOME/.config/btop/btop.conf"
        "$HOME/.config/mise/config.toml"
        "$HOME/.config/zed/settings.json"
        "$HOME/.ssh/config"
        "$HOME/.claude"
    )
    
    for file in "${files_to_backup[@]}"; do
        if [ -e "$file" ] && [ "$DRY_RUN" == "false" ]; then
            cp -r "$file" "$BACKUP_DIR/" 2>/dev/null || true
            print_warning "Backed up: $file"
        fi
    done
    
    print_success "Backups saved to: $BACKUP_DIR"
else
    print_warning "Skipping backup (disabled in config)"
fi

# ============================================
# Step 7: Install Packages from Brewfile
# ============================================

print_step "Step 7: Installing packages"

if [ -f "$DOTFILES_DIR/Brewfile" ] && [ "$DRY_RUN" == "false" ]; then
    # Create filtered Brewfile based on config
    TEMP_BREWFILE="/tmp/dotfiles_brewfile_filtered"
    > "$TEMP_BREWFILE"
    
    while IFS= read -r line; do
        install_line="true"
        
        # Check if line should be included based on config
        case "$line" in
            *"eza"*) should_install "EZA" || install_line="false" ;;
            *"fd"*) should_install "FD" || install_line="false" ;;
            *"ripgrep"*) should_install "RIPGREP" || install_line="false" ;;
            *"bat"*) should_install "BAT" || install_line="false" ;;
            *"zoxide"*) should_install "ZOXIDE" || install_line="false" ;;
            *"bottom"*) should_install "BOTTOM" || install_line="false" ;;
            *"neovim"*) should_install "NEOVIM" || install_line="false" ;;
            *"starship"*) should_install "STARSHIP" || install_line="false" ;;
            *"wezterm"*) should_install "WEZTERM" || install_line="false" ;;
            *"mise"*) should_install "MISE" || install_line="false" ;;
        esac
        
        if [ "$install_line" == "true" ]; then
            echo "$line" >> "$TEMP_BREWFILE"
        fi
    done < "$DOTFILES_DIR/Brewfile"
    
    brew bundle install --file="$TEMP_BREWFILE"
    rm "$TEMP_BREWFILE"
    print_success "Packages installed"
else
    print_warning "Skipping package installation"
fi

# ============================================
# Step 8: Configure Git
# ============================================

print_step "Step 8: Configuring Git"

if [ "$GIT_USER_NAME" != "Your Name" ] && [ "$GIT_USER_EMAIL" != "your.email@example.com" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        git config --global user.name "$GIT_USER_NAME"
        git config --global user.email "$GIT_USER_EMAIL"
        git config --global core.editor "nvim"
        git config --global core.pager "delta"
        git config --global interactive.diffFilter "delta --color-only"
        git config --global delta.navigate "true"
        git config --global delta.light "false"
        git config --global delta.side-by-side "true"
        git config --global delta.line-numbers "true"
    fi
    print_success "Git configured: $GIT_USER_NAME <$GIT_USER_EMAIL>"
else
    print_warning "Git user info not configured - please update .env file"
fi

# ============================================
# Step 9: Install Dotfiles
# ============================================

print_step "Step 9: Installing dotfiles"

mkdir -p "$HOME/.config/wezterm"
mkdir -p "$HOME/.config/nvim"
mkdir -p "$HOME/.config/atuin"
mkdir -p "$HOME/.config/btop"
mkdir -p "$HOME/.config/mise"
mkdir -p "$HOME/.config/zed"
mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/.claude"

if [ "$INSTALL_ZSHRC" == "true" ] && [ -f "$DOTFILES_DIR/zsh/.zshrc" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        ln -sf "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    fi
    print_success "Linked .zshrc"
fi

if [ "$INSTALL_WEZTERM_CONFIG" == "true" ] && [ -f "$DOTFILES_DIR/wezterm/wezterm.lua" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        ln -sf "$DOTFILES_DIR/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
    fi
    print_success "Linked WezTerm config"
fi

if [ "$INSTALL_STARSHIP_CONFIG" == "true" ] && [ -f "$DOTFILES_DIR/starship/starship.toml" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        ln -sf "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
    fi
    print_success "Linked Starship config"
fi

if [ "$INSTALL_GITCONFIG" == "true" ] && [ -f "$DOTFILES_DIR/git/.gitconfig" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        ln -sf "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
    fi
    print_success "Linked .gitconfig"
fi

if [ "$INSTALL_TMUX_CONFIG" == "true" ] && [ -f "$DOTFILES_DIR/tmux/.tmux.conf" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"
    fi
    print_success "Linked tmux config"
fi

if [ "$INSTALL_ATUIN_CONFIG" == "true" ] && [ -f "$DOTFILES_DIR/atuin/config.toml" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        ln -sf "$DOTFILES_DIR/atuin/config.toml" "$HOME/.config/atuin/config.toml"
    fi
    print_success "Linked Atuin config"
fi

if [ "$INSTALL_BTOP_CONFIG" == "true" ] && [ -f "$DOTFILES_DIR/btop/btop.conf" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        cp "$DOTFILES_DIR/btop/btop.conf" "$HOME/.config/btop/btop.conf"
    fi
    print_success "Copied btop config (btop rewrites this file)"
fi

if [ "$INSTALL_MISE_CONFIG" == "true" ] && [ -f "$DOTFILES_DIR/mise/config.toml" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        ln -sf "$DOTFILES_DIR/mise/config.toml" "$HOME/.config/mise/config.toml"
    fi
    print_success "Linked mise config"
fi

if [ "$INSTALL_ZED_CONFIG" == "true" ] && [ -f "$DOTFILES_DIR/zed/settings.json" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        ln -sf "$DOTFILES_DIR/zed/settings.json" "$HOME/.config/zed/settings.json"
    fi
    print_success "Linked Zed config"
fi

if [ "$INSTALL_SSH_CONFIG" == "true" ] && [ -f "$DOTFILES_DIR/ssh/config" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        cp "$DOTFILES_DIR/ssh/config" "$HOME/.ssh/config"
        chmod 644 "$HOME/.ssh/config"
    fi
    print_success "Copied SSH config (OrbStack may modify this file)"
fi

if [ "$INSTALL_ITERM2_CONFIG" == "true" ] && [ -f "$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        defaults import com.googlecode.iterm2 "$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist"
    fi
    print_success "Imported iTerm2 preferences"
fi

# ============================================
# Step 10: Setup Neovim
# ============================================

print_step "Step 10: Setting up Neovim"

if [ "$INSTALL_NEOVIM_CONFIG" == "true" ] && [ "$DRY_RUN" == "false" ]; then
    case "$NEOVIM_SETUP" in
        "lazyvim")
            print_warning "Installing LazyVim..."
            rm -rf "$HOME/.config/nvim"
            git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
            rm -rf "$HOME/.config/nvim/.git"
            print_success "LazyVim installed"
            ;;
        "kickstart")
            print_warning "Installing Kickstart.nvim..."
            rm -rf "$HOME/.config/nvim"
            git clone https://github.com/nvim-lua/kickstart.nvim.git "$HOME/.config/nvim"
            print_success "Kickstart.nvim installed"
            ;;
        "custom")
            if [ -d "$DOTFILES_DIR/nvim" ]; then
                rm -rf "$HOME/.config/nvim"
                ln -sf "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
                print_success "Custom Neovim config linked"
            fi
            ;;
        "none")
            print_warning "Skipping Neovim configuration"
            ;;
    esac
fi

# ============================================
# Step 11: Apply macOS Defaults
# ============================================

print_step "Step 11: Applying macOS defaults"

if [ "$APPLY_MACOS_DEFAULTS" == "true" ] && [ -f "$DOTFILES_DIR/macos/defaults.sh" ]; then
    if [ "$DRY_RUN" == "false" ]; then
        bash "$DOTFILES_DIR/macos/defaults.sh"
    fi
    print_success "macOS defaults applied"
else
    print_warning "Skipping macOS defaults"
fi

# ============================================
# Step 11.5: Configure Dock
# ============================================

print_step "Step 11.5: Configuring Dock"

if [ "$CONFIGURE_DOCK" == "true" ] && command -v dockutil >/dev/null 2>&1; then
    if [ "$DRY_RUN" == "false" ]; then
        # Remove all default Dock items
        dockutil --remove all --no-restart 2>/dev/null || true

        # Add preferred apps (skip if not installed)
        dock_apps=(
            "/System/Applications/Launchpad.app"
            "/Applications/WezTerm.app"
            "/Applications/Google Chrome.app"
            "/Applications/Claude.app"
            "/Applications/Obsidian.app"
            "/Applications/iTerm.app"
            "/Applications/Zed.app"
            "/System/Applications/System Settings.app"
        )

        for app in "${dock_apps[@]}"; do
            if [ -d "$app" ]; then
                dockutil --add "$app" --no-restart 2>/dev/null || true
            fi
        done

        # Restart Dock to apply
        killall Dock 2>/dev/null || true
    fi
    print_success "Dock configured with preferred apps"
elif [ "$CONFIGURE_DOCK" != "true" ]; then
    print_warning "Skipping Dock configuration (disabled)"
else
    print_warning "Skipping Dock configuration (dockutil not installed)"
fi

# ============================================
# Step 12: Restore Claude Configs
# ============================================

print_step "Step 12: Restoring Claude configs"

if [ "$INSTALL_CLAUDE_CONFIG" == "true" ]; then
    # Claude Code settings
    if [ -f "$DOTFILES_DIR/claude/claude-code/settings.json" ]; then
        if [ "$DRY_RUN" == "false" ]; then
            cp "$DOTFILES_DIR/claude/claude-code/settings.json" "$HOME/.claude/settings.json"
        fi
        print_success "Restored Claude Code settings.json"
    fi

    if [ -f "$DOTFILES_DIR/claude/claude-code/settings.local.json" ]; then
        if [ "$DRY_RUN" == "false" ]; then
            cp "$DOTFILES_DIR/claude/claude-code/settings.local.json" "$HOME/.claude/settings.local.json"
        fi
        print_success "Restored Claude Code settings.local.json"
    fi

    # Claude Desktop config
    if [ -d "$DOTFILES_DIR/claude/claude-desktop" ]; then
        if [ "$DRY_RUN" == "false" ]; then
            mkdir -p "$HOME/Library/Application Support/Claude"
            for f in "$DOTFILES_DIR/claude/claude-desktop"/*.json; do
                [ -f "$f" ] && cp "$f" "$HOME/Library/Application Support/Claude/"
            done
        fi
        print_success "Restored Claude Desktop config"
    fi

    # Project memory files
    if [ -d "$DOTFILES_DIR/claude/project-memory" ]; then
        if [ "$DRY_RUN" == "false" ]; then
            for memdir in "$DOTFILES_DIR/claude/project-memory"/*/; do
                project_name=$(basename "$memdir")
                # Create the project memory directory using the current username
                target_dir="$HOME/.claude/projects/-Users-$(whoami)-Code-${project_name}/memory"
                mkdir -p "$target_dir"
                if [ -f "${memdir}MEMORY.md" ]; then
                    cp "${memdir}MEMORY.md" "$target_dir/"
                fi
            done
        fi
        print_success "Restored Claude project memory files"
    fi
else
    print_warning "Skipping Claude config restoration"
fi

# ============================================
# Step 13: Post-Restore Guidance
# ============================================

print_step "Step 13: Post-restore reminders"

echo ""
echo -e "${YELLOW}🔑 SSH Keys:${NC}"
echo "  Your SSH keys were NOT stored in git (for security)."
echo "  If you backed them up to iCloud during pre-reset backup:"
echo "    1. Find the encrypted zip in ~/Library/Mobile Documents/com~apple~CloudDocs/mac-backup-*/"
echo "    2. unzip ~/Library/Mobile\\ Documents/com~apple~CloudDocs/mac-backup-*/ssh-keys-encrypted.zip"
echo "    3. Enter your backup password"
echo "    4. cp id_ed25519* ~/.ssh/ && chmod 600 ~/.ssh/id_ed25519"
echo "    5. ssh-add ~/.ssh/id_ed25519"
echo ""

echo -e "${YELLOW}📂 Clone Your Repos:${NC}"
echo "  mkdir -p ~/Code && cd ~/Code"
echo "  gh auth login"
echo "  gh repo clone ezra-gocci/fast-forward"
echo "  gh repo clone ezra-gocci/cv"
echo "  gh repo clone ezra-gocci/beat-em"
echo "  gh repo clone ezra-gocci/lets-dance"
echo "  gh repo clone ezra-gocci/investsmart"
echo "  gh repo clone ezra-gocci/claude-vault"
echo "  gh repo clone ezra-gocci/perfect-start"
echo "  gh repo clone ezra-gocci/leet"
echo ""

echo -e "${YELLOW}🔐 App Logins:${NC}"
echo "  • Claude Desktop — sign in with Anthropic account"
echo "  • Claude Code — run: claude login"
echo "  • GitHub CLI — run: gh auth login"
echo "  • Tailscale — run: tailscale up"
echo "  • Steam, Telegram, Obsidian — sign in manually"
echo ""

# ============================================
# Final Summary
# ============================================

echo ""
echo -e "${GREEN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ✓ Installation Complete!                               ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo -e "${CYAN}📦 Installed Components:${NC}"
echo ""
should_install "HOMEBREW" && echo "  ✓ Homebrew"
should_install "GIT" && echo "  ✓ Git (configured as: $GIT_USER_NAME)"
should_install "NEOVIM" && echo "  ✓ Neovim ($NEOVIM_SETUP)"
should_install "MISE" && echo "  ✓ mise"
should_install "STARSHIP" && echo "  ✓ Starship"
should_install "WEZTERM" && echo "  ✓ WezTerm"
[ "$INSTALL_TMUX_CONFIG" == "true" ] && echo "  ✓ tmux config"
[ "$INSTALL_ATUIN_CONFIG" == "true" ] && echo "  ✓ Atuin config"
[ "$INSTALL_BTOP_CONFIG" == "true" ] && echo "  ✓ btop config"
[ "$INSTALL_MISE_CONFIG" == "true" ] && echo "  ✓ mise config"
[ "$INSTALL_ZED_CONFIG" == "true" ] && echo "  ✓ Zed config"
[ "$INSTALL_SSH_CONFIG" == "true" ] && echo "  ✓ SSH config"
[ "$INSTALL_ITERM2_CONFIG" == "true" ] && echo "  ✓ iTerm2 preferences"
[ "$INSTALL_CLAUDE_CONFIG" == "true" ] && echo "  ✓ Claude configs"
echo ""

echo -e "${YELLOW}📝 Next Steps:${NC}"
echo ""
echo "  1. ${CYAN}Restart your terminal${NC} or run: source ~/.zshrc"
echo ""
echo "  2. ${CYAN}Launch WezTerm or iTerm2${NC}"
echo ""
echo "  3. ${CYAN}Restore SSH keys${NC} from iCloud backup (see guidance above)"
echo ""
echo "  4. ${CYAN}Clone your repos${NC} (see commands above)"
echo ""
echo "  5. ${CYAN}Test the tools${NC}:"
echo "     ll              # Modern ls (eza)"
echo "     z ~             # Smart cd (zoxide)"
echo "     bat README.md   # Syntax-highlighted cat"
echo "     rg \"TODO\"       # Fast grep (ripgrep)"
echo "     btop            # Resource monitor"
echo "     yazi            # File manager"
echo ""

if [ "$BACKUP_EXISTING" == "true" ]; then
    echo -e "${CYAN}💾 Backup location:${NC} $BACKUP_DIR"
fi

echo -e "${CYAN}📁 Dotfiles location:${NC} $DOTFILES_DIR"
echo ""

echo -e "${GREEN}🎉 Happy coding!${NC}"
echo ""
