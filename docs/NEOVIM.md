# Complete Neovim IDE Setup Guide for Development

Transform Neovim into a powerful IDE with LSP, debugging, Git integration, and modern tooling.

---

## 🎯 **What You'll Get**

- ✅ **LSP (Language Server Protocol)** - IntelliSense, go-to-definition, auto-completion
- ✅ **DAP (Debug Adapter Protocol)** - Full debugging support
- ✅ **File Explorer** - Neo-tree or nvim-tree
- ✅ **Fuzzy Finder** - Telescope for files, grep, symbols
- ✅ **Git Integration** - Fugitive, Gitsigns, LazyGit
- ✅ **Syntax Highlighting** - Treesitter (better than regex)
- ✅ **Auto-completion** - nvim-cmp with snippets
- ✅ **Formatting & Linting** - null-ls/conform.nvim
- ✅ **Terminal Integration** - Built-in toggleterm
- ✅ **Status Line** - Lualine
- ✅ **Tab Line** - Bufferline
- ✅ **Theme** - Gruvbox to match your terminal

---

## 🚀 **Quick Start: Three Options**

### **Option 1: LazyVim (Recommended for Beginners)**

Pre-configured distribution with everything included:

```bash
# Backup existing config
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup

# Install LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# Start Neovim (plugins auto-install)
nvim
```

**What you get instantly:**
- LSP for 50+ languages (auto-install)
- File explorer (neo-tree)
- Fuzzy finder (telescope)
- Git integration (lazygit, gitsigns)
- Debugging (nvim-dap)
- All keybindings pre-configured

**After first launch:**
```vim
:LazyExtras  " Install language-specific extras
" Select: python, typescript, rust, go, etc.
```

### **Option 2: Kickstart.nvim (Learning-Focused)**

Minimal starter config to understand Neovim from scratch:

```bash
git clone https://github.com/nvim-lua/kickstart.nvim.git ~/.config/nvim
nvim
```

**Teaches you:**
- How Neovim config works
- Lua basics
- Plugin management
- Build your own config

### **Option 3: Custom Setup (Full Control)**

Build from scratch using the configuration below.

---

## 📦 **Custom Configuration: Step-by-Step**

### **1. Install Plugin Manager (lazy.nvim)**

Create `~/.config/nvim/init.lua`:

```lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup("plugins")

-- Load core config
require("config.options")
require("config.keymaps")
require("config.autocmds")
```

### **2. Core Settings**

Create `~/.config/nvim/lua/config/options.lua`:

```lua
-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs and indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

-- Search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- Appearance
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.colorcolumn = "80"

-- Split windows
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Backup and swap
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false
vim.opt.undofile = true

-- Update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Mouse
vim.opt.mouse = "a"

-- Completion
vim.opt.completeopt = "menu,menuone,noselect"
```

### **3. Essential Plugins**

Create `~/.config/nvim/lua/plugins/init.lua`:

```lua
return {
  -- Color scheme (Gruvbox)
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000,
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
        transparent_mode = false,
      })
      vim.cmd("colorscheme gruvbox")
    end,
  },

  -- Treesitter (better syntax highlighting)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc", "query",
          "python", "javascript", "typescript",
          "rust", "go", "bash", "json", "yaml",
          "markdown", "html", "css"
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
  },

  -- Auto-completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Git integration
  { "tpope/vim-fugitive" },
  { "lewis6991/gitsigns.nvim" },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Buffer line
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Terminal
  { "akinsho/toggleterm.nvim", version = "*" },

  -- Debugging
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" } },
  { "theHamsta/nvim-dap-virtual-text" },

  -- Formatting and linting
  { "stevearc/conform.nvim" },
  { "mfussenegger/nvim-lint" },

  -- Auto pairs
  { "windwp/nvim-autopairs" },

  -- Comments
  { "numToStr/Comment.nvim" },

  -- Surround
  { "kylechui/nvim-surround" },

  -- Which-key (show keybindings)
  { "folke/which-key.nvim" },

  -- Indent guides
  { "lukas-reineke/indent-blankline.nvim" },

  -- LazyGit integration
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
```

---

## 🔧 **LSP Configuration**

Create `~/.config/nvim/lua/plugins/lsp.lua`:

```lua
return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",           -- Lua
          "pyright",          -- Python
          "tsserver",         -- TypeScript/JavaScript
          "rust_analyzer",    -- Rust
          "gopls",            -- Go
          "bashls",           -- Bash
          "yamlls",           -- YAML
          "jsonls",           -- JSON
          "html",             -- HTML
          "cssls",            -- CSS
          "tailwindcss",      -- Tailwind
        },
        automatic_installation = true,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Keybindings for LSP
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, opts)
        end,
      })

      -- Configure each LSP server
      local servers = {
        "lua_ls", "pyright", "tsserver", "rust_analyzer",
        "gopls", "bashls", "yamlls", "jsonls", "html", "cssls"
      }

      for _, lsp in ipairs(servers) do
        lspconfig[lsp].setup({
          capabilities = capabilities,
        })
      end

      -- Lua specific config
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })
    end,
  },
}
```

