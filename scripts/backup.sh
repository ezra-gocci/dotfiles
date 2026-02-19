#!/bin/bash
#
# Pre-Factory-Reset Backup Script
#
# Interactive backup tool that saves configs, files, and keys
# to iCloud and GitHub before a macOS factory reset.
#
# Usage:
#   ./scripts/backup.sh
#

set -euo pipefail

# ═══════════════════════════════════════════════════════════
# Colors & Formatting
# ═══════════════════════════════════════════════════════════

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# ═══════════════════════════════════════════════════════════
# Configuration
# ═══════════════════════════════════════════════════════════

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
BACKUP_DATE=$(date +%Y%m%d)
BACKUP_DEST="$ICLOUD_DIR/mac-backup-$BACKUP_DATE"
MANIFEST_DIR="$DOTFILES_DIR/manifests"
CODE_DIR="$HOME/Code"

# Backup item states (1=selected, 0=deselected)
declare -A ITEMS
ITEMS[brewfile]=1
ITEMS[configs]=1
ITEMS[ssh_keys]=1
ITEMS[personal_files]=1
ITEMS[git_repos]=1
ITEMS[claude]=1
ITEMS[app_prefs]=1
ITEMS[credentials]=0

# Item descriptions
declare -A ITEM_LABELS
ITEM_LABELS[brewfile]="Homebrew packages → Brewfile"
ITEM_LABELS[configs]="Dotfile configs → git commit"
ITEM_LABELS[ssh_keys]="SSH keys → encrypted zip to iCloud"
ITEM_LABELS[personal_files]="Personal files → rsync to iCloud"
ITEM_LABELS[git_repos]="Git repos → verify all pushed"
ITEM_LABELS[claude]="Claude configs → git commit"
ITEM_LABELS[app_prefs]="App preferences → export to dotfiles"
ITEM_LABELS[credentials]="Credentials (kube/docker) → iCloud"

# Ordered keys for display
ITEM_ORDER=(brewfile configs ssh_keys personal_files git_repos claude app_prefs credentials)

# ═══════════════════════════════════════════════════════════
# Helper Functions
# ═══════════════════════════════════════════════════════════

print_header() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_ok() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

print_fail() {
    echo -e "  ${RED}✗${NC} $1"
}

print_info() {
    echo -e "  ${CYAN}ℹ${NC} $1"
}

human_size() {
    local bytes=$1
    if [ "$bytes" -ge 1073741824 ]; then
        printf "%.1f GB" "$(echo "$bytes / 1073741824" | bc -l)"
    elif [ "$bytes" -ge 1048576 ]; then
        printf "%.1f MB" "$(echo "$bytes / 1048576" | bc -l)"
    elif [ "$bytes" -ge 1024 ]; then
        printf "%.0f KB" "$(echo "$bytes / 1024" | bc -l)"
    else
        printf "%d B" "$bytes"
    fi
}

dir_size_bytes() {
    if [ -d "$1" ]; then
        du -sk "$1" 2>/dev/null | awk '{print $1 * 1024}'
    else
        echo "0"
    fi
}

# ═══════════════════════════════════════════════════════════
# Phase 1: Inventory
# ═══════════════════════════════════════════════════════════

