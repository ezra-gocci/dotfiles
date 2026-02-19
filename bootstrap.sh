#!/bin/bash
#
# macOS Bootstrap — Single-command setup after factory reset
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/ezra-gocci/dotfiles/main/bootstrap.sh | bash
#
# What this does:
#   1. Installs Xcode Command Line Tools
#   2. Installs Homebrew
#   3. Installs Git + Ansible
#   4. Clones dotfiles repo
#   5. Runs Ansible playbook to configure everything
#
# Works with macOS bash 3.2 (no associative arrays, no set -u)

set -eo pipefail

# ─── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
DIM='\033[2m'
NC='\033[0m'

# ─── Configuration ────────────────────────────────────────────
DOTFILES_REPO="https://github.com/ezra-gocci/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
CLT_TIMEOUT=600  # 10 minutes

# ─── Helpers ──────────────────────────────────────────────────
print_step() {
    echo ""
    echo -e "${BLUE}━━━ $1 ━━━${NC}"
}

print_ok() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "  ${YELLOW}!${NC} $1"
}

print_err() {
    echo -e "  ${RED}✗${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ─── Banner ───────────────────────────────────────────────────
echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   macOS Bootstrap — ezra-gocci/dotfiles   ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════╝${NC}"
echo ""

# ─── Preflight checks ────────────────────────────────────────
print_step "Preflight checks"

# Check macOS
if [ "$(uname)" != "Darwin" ]; then
    print_err "This script only runs on macOS"
    exit 1
fi
print_ok "macOS $(sw_vers -productVersion) ($(uname -m))"

# Check internet
if ! curl -s --head --max-time 5 https://github.com >/dev/null 2>&1; then
    print_err "No internet connection — connect to Wi-Fi first"
    exit 1
fi
print_ok "Internet connected"

# ─── Step 1: Xcode Command Line Tools ────────────────────────
print_step "Step 1: Xcode Command Line Tools"

if xcode-select -p >/dev/null 2>&1; then
    print_ok "Already installed"
else
    print_warn "Installing Xcode CLT (this may take a few minutes)..."

    # Non-interactive install via softwareupdate
    touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress

    # Find the CLT package name
    CLT_PKG=$(softwareupdate -l 2>/dev/null | \
        grep -E '\*.*Command Line' | \
        head -n 1 | \
        awk -F'*' '{print $2}' | \
        sed 's/^ *//' | \
        sed 's/Label: //')

    if [ -n "$CLT_PKG" ]; then
        echo -e "  ${DIM}Package: ${CLT_PKG}${NC}"
        softwareupdate -i "$CLT_PKG" --verbose 2>&1 | while read -r line; do
            # Show progress lines only
            case "$line" in
                *Installing*|*Downloaded*|*Done*) echo -e "  ${DIM}${line}${NC}" ;;
            esac
        done
    else
        print_warn "Could not find CLT package — falling back to xcode-select --install"
        xcode-select --install 2>/dev/null || true
        echo -e "  ${YELLOW}A dialog may have appeared. Click 'Install' and wait.${NC}"
    fi

    # Poll until installed or timeout
    elapsed=0
    while ! xcode-select -p >/dev/null 2>&1; do
        sleep 5
        elapsed=$((elapsed + 5))
        if [ "$elapsed" -ge "$CLT_TIMEOUT" ]; then
            rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
            print_err "Timed out waiting for Xcode CLT (${CLT_TIMEOUT}s)"
            print_err "Run 'xcode-select --install' manually, then re-run this script"
            exit 1
        fi
    done

    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    print_ok "Xcode CLT installed"
fi

# ─── Step 2: Homebrew ────────────────────────────────────────
print_step "Step 2: Homebrew"

if command_exists brew; then
    print_ok "Already installed"
    brew update --quiet
    print_ok "Updated"
else
    print_warn "Installing Homebrew..."

    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [ "$(uname -m)" = "arm64" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
        # Persist for future shells
        if ! grep -q '/opt/homebrew/bin/brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        fi
    else
        eval "$(/usr/local/bin/brew shellenv)"
        if ! grep -q '/usr/local/bin/brew shellenv' "$HOME/.zprofile" 2>/dev/null; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
        fi
    fi

    print_ok "Homebrew installed"
fi

# ─── Step 3: Git + Ansible ───────────────────────────────────
print_step "Step 3: Git + Ansible"

if ! command_exists git; then
    brew install git --quiet
    print_ok "Git installed"
else
    print_ok "Git already installed"
fi

if ! command_exists ansible-playbook; then
    brew install ansible --quiet
    print_ok "Ansible installed"
else
    print_ok "Ansible already installed"
fi

# ─── Step 4: Clone dotfiles ──────────────────────────────────
print_step "Step 4: Dotfiles repository"

if [ -d "$DOTFILES_DIR/.git" ]; then
    print_ok "Already cloned at $DOTFILES_DIR"
    cd "$DOTFILES_DIR"
    git pull --quiet origin main || print_warn "Could not update (continuing anyway)"
else
    if [ -d "$DOTFILES_DIR" ]; then
        print_warn "Directory exists but is not a git repo — backing up"
        mv "$DOTFILES_DIR" "${DOTFILES_DIR}.bak.$(date +%s)"
    fi
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    print_ok "Cloned to $DOTFILES_DIR"
fi

# ─── Step 5: Ansible Galaxy collections ──────────────────────
print_step "Step 5: Ansible dependencies"

cd "$DOTFILES_DIR/ansible"

if [ -f requirements.yml ]; then
    ansible-galaxy install -r requirements.yml --force 2>&1 | while read -r line; do
        case "$line" in
            *Installing*|*installed*) echo -e "  ${DIM}${line}${NC}" ;;
        esac
    done
    print_ok "Galaxy collections installed"
else
    print_warn "No requirements.yml found — skipping"
fi

# ─── Step 6: Run Ansible playbook ────────────────────────────
print_step "Step 6: Running Ansible playbook"

echo ""
echo -e "  ${YELLOW}Ansible will now configure your system.${NC}"
echo -e "  ${YELLOW}You'll be prompted for your sudo password.${NC}"
echo ""

ansible-playbook main.yml -i inventory.yml --ask-become-pass

# ─── Done ─────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         Bootstrap complete!                ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Next steps:${NC}"
echo -e "  1. Restart your terminal (or run: ${GREEN}source ~/.zshrc${NC})"
echo -e "  2. Restore SSH keys from iCloud backup"
echo -e "  3. Clone your repos: ${GREEN}cd ~/Code && gh auth login${NC}"
echo ""
echo -e "  ${DIM}Dotfiles: $DOTFILES_DIR${NC}"
echo -e "  ${DIM}Re-run Ansible: cd $DOTFILES_DIR/ansible && ansible-playbook main.yml --ask-become-pass${NC}"
echo ""