---

## 💡 **Auto-completion Configuration**

Create `~/.config/nvim/lua/plugins/cmp.lua`:

```lua
return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif luasnip.expand_or_jumpable() then
            luasnip.expand_or_jump()
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          elseif luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
      }),
    })
  end,
}
```

---

## 🐛 **Debugging (DAP) Configuration**

Create `~/.config/nvim/lua/plugins/dap.lua`:

```lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",  -- Python debugging
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Setup DAP UI
      dapui.setup()

      -- Virtual text
      require("nvim-dap-virtual-text").setup()

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Python debugging setup
      require("dap-python").setup("python")

      -- Keybindings
      vim.keymap.set("n", "<F5>", dap.continue)
      vim.keymap.set("n", "<F10>", dap.step_over)
      vim.keymap.set("n", "<F11>", dap.step_into)
      vim.keymap.set("n", "<F12>", dap.step_out)
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
      vim.keymap.set("n", "<leader>dr", dap.repl.open)
    end,
  },
}
```

---

## 📁 **File Explorer Configuration**

Create `~/.config/nvim/lua/plugins/neo-tree.lua`:

```lua
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      close_if_last_window = true,
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
        },
      },
      window = {
        width = 30,
      },
    })

    -- Keybindings
    vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { silent = true })
    vim.keymap.set("n", "<leader>o", ":Neotree focus<CR>", { silent = true })
  end,
}
```

---

## 🔍 **Telescope (Fuzzy Finder) Configuration**

Create `~/.config/nvim/lua/plugins/telescope.lua`:

```lua
return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local telescope = require("telescope")
    local builtin = require("telescope.builtin")

    telescope.setup({
      defaults = {
        file_ignore_patterns = { "node_modules", ".git/" },
      },
    })

    -- Keybindings
    vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
    vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
    vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, {})
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, {})
  end,
}
```

---

## 🎨 **Git Integration**

Create `~/.config/nvim/lua/plugins/git.lua`:

```lua
return {
  -- Gitsigns (inline git blame, hunks)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "│" },
          change = { text = "│" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          -- Keybindings
          vim.keymap.set("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
          end, { expr = true, buffer = bufnr })

          vim.keymap.set("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
          end, { expr = true, buffer = bufnr })

          vim.keymap.set("n", "<leader>hp", gs.preview_hunk, { buffer = bufnr })
          vim.keymap.set("n", "<leader>hb", gs.blame_line, { buffer = bufnr })
        end,
      })
    end,
  },

  -- Fugitive (Git commands)
  { "tpope/vim-fugitive" },

  -- LazyGit (TUI for Git)
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>gg", ":LazyGit<CR>", { silent = true })
    end,
  },
}
```

---

## ⌨️ **Essential Keybindings**

Create `~/.config/nvim/lua/config/keymaps.lua`:

```lua
-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local keymap = vim.keymap

-- General keymaps
keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
keymap.set("n", "<leader>x", ":x<CR>", { desc = "Save and quit" })

-- Window navigation
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to bottom window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to top window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Window resizing
keymap.set("n", "<C-Up>", ":resize +2<CR>")
keymap.set("n", "<C-Down>", ":resize -2<CR>")
keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")

-- Buffer navigation
keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
keymap.set("n", "<S-Tab>", ":bprevious<CR>", { desc = "Previous buffer" })
keymap.set("n", "<leader>bd", ":bdelete<CR>", { desc = "Delete buffer" })

-- Split windows
keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "Split vertically" })
keymap.set("n", "<leader>sh", ":split<CR>", { desc = "Split horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Equal splits" })
keymap.set("n", "<leader>sx", ":close<CR>", { desc = "Close split" })

-- Indenting
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Move lines
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Clear search highlight
keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })

-- Better paste
keymap.set("v", "p", '"_dP')

-- Keep cursor centered
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
```

---

## 📋 **Complete Keybinding Reference**

### **Leader Key: `Space`**