phase_inventory() {
    echo -e "${BLUE}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   macOS Pre-Reset Backup                                 ║
║   Inventory & Selective Backup Tool                      ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    print_header "Phase 1: System Inventory"

    # Homebrew
    echo ""
    echo -e "  ${BOLD}Homebrew:${NC}"
    if command -v brew &>/dev/null; then
        local formulae_count=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
        local cask_count=$(brew list --cask 2>/dev/null | wc -l | tr -d ' ')
        local tap_count=$(brew tap 2>/dev/null | wc -l | tr -d ' ')
        print_ok "${formulae_count} formulae, ${cask_count} casks, ${tap_count} taps"
    else
        print_warn "Homebrew not installed"
    fi

    # Configs
    echo ""
    echo -e "  ${BOLD}Dotfile Configs:${NC}"
    local config_count=0
    local config_tracked=0
    local config_files=(
        "$HOME/.zshrc"
        "$HOME/.gitconfig"
        "$HOME/.tmux.conf"
        "$HOME/.config/starship.toml"
        "$HOME/.config/wezterm/wezterm.lua"
        "$HOME/.config/nvim/init.lua"
        "$HOME/.config/nvim/lazy-lock.json"
        "$HOME/.config/atuin/config.toml"
        "$HOME/.config/btop/btop.conf"
        "$HOME/.config/mise/config.toml"
        "$HOME/.config/zed/settings.json"
        "$HOME/.ssh/config"
    )
    for f in "${config_files[@]}"; do
        if [ -f "$f" ]; then
            config_count=$((config_count + 1))
        fi
    done
    # Check how many are in dotfiles repo
    if [ -d "$DOTFILES_DIR" ]; then
        local repo_configs=(
            "$DOTFILES_DIR/zsh/.zshrc"
            "$DOTFILES_DIR/git/.gitconfig"
            "$DOTFILES_DIR/tmux/.tmux.conf"
            "$DOTFILES_DIR/starship/starship.toml"
            "$DOTFILES_DIR/wezterm/wezterm.lua"
            "$DOTFILES_DIR/nvim/init.lua"
            "$DOTFILES_DIR/nvim/lazy-lock.json"
            "$DOTFILES_DIR/atuin/config.toml"
            "$DOTFILES_DIR/btop/btop.conf"
            "$DOTFILES_DIR/mise/config.toml"
            "$DOTFILES_DIR/zed/settings.json"
            "$DOTFILES_DIR/ssh/config"
        )
        for f in "${repo_configs[@]}"; do
            [ -f "$f" ] && config_tracked=$((config_tracked + 1))
        done
    fi
    print_ok "${config_count} configs found (${config_tracked} tracked in repo)"

    # SSH Keys
    echo ""
    echo -e "  ${BOLD}SSH Keys:${NC}"
    local key_count=0
    for keyfile in "$HOME/.ssh"/id_*; do
        [ -f "$keyfile" ] && [[ ! "$keyfile" == *.pub ]] && key_count=$((key_count + 1))
    done
    if [ "$key_count" -gt 0 ]; then
        print_ok "${key_count} key pair(s)"
        for keyfile in "$HOME/.ssh"/id_*.pub; do
            [ -f "$keyfile" ] && print_info "  $(basename "$keyfile"): $(cat "$keyfile" | awk '{print $3}')"
        done
    else
        print_warn "No SSH keys found"
    fi

    # Git repos
    echo ""
    echo -e "  ${BOLD}Git Repos (~/Code/):${NC}"
    if [ -d "$CODE_DIR" ]; then
        local repo_count=0
        local dirty_count=0
        for dir in "$CODE_DIR"/*/; do
            if [ -d "${dir}.git" ]; then
                repo_count=$((repo_count + 1))
                cd "$dir"
                if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                    dirty_count=$((dirty_count + 1))
                fi
            fi
        done
        cd "$DOTFILES_DIR" 2>/dev/null || cd "$HOME"
        print_ok "${repo_count} repos in ~/Code/"
        if [ "$dirty_count" -gt 0 ]; then
            print_warn "${dirty_count} repo(s) have uncommitted changes"
        fi
    else
        print_warn "~/Code/ directory not found"
    fi

    # Personal files
    echo ""
    echo -e "  ${BOLD}Personal Files:${NC}"
    local docs_size=$(dir_size_bytes "$HOME/Documents")
    local music_size=$(dir_size_bytes "$HOME/Music")
    local desktop_size=$(dir_size_bytes "$HOME/Desktop")
    local downloads_size=$(dir_size_bytes "$HOME/Downloads")
    [ "$docs_size" -gt 0 ] && print_ok "Documents: $(human_size "$docs_size")"
    [ "$music_size" -gt 0 ] && print_ok "Music: $(human_size "$music_size")"
    [ "$desktop_size" -gt 0 ] && print_ok "Desktop: $(human_size "$desktop_size")"
    [ "$downloads_size" -gt 0 ] && print_info "Downloads: $(human_size "$downloads_size") ${DIM}(usually skipped)${NC}"

    # iCloud
    echo ""
    echo -e "  ${BOLD}iCloud Drive:${NC}"
    if [ -d "$ICLOUD_DIR" ]; then
        local icloud_size=$(dir_size_bytes "$ICLOUD_DIR")
        print_ok "Available at: ~/Library/Mobile Documents/com~apple~CloudDocs/"
        print_ok "Current size: $(human_size "$icloud_size")"
    else
        print_warn "iCloud Drive not accessible"
    fi

    # Claude
    echo ""
    echo -e "  ${BOLD}Claude:${NC}"
    if [ -d "$HOME/.claude" ]; then
        local claude_size=$(dir_size_bytes "$HOME/.claude")
        print_ok "Claude Code config: $(human_size "$claude_size")"
    fi
    if [ -d "$HOME/Library/Application Support/Claude" ]; then
        local claude_desktop_size=$(dir_size_bytes "$HOME/Library/Application Support/Claude")
        print_ok "Claude Desktop data: $(human_size "$claude_desktop_size")"
    fi

    echo ""
}

# ═══════════════════════════════════════════════════════════
# Phase 2: Selection UI
# ═══════════════════════════════════════════════════════════

phase_selection() {
    print_header "Phase 2: Select Backup Items"
    echo ""
    echo -e "  ${DIM}Toggle items with their number. Press Enter to proceed.${NC}"
    echo ""

    while true; do
        # Display current selections
        for i in "${!ITEM_ORDER[@]}"; do
            local key="${ITEM_ORDER[$i]}"
            local num=$((i + 1))
            if [ "${ITEMS[$key]}" -eq 1 ]; then
                echo -e "  ${GREEN}[x]${NC} ${BOLD}${num}.${NC} ${ITEM_LABELS[$key]}"
            else
                echo -e "  ${DIM}[ ]${NC} ${BOLD}${num}.${NC} ${ITEM_LABELS[$key]}"
            fi
        done

        echo ""
        echo -ne "  ${CYAN}Toggle [1-${#ITEM_ORDER[@]}], ${BOLD}a${NC}${CYAN}=all, ${BOLD}n${NC}${CYAN}=none, ${BOLD}Enter${NC}${CYAN}=proceed: ${NC}"
        read -r choice

        case "$choice" in
            "")
                break
                ;;
            a|A)
                for key in "${ITEM_ORDER[@]}"; do ITEMS[$key]=1; done
                ;;
            n|N)
                for key in "${ITEM_ORDER[@]}"; do ITEMS[$key]=0; done
                ;;
            [1-8])
                local idx=$((choice - 1))
                local key="${ITEM_ORDER[$idx]}"
                if [ "${ITEMS[$key]}" -eq 1 ]; then
                    ITEMS[$key]=0
                else
                    ITEMS[$key]=1
                fi
                ;;
            *)
                echo -e "  ${RED}Invalid choice${NC}"
                ;;
        esac

        # Clear the menu lines for redraw (move up)
        for _ in "${ITEM_ORDER[@]}"; do
            printf "\033[A\033[2K"
        done
        printf "\033[A\033[2K"  # The prompt line
        printf "\033[A\033[2K"  # The blank line
    done

    # Count selected
    local selected=0
    for key in "${ITEM_ORDER[@]}"; do
        [ "${ITEMS[$key]}" -eq 1 ] && selected=$((selected + 1))
    done

    if [ "$selected" -eq 0 ]; then
        echo -e "  ${YELLOW}No items selected. Nothing to back up.${NC}"
        exit 0
    fi

    echo ""
    echo -e "  ${GREEN}${selected} item(s) selected for backup.${NC}"
    echo ""
    echo -ne "  ${YELLOW}Proceed with backup? [Y/n]: ${NC}"
    read -r confirm
    if [[ "$confirm" =~ ^[Nn] ]]; then
        echo -e "  ${YELLOW}Backup cancelled.${NC}"
        exit 0
    fi
}

# ═══════════════════════════════════════════════════════════
# Phase 3: Execute Backups
# ═══════════════════════════════════════════════════════════

# --- Brewfile ---
backup_brewfile() {
    print_header "Backing up Homebrew packages"

    if ! command -v brew &>/dev/null; then
        print_warn "Homebrew not installed, skipping"
        return
    fi

    cd "$DOTFILES_DIR"
    brew bundle dump --force --describe --file="$DOTFILES_DIR/Brewfile"
    local count=$(grep -c '^brew\|^cask\|^tap' "$DOTFILES_DIR/Brewfile" || true)
    print_ok "Brewfile updated with ${count} entries"
}

# --- Configs ---
backup_configs() {
    print_header "Backing up dotfile configs"

    cd "$DOTFILES_DIR"

    # Copy live configs back into repo directories
    local copied=0

    # .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$DOTFILES_DIR/zsh/.zshrc"
        print_ok ".zshrc"
        copied=$((copied + 1))
    fi

    # .gitconfig
    if [ -f "$HOME/.gitconfig" ]; then
        cp "$HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig"
        print_ok ".gitconfig"
        copied=$((copied + 1))
    fi

    # tmux
    if [ -f "$HOME/.tmux.conf" ]; then
        mkdir -p "$DOTFILES_DIR/tmux"
        cp "$HOME/.tmux.conf" "$DOTFILES_DIR/tmux/.tmux.conf"
        print_ok ".tmux.conf"
        copied=$((copied + 1))
    fi

    # starship
    if [ -f "$HOME/.config/starship.toml" ]; then
        cp "$HOME/.config/starship.toml" "$DOTFILES_DIR/starship/starship.toml"
        print_ok "starship.toml"
        copied=$((copied + 1))
    fi

    # wezterm
    if [ -f "$HOME/.config/wezterm/wezterm.lua" ]; then
        cp "$HOME/.config/wezterm/wezterm.lua" "$DOTFILES_DIR/wezterm/wezterm.lua"
        print_ok "wezterm.lua"
        copied=$((copied + 1))
    fi

    # nvim
    if [ -f "$HOME/.config/nvim/init.lua" ]; then
        mkdir -p "$DOTFILES_DIR/nvim"
        cp "$HOME/.config/nvim/init.lua" "$DOTFILES_DIR/nvim/init.lua"
        print_ok "nvim/init.lua"
        copied=$((copied + 1))
    fi
    if [ -f "$HOME/.config/nvim/lazy-lock.json" ]; then
        cp "$HOME/.config/nvim/lazy-lock.json" "$DOTFILES_DIR/nvim/lazy-lock.json"
        print_ok "nvim/lazy-lock.json"
        copied=$((copied + 1))
    fi

    # atuin
    if [ -f "$HOME/.config/atuin/config.toml" ]; then
        mkdir -p "$DOTFILES_DIR/atuin"
        cp "$HOME/.config/atuin/config.toml" "$DOTFILES_DIR/atuin/config.toml"
        print_ok "atuin/config.toml"
        copied=$((copied + 1))
    fi

    # btop
    if [ -f "$HOME/.config/btop/btop.conf" ]; then
        mkdir -p "$DOTFILES_DIR/btop"
        cp "$HOME/.config/btop/btop.conf" "$DOTFILES_DIR/btop/btop.conf"
        print_ok "btop/btop.conf"
        copied=$((copied + 1))
    fi

    # mise
    if [ -f "$HOME/.config/mise/config.toml" ]; then
        mkdir -p "$DOTFILES_DIR/mise"
        cp "$HOME/.config/mise/config.toml" "$DOTFILES_DIR/mise/config.toml"
        print_ok "mise/config.toml"
        copied=$((copied + 1))
    fi

    # zed
    if [ -f "$HOME/.config/zed/settings.json" ]; then
        mkdir -p "$DOTFILES_DIR/zed"
        cp "$HOME/.config/zed/settings.json" "$DOTFILES_DIR/zed/settings.json"
        print_ok "zed/settings.json"
        copied=$((copied + 1))
    fi

    # ssh config (NOT keys)
    if [ -f "$HOME/.ssh/config" ]; then
        mkdir -p "$DOTFILES_DIR/ssh"
        cp "$HOME/.ssh/config" "$DOTFILES_DIR/ssh/config"
        print_ok "ssh/config"
        copied=$((copied + 1))
    fi

    print_ok "${copied} config files copied into dotfiles repo"
}

# --- SSH Keys ---
backup_ssh_keys() {
    print_header "Backing up SSH keys"

    local key_files=()
    for f in "$HOME/.ssh"/id_* "$HOME/.ssh"/known_hosts; do
        [ -f "$f" ] && key_files+=("$f")
    done

    if [ ${#key_files[@]} -eq 0 ]; then
        print_warn "No SSH keys found to back up"
        return
    fi

    mkdir -p "$BACKUP_DEST"

    echo ""
    echo -e "  ${YELLOW}SSH keys will be encrypted with a password.${NC}"
    echo -e "  ${YELLOW}Remember this password — you'll need it to restore.${NC}"
    echo ""

    # Create encrypted zip
    cd "$HOME/.ssh"
    zip -e "$BACKUP_DEST/ssh-keys-encrypted.zip" "${key_files[@]/#$HOME\/.ssh\//}" 2>/dev/null

    if [ $? -eq 0 ]; then
        print_ok "SSH keys encrypted and saved to iCloud"
        print_info "Location: $BACKUP_DEST/ssh-keys-encrypted.zip"
    else
        print_fail "Failed to create encrypted SSH key backup"
    fi
}

# --- Personal Files ---
backup_personal_files() {
    print_header "Backing up personal files to iCloud"

    mkdir -p "$BACKUP_DEST"

    local dirs_to_backup=()

    if [ -d "$HOME/Documents" ] && [ "$(ls -A "$HOME/Documents" 2>/dev/null)" ]; then
        dirs_to_backup+=("$HOME/Documents")
    fi
    if [ -d "$HOME/Music" ] && [ "$(ls -A "$HOME/Music" 2>/dev/null)" ]; then
        dirs_to_backup+=("$HOME/Music")
    fi
    if [ -d "$HOME/Desktop" ] && [ "$(ls -A "$HOME/Desktop" 2>/dev/null)" ]; then
        dirs_to_backup+=("$HOME/Desktop")
    fi

    if [ ${#dirs_to_backup[@]} -eq 0 ]; then
        print_warn "No personal files to back up"
        return
    fi

    for dir in "${dirs_to_backup[@]}"; do
        local dirname=$(basename "$dir")
        local size=$(dir_size_bytes "$dir")
        echo -ne "  ${CYAN}Syncing ${dirname} ($(human_size "$size"))...${NC}"
        rsync -a --progress "$dir/" "$BACKUP_DEST/$dirname/" 2>/dev/null | tail -1
        echo -e "\r  ${GREEN}✓${NC} ${dirname} ($(human_size "$size"))                    "
    done

    print_ok "Personal files synced to iCloud"
    print_info "Location: $BACKUP_DEST/"
}

# --- Git Repos ---
verify_git_repos() {
    print_header "Verifying Git repos"

    if [ ! -d "$CODE_DIR" ]; then
        print_warn "~/Code/ not found"
        return
    fi

    local all_clean=true

    for dir in "$CODE_DIR"/*/; do
        if [ ! -d "${dir}.git" ]; then
            continue
        fi

        local repo_name=$(basename "$dir")
        cd "$dir"

        local status=""
        local issues=()

        # Check for uncommitted changes
        if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
            issues+=("uncommitted changes")
        fi

        # Check for unpushed commits
        local branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [ -n "$branch" ]; then
            local unpushed=$(git log "origin/${branch}..HEAD" --oneline 2>/dev/null | wc -l | tr -d ' ')
            if [ "$unpushed" -gt 0 ]; then
                issues+=("${unpushed} unpushed commit(s)")
            fi
        fi

        if [ ${#issues[@]} -eq 0 ]; then
            print_ok "${repo_name} — clean"
        else
            all_clean=false
            local issue_str=$(IFS=", "; echo "${issues[*]}")
            print_warn "${repo_name} — ${issue_str}"
        fi
    done

    cd "$DOTFILES_DIR" 2>/dev/null || cd "$HOME"

    if [ "$all_clean" = true ]; then
        print_ok "All repos are clean and pushed"
    else
        echo ""
        echo -ne "  ${YELLOW}Some repos have unpushed changes. Continue anyway? [Y/n]: ${NC}"
        read -r cont
        if [[ "$cont" =~ ^[Nn] ]]; then
            echo -e "  ${YELLOW}Please push your changes first, then run backup again.${NC}"
            exit 1
        fi
    fi
}

# --- Claude ---
backup_claude() {
    print_header "Backing up Claude configs"

    cd "$DOTFILES_DIR"
    local copied=0

    # Claude Code settings
    mkdir -p "$DOTFILES_DIR/claude/claude-code"
    if [ -f "$HOME/.claude/settings.json" ]; then
        cp "$HOME/.claude/settings.json" "$DOTFILES_DIR/claude/claude-code/settings.json"
        print_ok "Claude Code settings.json"
        copied=$((copied + 1))
    fi
    if [ -f "$HOME/.claude/settings.local.json" ]; then
        cp "$HOME/.claude/settings.local.json" "$DOTFILES_DIR/claude/claude-code/settings.local.json"
        print_ok "Claude Code settings.local.json"
        copied=$((copied + 1))
    fi

    # Claude Desktop config
    mkdir -p "$DOTFILES_DIR/claude/claude-desktop"
    local claude_desktop_dir="$HOME/Library/Application Support/Claude"
    if [ -d "$claude_desktop_dir" ]; then
        for f in "$claude_desktop_dir"/*.json; do
            if [ -f "$f" ]; then
                cp "$f" "$DOTFILES_DIR/claude/claude-desktop/"
                print_ok "Claude Desktop $(basename "$f")"
                copied=$((copied + 1))
            fi
        done
    fi

    # Project memory files
    mkdir -p "$DOTFILES_DIR/claude/project-memory"
    if [ -d "$HOME/.claude/projects" ]; then
        for projdir in "$HOME/.claude/projects"/*/; do
            if [ -f "${projdir}memory/MEMORY.md" ]; then
                local proj_name=$(basename "$projdir")
                # Extract project name from path encoding
                local friendly_name=$(echo "$proj_name" | sed 's/^-Users-[^-]*-Code-//' | sed 's/^-Users-[^-]*-//')
                mkdir -p "$DOTFILES_DIR/claude/project-memory/$friendly_name"
                cp "${projdir}memory/MEMORY.md" "$DOTFILES_DIR/claude/project-memory/$friendly_name/"
                print_ok "Project memory: $friendly_name"
                copied=$((copied + 1))
            fi
        done
    fi

    print_ok "${copied} Claude config files saved"
}

# --- App Preferences ---
backup_app_prefs() {
    print_header "Backing up app preferences"

    local exported=0

    # iTerm2
    if defaults read com.googlecode.iterm2 &>/dev/null; then
        mkdir -p "$DOTFILES_DIR/iterm2"
        defaults export com.googlecode.iterm2 "$DOTFILES_DIR/iterm2/com.googlecode.iterm2.plist"
        print_ok "iTerm2 preferences exported"
        exported=$((exported + 1))
    fi

    print_ok "${exported} app preference(s) exported"
}

# --- Credentials ---
backup_credentials() {
    print_header "Backing up credentials to iCloud"

    mkdir -p "$BACKUP_DEST"

    local backed_up=0

    # Kubernetes config
    if [ -f "$HOME/.kube/config" ]; then
        mkdir -p "$BACKUP_DEST/credentials"
        cp "$HOME/.kube/config" "$BACKUP_DEST/credentials/kube-config"
        print_ok "Kubernetes config"
        backed_up=$((backed_up + 1))
    fi

    # Docker config (not credentials, just config)
    if [ -f "$HOME/.docker/config.json" ]; then
        mkdir -p "$BACKUP_DEST/credentials"
        cp "$HOME/.docker/config.json" "$BACKUP_DEST/credentials/docker-config.json"
        print_ok "Docker config"
        backed_up=$((backed_up + 1))
    fi

    if [ "$backed_up" -eq 0 ]; then
        print_info "No credential files found to back up"
    else
        print_ok "${backed_up} credential file(s) copied to iCloud"
        print_info "Location: $BACKUP_DEST/credentials/"
    fi
}

# ═══════════════════════════════════════════════════════════
# Phase 4: Manifest & Commit
# ═══════════════════════════════════════════════════════════

phase_manifest() {
    print_header "Phase 4: Creating manifest & committing"

    mkdir -p "$MANIFEST_DIR"

    # Gather data for manifest
    local hostname=$(scutil --get ComputerName 2>/dev/null || hostname)
    local macos_ver=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
    local chip=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "unknown")
    local formulae_count=$(brew list --formula 2>/dev/null | wc -l | tr -d ' ')
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Build JSON manifest
    local manifest_file="$MANIFEST_DIR/backup-${BACKUP_DATE}.json"

    cat > "$manifest_file" << MANIFEST_EOF
{
  "schema_version": "1.0",
  "created_at": "${timestamp}",
  "machine": {
    "hostname": "${hostname}",
    "macos_version": "${macos_ver}",
    "chip": "${chip}"
  },
  "backup_items": {
    "brewfile": {
      "saved": $([ "${ITEMS[brewfile]}" -eq 1 ] && echo "true" || echo "false"),
      "formulae_count": ${formulae_count}
    },
    "configs": {
      "saved": $([ "${ITEMS[configs]}" -eq 1 ] && echo "true" || echo "false")
    },
    "ssh_keys": {
      "saved": $([ "${ITEMS[ssh_keys]}" -eq 1 ] && echo "true" || echo "false"),
      "location": "icloud",
      "encrypted": true
    },
    "personal_files": {
      "saved": $([ "${ITEMS[personal_files]}" -eq 1 ] && echo "true" || echo "false"),
      "location": "icloud"
    },
    "git_repos": {
      "verified": $([ "${ITEMS[git_repos]}" -eq 1 ] && echo "true" || echo "false")
    },
    "claude": {
      "saved": $([ "${ITEMS[claude]}" -eq 1 ] && echo "true" || echo "false")
    },
    "app_prefs": {
      "saved": $([ "${ITEMS[app_prefs]}" -eq 1 ] && echo "true" || echo "false")
    },
    "credentials": {
      "saved": $([ "${ITEMS[credentials]}" -eq 1 ] && echo "true" || echo "false"),
      "location": "icloud"
    }
  },
  "icloud_backup_dir": "${BACKUP_DEST}",
  "dotfiles_repo": "https://github.com/ezra-gocci/dotfiles.git"
}
MANIFEST_EOF

    print_ok "Manifest created: manifests/backup-${BACKUP_DATE}.json"

    # Git commit and push
    cd "$DOTFILES_DIR"
    git add -A
    local changes=$(git status --porcelain | wc -l | tr -d ' ')

    if [ "$changes" -gt 0 ]; then
        git commit -m "backup: pre-reset backup ${BACKUP_DATE}

Automated backup before macOS factory reset.
Machine: ${hostname} (${macos_ver}, ${chip})"

        print_ok "Changes committed (${changes} files)"

        echo -ne "  ${CYAN}Push to GitHub? [Y/n]: ${NC}"
        read -r push_confirm
        if [[ ! "$push_confirm" =~ ^[Nn] ]]; then
            git push origin main
            local sha=$(git rev-parse --short HEAD)
            print_ok "Pushed to GitHub (${sha})"
        fi
    else
        print_info "No changes to commit"
    fi
}

# ═══════════════════════════════════════════════════════════
# Final Summary
# ═══════════════════════════════════════════════════════════

print_summary() {
    echo ""
    echo -e "${GREEN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ✓ Backup Complete!                                     ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    echo -e "  ${BOLD}Saved to GitHub:${NC}"
    [ "${ITEMS[brewfile]}" -eq 1 ] && echo "    ✓ Brewfile"
    [ "${ITEMS[configs]}" -eq 1 ] && echo "    ✓ Dotfile configs"
    [ "${ITEMS[claude]}" -eq 1 ] && echo "    ✓ Claude configs"
    [ "${ITEMS[app_prefs]}" -eq 1 ] && echo "    ✓ App preferences"
    echo "    ✓ Backup manifest"

    echo ""
    echo -e "  ${BOLD}Saved to iCloud:${NC}"
    [ "${ITEMS[ssh_keys]}" -eq 1 ] && echo "    ✓ SSH keys (encrypted)"
    [ "${ITEMS[personal_files]}" -eq 1 ] && echo "    ✓ Personal files"
    [ "${ITEMS[credentials]}" -eq 1 ] && echo "    ✓ Credentials"

    echo ""
    echo -e "  ${BOLD}Verified:${NC}"
    [ "${ITEMS[git_repos]}" -eq 1 ] && echo "    ✓ Git repos pushed"

    echo ""
    echo -e "  ${YELLOW}📋 Before factory reset, verify:${NC}"
    echo "    1. iCloud sync is complete: ls \"$BACKUP_DEST\""
    echo "    2. GitHub has latest: gh repo view ezra-gocci/dotfiles"
    echo "    3. Sign out of iCloud LAST (after verifying sync)"
    echo ""
    echo -e "  ${YELLOW}📋 After fresh install:${NC}"
    echo "    1. Sign into iCloud first"
    echo "    2. Wait for iCloud Drive to sync"
    echo "    3. Install Xcode CLT: xcode-select --install"
    echo "    4. Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "    5. Clone dotfiles: gh repo clone ezra-gocci/dotfiles ~/.dotfiles"
    echo "    6. Run restore: cd ~/.dotfiles && ./install.sh"
    echo ""
}

# ═══════════════════════════════════════════════════════════
# Main
# ═══════════════════════════════════════════════════════════

main() {
    # Ensure we're in the dotfiles directory
    if [ ! -d "$DOTFILES_DIR" ]; then
        echo -e "${RED}Error: Dotfiles directory not found at $DOTFILES_DIR${NC}"
        echo "Set DOTFILES_DIR environment variable or clone your dotfiles first."
        exit 1
    fi

    # Phase 1: Inventory
    phase_inventory

    # Phase 2: Selection
    phase_selection

    # Phase 3: Execute selected backups
    print_header "Phase 3: Executing Backups"

    [ "${ITEMS[brewfile]}" -eq 1 ] && backup_brewfile
    [ "${ITEMS[configs]}" -eq 1 ] && backup_configs
    [ "${ITEMS[ssh_keys]}" -eq 1 ] && backup_ssh_keys
    [ "${ITEMS[personal_files]}" -eq 1 ] && backup_personal_files
    [ "${ITEMS[git_repos]}" -eq 1 ] && verify_git_repos
    [ "${ITEMS[claude]}" -eq 1 ] && backup_claude
    [ "${ITEMS[app_prefs]}" -eq 1 ] && backup_app_prefs
    [ "${ITEMS[credentials]}" -eq 1 ] && backup_credentials

    # Phase 4: Manifest & commit
    phase_manifest

    # Summary
    print_summary
}

main "$@"
