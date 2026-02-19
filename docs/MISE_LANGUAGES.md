# 🛠️ mise - Language Version Management

Complete guide to setting up Python, TypeScript, Go, and Rust development environments using mise.

## 📋 Table of Contents

- [What is mise?](#what-is-mise)
- [Python Development](#python-development)
- [TypeScript/Node.js Development](#typescriptnodesjs-development)
- [Go Development](#go-development)
- [Rust Development](#rust-development)
- [Project-Specific Versions](#project-specific-versions)
- [Global Configuration](#global-configuration)
- [Common Workflows](#common-workflows)

---

## 🎯 What is mise?

**mise** (formerly rtx) is a universal version manager that replaces:
- **pyenv** (Python)
- **nvm** / **fnm** (Node.js)
- **gvm** (Go)
- **rustup** (Rust)
- **rbenv** (Ruby)
- And 100+ other language tools

### Why mise?

✅ **Single tool** for all languages
✅ **Fast** - Written in Rust
✅ **Compatible** with existing `.node-version`, `.python-version` files
✅ **Project-aware** - Auto-switches versions per directory
✅ **No shims** - Direct PATH manipulation
✅ **Global & local** versions

### Installation

Already installed via Brewfile! Verify:

```bash
mise --version
# Output: mise 2024.x.x
```

---

## 🐍 Python Development

### Install Python Versions

```bash
# List available Python versions
mise list-remote python

# Install latest Python 3.12
mise install python@3.12

# Install specific version
mise install python@3.12.1

# Install multiple versions
mise install python@3.11 python@3.10

# Install latest patch version
mise install python@latest
```

### Set Python Versions

```bash
# Set global default
mise use --global python@3.12

# Set for current directory (creates .mise.toml)
mise use python@3.12

# Use multiple versions
mise use python@3.12 python@3.11
```

### Python Development Setup

```bash
# 1. Set Python version for project
cd ~/projects/my-python-app
mise use python@3.12

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Install development tools
pip install black ruff mypy pytest ipython

# Alternatively, use mise for tools too!
mise install python-tools@black
mise install python-tools@ruff
```

### Python Project Structure

```
my-python-app/
├── .mise.toml              # mise configuration
├── requirements.txt        # Production dependencies
├── requirements-dev.txt    # Development dependencies
├── pyproject.toml         # Project metadata
├── setup.py               # Package setup
└── src/
    └── main.py
```

### .mise.toml for Python

```toml
[tools]
python = "3.12"

[env]
# Python environment variables
PYTHONPATH = "./src"
PYTHONDONTWRITEBYTECODE = "1"

[tasks.test]
run = "pytest tests/"

[tasks.lint]
run = "ruff check ."

[tasks.format]
run = "black ."

[tasks.dev]
run = "python -m uvicorn src.main:app --reload"
```

### Python Tools via mise

```bash
# Install Python development tools globally
mise install uv             # Fast pip replacement
mise install pipx           # Install Python apps
mise install poetry         # Dependency management
mise install pdm            # Modern Python package manager

# Use tools
mise exec uv -- pip install django
mise exec poetry -- init
```

### Common Python Commands

```bash
# Which Python is active?
which python
mise which python

# List installed Python versions
mise list python

# Update Python
mise install python@latest
mise use --global python@latest

# Remove old version
mise uninstall python@3.10
```

---

## 🟦 TypeScript/Node.js Development

### Install Node.js Versions

```bash
# List available Node versions
mise list-remote node

# Install LTS version
mise install node@lts

# Install latest version
mise install node@latest

# Install specific version
mise install node@20.11.0

# Install multiple versions
mise install node@20 node@18 node@16
```

### Set Node.js Versions

```bash
# Set global default
mise use --global node@lts

# Set for project
cd ~/projects/my-typescript-app
mise use node@20

# Create .node-version file (compatible with nvm)
echo "20" > .node-version
mise install  # Reads .node-version automatically
```

### TypeScript Project Setup

```bash
# 1. Set Node version
cd ~/projects/my-typescript-app
mise use node@20

# 2. Initialize npm project
npm init -y

# 3. Install TypeScript
npm install --save-dev typescript @types/node

# 4. Initialize TypeScript config
npx tsc --init

# 5. Install development tools
npm install --save-dev \
    eslint \
    prettier \
    @typescript-eslint/parser \
    @typescript-eslint/eslint-plugin \
    ts-node \
    nodemon

# 6. Install tsx (fast TypeScript runner)
mise install tsx
```

### TypeScript Project Structure

```
my-typescript-app/
├── .mise.toml              # mise configuration
├── .node-version           # Node version (nvm compatible)
├── package.json            # Dependencies
├── tsconfig.json          # TypeScript config
├── .eslintrc.js           # ESLint config
├── .prettierrc            # Prettier config
└── src/
    ├── index.ts
    └── types/
```

### .mise.toml for TypeScript

```toml
[tools]
node = "20"

[env]
NODE_ENV = "development"

[tasks.dev]
run = "tsx watch src/index.ts"

[tasks.build]
run = "tsc"

[tasks.test]
run = "npm test"

[tasks.lint]
run = "eslint src --ext .ts"

[tasks.format]
run = "prettier --write 'src/**/*.ts'"

[tasks.start]
run = "node dist/index.js"
```

### Node Package Managers via mise

```bash
# Install alternative package managers
mise install pnpm           # Fast, disk-efficient
mise install yarn           # Alternative to npm
mise install bun            # Fast all-in-one toolkit

# Use them
pnpm install
yarn add lodash
bun install
```

### Common Node.js Commands

```bash
# Which Node is active?
which node
mise which node

# List installed versions
mise list node

# Run npm with specific version
mise exec node@18 -- npm install

# Multiple Node versions in same terminal
mise shell node@20  # Temporarily switch
```

---

## 🐹 Go Development

### Install Go Versions

```bash
# List available Go versions
mise list-remote go

# Install latest Go
mise install go@latest

# Install specific version
mise install go@1.22.0

# Install multiple versions
mise install go@1.22 go@1.21
```

### Set Go Versions

```bash
# Set global default
mise use --global go@latest

# Set for project
cd ~/projects/my-go-app
mise use go@1.22
```

### Go Project Setup

```bash
# 1. Set Go version
cd ~/projects/my-go-app
mise use go@1.22

# 2. Initialize Go module
go mod init github.com/username/my-go-app

# 3. Create main.go
cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
EOF

# 4. Install development tools
go install golang.org/x/tools/gopls@latest           # LSP
go install github.com/go-delve/delve/cmd/dlv@latest  # Debugger
go install honnef.co/go/tools/cmd/staticcheck@latest # Linter

# 5. Run the app
go run main.go
```

### Go Project Structure

```
my-go-app/
├── .mise.toml              # mise configuration
├── go.mod                  # Module definition
├── go.sum                  # Dependency checksums
├── main.go                 # Entry point
├── cmd/                    # Command-line tools
├── pkg/                    # Public libraries
└── internal/               # Private code
```

### .mise.toml for Go

```toml
[tools]
go = "1.22"

[env]
# Go environment variables
GOPATH = "{{env.HOME}}/go"
GO111MODULE = "on"
CGO_ENABLED = "1"

[tasks.run]
run = "go run main.go"

[tasks.build]
run = "go build -o bin/app"

[tasks.test]
run = "go test ./..."

[tasks.lint]
run = "staticcheck ./..."

[tasks.format]
run = "gofmt -w ."

[tasks.tidy]
run = "go mod tidy"
```

### Go Tools via mise

```bash
# Install Go development tools
go install golang.org/x/tools/gopls@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install github.com/cosmtrek/air@latest  # Hot reload

# Verify installation
gopls version
golangci-lint --version
```

### Common Go Commands

```bash
# Which Go is active?
which go
mise which go

# List installed versions
mise list go

# Download dependencies
go mod download

# Update dependencies
go get -u ./...
go mod tidy

# Build for different platforms
GOOS=linux GOARCH=amd64 go build
GOOS=windows GOARCH=amd64 go build
```

---

## 🦀 Rust Development

### Install Rust via rustup (Recommended)

**Note:** For Rust, we recommend using `rustup` directly instead of mise, as rustup is the official Rust toolchain manager with better integration.

```bash
# Install rustup (if not already installed)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Or via Homebrew
brew install rustup-init
rustup-init

# Install stable Rust
rustup install stable

# Install nightly Rust (for latest features)
rustup install nightly

# Install beta Rust
rustup install beta
```

### Alternative: Rust via mise

```bash
# Install Rust via mise (alternative to rustup)
mise install rust@latest

# Install specific version
mise install rust@1.75.0

# Set global version
mise use --global rust@latest

# Set for project
mise use rust@stable
```

### Rust Project Setup

```bash
# 1. Create new project
cargo new my-rust-app
cd my-rust-app

# 2. Or create a library
cargo new --lib my-rust-lib

# 3. Project is ready! (Cargo.toml and src/ created)

# 4. Install development tools
rustup component add rustfmt      # Formatter
rustup component add clippy       # Linter
rustup component add rust-analyzer # LSP

# 5. Install additional tools
cargo install cargo-watch         # Auto-rebuild on changes
cargo install cargo-edit          # Cargo add/rm/upgrade commands
cargo install cargo-outdated      # Check for outdated deps
```

### Rust Project Structure

```
my-rust-app/
├── .mise.toml              # mise configuration (optional)
├── Cargo.toml              # Package manifest
├── Cargo.lock              # Dependency lock file
├── src/
│   ├── main.rs            # Entry point (for binary)
│   └── lib.rs             # Entry point (for library)
└── tests/                  # Integration tests
```

### .mise.toml for Rust

```toml
[tools]
# If using mise for Rust
rust = "stable"

# Or use rustup channels via mise
# rust = "nightly"

[env]
RUST_BACKTRACE = "1"
CARGO_INCREMENTAL = "1"

[tasks.run]
run = "cargo run"

[tasks.build]
run = "cargo build --release"

[tasks.test]
run = "cargo test"

[tasks.lint]
run = "cargo clippy -- -D warnings"

[tasks.format]
run = "cargo fmt"

[tasks.check]
run = "cargo check"

[tasks.doc]
run = "cargo doc --open"

[tasks.watch]
run = "cargo watch -x run"
```

### Rust Toolchain Management

```bash
# With rustup (recommended)
rustup default stable        # Use stable by default
rustup default nightly       # Use nightly by default

# Per-project toolchain (create rust-toolchain.toml)
cat > rust-toolchain.toml << 'EOF'
[toolchain]
channel = "stable"
components = ["rustfmt", "clippy"]
targets = ["wasm32-unknown-unknown"]
EOF

# Update Rust
rustup update

# Show installed toolchains
rustup show

# Add compile targets
rustup target add wasm32-unknown-unknown
rustup target add aarch64-apple-darwin
```

### Common Rust Commands

```bash
# Which Rust is active?
which rustc
rustc --version
cargo --version

# Build project
cargo build          # Debug build
cargo build --release # Optimized build

# Run project
cargo run
cargo run --release

# Test project
cargo test
cargo test --lib      # Library tests only
cargo test --test integration_test # Specific test

# Format code
cargo fmt

# Lint code
cargo clippy

# Update dependencies
cargo update

# Add dependency
cargo add serde      # Requires cargo-edit
# Or edit Cargo.toml manually

# Check without building
cargo check
```

### Rust Cross-Compilation

```bash
# Install target
rustup target add x86_64-unknown-linux-gnu

# Build for target
cargo build --target x86_64-unknown-linux-gnu

# Common targets
rustup target add x86_64-pc-windows-gnu     # Windows
rustup target add aarch64-apple-darwin      # Apple Silicon
rustup target add wasm32-unknown-unknown    # WebAssembly
```

---

## 📁 Project-Specific Versions

### .mise.toml (Recommended)

Create `.mise.toml` in your project root:

```toml
# Multi-language project example
[tools]
python = "3.12"
node = "20"
go = "1.22"

[env]
# Project-specific environment variables
DATABASE_URL = "postgresql://localhost/mydb"
API_KEY = "dev-key-123"

# Use other env vars
PROJECT_ROOT = "{{cwd}}"

[tasks]
# Define project tasks
[tasks.start]
run = "npm run dev"
description = "Start development server"

[tasks.test]
run = ["pytest", "npm test", "go test ./..."]
description = "Run all tests"

[tasks.setup]
run = """
npm install
pip install -r requirements.txt
go mod download
"""
description = "Setup project dependencies"
```

### Legacy Version Files

mise supports legacy version files from other tools:

```bash
# .node-version (nvm, fnm)
echo "20.11.0" > .node-version

# .python-version (pyenv)
echo "3.12.1" > .python-version

# .go-version (gvm)
echo "1.22.0" > .go-version

# .ruby-version (rbenv)
echo "3.3.0" > .ruby-version

# mise reads these automatically!
mise install
```

---

## 🌍 Global Configuration

### Set Global Defaults

```bash
# Set global default versions
mise use --global python@3.12
mise use --global node@lts
mise use --global go@latest

# View global config
cat ~/.config/mise/config.toml
```

### Global config.toml

Located at `~/.config/mise/config.toml`:

```toml
[tools]
python = "3.12"
node = "lts"
go = "latest"

[settings]
# Auto-install missing tools
auto_install = true

# Show version in prompt
show_env = true

# Use legacy version files
legacy_version_file = true

[env]
# Global environment variables
EDITOR = "nvim"
VISUAL = "nvim"
```

---

## 🔄 Common Workflows

### New Project Setup

```bash
# 1. Create project directory
mkdir my-project && cd my-project

# 2. Set language versions
mise use python@3.12 node@20

# 3. View active versions
mise current

# 4. Install dependencies
npm install
pip install -r requirements.txt

# 5. Start development
mise run dev
```

### Multi-Language Project

```bash
# Microservices with different languages
my-app/
├── .mise.toml           # Root config
├── backend/             # Go service
│   └── .mise.toml       # go@1.22
├── frontend/            # React app
│   └── .mise.toml       # node@20
└── scripts/             # Python scripts
    └── .mise.toml       # python@3.12

# mise auto-switches versions when you cd!
cd backend    # Uses Go 1.22
cd ../frontend # Uses Node 20
cd ../scripts  # Uses Python 3.12
```

### Update All Tools

```bash
# Update mise itself
brew upgrade mise

# Update all installed tools
mise upgrade

# Or update specific language
mise upgrade python
mise upgrade node

# Check for outdated versions
mise outdated
```

### Using Tasks

```bash
# Run defined tasks
mise run dev        # Start dev server
mise run test       # Run tests
mise run build      # Build project
mise run setup      # Setup dependencies

# List available tasks
mise tasks

# Run multiple tasks
mise run fmt lint test
```

### Development Environment

```bash
# Temporarily use different version (current shell only)
mise shell python@3.11

# Execute command with specific version
mise exec python@3.11 -- python script.py

# Check which tool will be used
mise which python
mise which node

# List all installed versions
mise list

# List only active versions
mise current
```

---

## 📚 Additional Resources

### Documentation

```bash
# Built-in help
mise help
mise help use
mise help install

# Show current configuration
mise doctor

# Debug issues
mise debug

# View environment
mise env
```

### Official Links

- **mise Documentation**: https://mise.jdx.dev
- **GitHub**: https://github.com/jdx/mise
- **Rust Documentation**: https://doc.rust-lang.org
- **Go Documentation**: https://go.dev/doc
- **Python Documentation**: https://docs.python.org
- **Node.js Documentation**: https://nodejs.org/docs

---

## 💡 Pro Tips

1. **Auto-install on cd**: Enable in `~/.config/mise/config.toml`:
   ```toml
   [settings]
   auto_install = true
   ```

2. **Shell integration**: Already enabled in your `.zshrc`:
   ```bash
   eval "$(mise activate zsh)"
   ```

3. **IDE Integration**: Most IDEs detect `.mise.toml` or legacy version files automatically

4. **Performance**: mise is faster than rbenv/pyenv because it doesn't use shims

5. **Trust**: mise asks you to trust `.mise.toml` files to prevent malicious code execution

---

**Last Updated**: 2026-02-05  
**mise Version**: 2024.x.x  
**Tested Languages**: Python, TypeScript/Node.js, Go, Rust