| Keybinding | Action | Plugin |
|------------|--------|--------|
| **File Explorer** | | |
| `<leader>e` | Toggle file tree | Neo-tree |
| `<leader>o` | Focus file tree | Neo-tree |
| **Telescope (Fuzzy Finder)** | | |
| `<leader>ff` | Find files | Telescope |
| `<leader>fg` | Live grep (search in files) | Telescope |
| `<leader>fb` | Find buffers | Telescope |
| `<leader>fr` | Recent files | Telescope |
| `<leader>fs` | Find symbols | Telescope |
| **LSP** | | |
| `gd` | Go to definition | LSP |
| `gD` | Go to declaration | LSP |
| `gr` | Find references | LSP |
| `gi` | Go to implementation | LSP |
| `K` | Hover documentation | LSP |
| `<leader>rn` | Rename symbol | LSP |
| `<leader>ca` | Code actions | LSP |
| `<leader>f` | Format file | LSP |
| **Debugging** | | |
| `F5` | Continue/Start debugging | DAP |
| `F10` | Step over | DAP |
| `F11` | Step into | DAP |
| `F12` | Step out | DAP |
| `<leader>b` | Toggle breakpoint | DAP |
| `<leader>dr` | Open REPL | DAP |
| **Git** | | |
| `<leader>gg` | LazyGit | LazyGit |
| `<leader>hp` | Preview hunk | Gitsigns |
| `<leader>hb` | Blame line | Gitsigns |
| `]c` | Next hunk | Gitsigns |
| `[c` | Previous hunk | Gitsigns |
| **Buffers** | | |
| `Tab` | Next buffer | Built-in |
| `Shift-Tab` | Previous buffer | Built-in |
| `<leader>bd` | Delete buffer | Built-in |
| **Windows** | | |
| `Ctrl-h/j/k/l` | Navigate windows | Built-in |
| `<leader>sv` | Vertical split | Built-in |
| `<leader>sh` | Horizontal split | Built-in |
| `<leader>sx` | Close split | Built-in |
| **General** | | |
| `<leader>w` | Save file | Built-in |
| `<leader>q` | Quit | Built-in |
| `Esc` | Clear search highlight | Built-in |

---

## 🛠️ **Language-Specific Setup**

### **Python**

```bash
# Install language server
:Mason
# Search for: pyright, debugpy, black, ruff

# In Mason, press 'i' to install
```

Create `.nvim.lua` in your Python project:
```lua
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
```

### **JavaScript/TypeScript**

```bash
:Mason
# Install: tsserver, eslint_d, prettier
```

### **Rust**

```bash
:Mason
# Install: rust-analyzer, codelldb
```

### **Go**

```bash
:Mason
# Install: gopls, gofumpt, golangci-lint
```

---

## 🎓 **Learning Neovim**

### **Built-in Tutor**

```bash
:Tutor  # Interactive Vim tutorial
```

### **Essential Commands**

```vim
:help nvim                 " Main help
:checkhealth               " Diagnose issues
:Lazy                      " Manage plugins
:Mason                     " Manage LSP servers
:LspInfo                   " LSP status
:TSInstallInfo             " Treesitter status
```

### **Motion Commands**

```
h/j/k/l     - Left/Down/Up/Right
w/b         - Forward/Backward word
0/$         - Start/End of line
gg/G        - Top/Bottom of file
%           - Matching bracket
*/#         - Next/Previous occurrence
f{char}     - Find character forward
t{char}     - Till character forward
```

---

## 📚 **Additional Resources**

### **Install Language Servers via Mason**

```vim
:Mason

# Then search and install:
i - Install
X - Uninstall
U - Update
```

### **Popular Language Servers**

| Language | LSP | Formatter | Linter |
|----------|-----|-----------|--------|
| Python | pyright | black, ruff | ruff |
| TypeScript | tsserver | prettier | eslint |
| Rust | rust-analyzer | rustfmt | clippy |
| Go | gopls | gofumpt | golangci-lint |
| Lua | lua_ls | stylua | luacheck |
| JSON | jsonls | prettier | - |
| YAML | yamlls | prettier | yamllint |
| Bash | bashls | shfmt | shellcheck |

---

## 🚀 **Quick Setup Script**

Save as `~/.config/nvim/install.sh`:

```bash
#!/bin/bash
# Neovim Full IDE Setup

echo "Installing Neovim IDE configuration..."

# Backup existing config
if [ -d ~/.config/nvim ]; then
    mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
fi

# Install LazyVim (easiest option)
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

echo "✓ Configuration installed"
echo ""
echo "Next steps:"
echo "1. Run: nvim"
echo "2. Wait for plugins to install"
echo "3. Run: :checkhealth"
echo "4. Run: :Mason to install language servers"
echo ""
echo "Happy coding!"
```

---

## 💡 **Pro Tips**

1. **Start with LazyVim**: Learn the ecosystem first
2. **Use :checkhealth**: Diagnose issues
3. **Install Language Servers on demand**: Only what you need
4. **Learn motions gradually**: Focus on h/j/k/l first
5. **Use Which-Key**: Shows available keybindings
6. **Customize slowly**: Start with defaults, tweak later

---

## 🔥 **My Recommended Setup for Your Use Case**

Based on your profile (Python, JavaScript, multilingual dev):

```bash
# 1. Install LazyVim
git clone https://github.com/LazyVim/starter ~/.config/nvim
rm -rf ~/.config/nvim/.git

# 2. Start Neovim
nvim

# 3. Install extras (after first load)
:LazyExtras
# Select: python, typescript, rust, json, yaml

# 4. Install language servers
:Mason
# Install: pyright, tsserver, rust-analyzer, lua_ls
```

This gives you a complete IDE with everything you need!

---

**Next Steps After Reading This:**
1. Choose setup method (LazyVim recommended)
2. Install configuration
3. Open Neovim and let plugins install
4. Install language servers via :Mason
5. Start coding!

---

**Last Updated**: 2026-02-05  
**Neovim Version**: 0.10+  
**Tested on**: macOS Tahoe 26.x
