# MacOS Reinstall — Claude Restore Checklist

After reinstalling MacOS, follow this checklist to restore Claude tools and context.

---

## 1. Install Claude Tools

```bash
# Claude Desktop (download from https://claude.ai/download)
# or via Homebrew if available:
brew install --cask claude

# Claude Code (CLI)
npm install -g @anthropic-ai/claude-code
# or
brew install claude-code
```

## 2. Authenticate

```bash
# Claude Code — sign in
claude login

# Claude Desktop — open app and sign in with your Anthropic account

# GitHub CLI
brew install gh
gh auth login
```

## 3. Restore Claude Code Config

```bash
# Clone dotfiles
gh repo clone ezra-gocci/dotfiles ~/Code/dotfiles

# Restore settings
mkdir -p ~/.claude
cp ~/Code/dotfiles/claude/claude-code/settings.json ~/.claude/
cp ~/Code/dotfiles/claude/claude-code/settings.local.json ~/.claude/

# Restore project memory (gives Claude Code context about your projects)
# For each project you clone, create the memory directory:

# fast-forward
gh repo clone ezra-gocci/fast-forward ~/Code/fast-forward
mkdir -p ~/.claude/projects/-Users-$(whoami)-Code-fast-forward/memory
# Create MEMORY.md with project context (see claude/project-memory/ for reference)

# github-cleanup
mkdir -p ~/.claude/projects/-Users-$(whoami)-Code-github-cleanup/memory
cp ~/Code/dotfiles/claude/project-memory/github-cleanup/MEMORY.md \
   ~/.claude/projects/-Users-$(whoami)-Code-github-cleanup/memory/
```

## 4. Restore Claude Desktop Config

```bash
# Copy desktop preferences
mkdir -p ~/Library/Application\ Support/Claude
cp ~/Code/dotfiles/claude/claude-desktop/claude_desktop_config.json \
   ~/Library/Application\ Support/Claude/
cp ~/Code/dotfiles/claude/claude-desktop/config.json \
   ~/Library/Application\ Support/Claude/
```

## 5. Clone Your Repos

```bash
mkdir -p ~/Code && cd ~/Code

# Main projects
gh repo clone ezra-gocci/fast-forward
gh repo clone ezra-gocci/cv
gh repo clone ezra-gocci/beat-em
gh repo clone ezra-gocci/lets-dance
gh repo clone ezra-gocci/investsmart
gh repo clone ezra-gocci/claude-vault
gh repo clone ezra-gocci/perfect-start
gh repo clone ezra-gocci/leet
gh repo clone ezra-gocci/dotfiles
```

## 6. Reference: Previous Session History

All previous Claude Code and Cowork session transcripts are preserved as markdown in:
```
ezra-gocci/claude-vault → sessions/
```

These are **read-only reference** — they won't load into the UI but contain all
meaningful dialog from before the reinstall.

---

## What You Get vs What's Gone

### ✅ Preserved (available after restore)
- Claude Code settings and permissions
- Claude Desktop config (trusted folders, shortcuts, sidebar mode)
- Project memory (MEMORY.md) — Claude knows your projects' context
- All session transcripts as searchable markdown in claude-vault
- All code repos on GitHub

### ⚠️ Gone (expected — fresh start)
- Claude Code session history in UI (no previous chats visible)
- Claude Desktop chat history in UI (server-side — may still show if same account)
- Cowork task history in UI
- Local caches, debug logs, shell snapshots
- Todo/plan state from previous sessions

### 💡 Tip: Bootstrapping Context
When you start a new Claude Code session in a project, add a `CLAUDE.md` file
to the project root. Claude reads it automatically. Your FastForward project
already has one. For other projects, reference the session transcripts in
claude-vault to recreate context.

---

## Saved Data Inventory

| Location in dotfiles | Restores to | Purpose |
|---------------------|-------------|---------|
| `claude/claude-code/settings.json` | `~/.claude/settings.json` | Global Claude Code settings |
| `claude/claude-code/settings.local.json` | `~/.claude/settings.local.json` | Local permissions (MCP, etc) |
| `claude/claude-code/history.jsonl` | Reference only | Command history |
| `claude/claude-code/plans/*.md` | Reference only | Session planning docs |
| `claude/claude-desktop/claude_desktop_config.json` | `~/Library/Application Support/Claude/` | Desktop app preferences |
| `claude/project-memory/*/MEMORY.md` | `~/.claude/projects/*/memory/` | Per-project context |
