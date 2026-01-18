-- ============================================
-- Neovim MERN Stack + Tokyo Night UI Setup
-- ============================================

-- Leader key
vim.g.mapleader = " "


-- General Options
-- ============================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.mouse = "a"
vim.o.timeoutlen = 300
vim.o.ttimeoutlen = 10
vim.o.timeoutlen = 300
vim.o.ttimeoutlen = 10

-- ============================================
-- Lazy.nvim Bootstrap
-- ============================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================
-- Plugins
-- ============================================

-- Mason (LSP/DAP installer)



require("lazy").setup({
  -- LSP + Completion
  { "neovim/nvim-lspconfig" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "saadparwaiz1/cmp_luasnip" },
  { "L3MON4D3/LuaSnip" },
  { "rafamadriz/friendly-snippets" },
  { "onsails/lspkind.nvim" },

    -- Mason (LSP/DAP installer)
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {},
},


  -- Mason LSP Config (connects Mason with nvim-lspconfig)
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "ts_ls", "html", "cssls", "jsonls", "eslint", "pyright" },
        automatic_installation = true,
      })
    end,
  },

  -- UI + Appearance
  { "folke/tokyonight.nvim", name = "tokyonight" },
  { "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "akinsho/bufferline.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Syntax Highlighting + Autotag
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  { "windwp/nvim-autopairs", config = true },
  { "windwp/nvim-ts-autotag", config = true },

  -- Recommended Add-ons
  { "nvim-telescope/telescope.nvim", tag = "0.1.5", dependencies = { "nvim-lua/plenary.nvim" } },
  { "numToStr/Comment.nvim", config = true },
  { "folke/which-key.nvim", event = "VeryLazy", opts = {} },
  { "tpope/vim-surround" },

  -- Tokyo Night Theme
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "storm", -- Options: "storm", "night", "moon", "day"
        transparent = true,
        terminal_colors = true,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
          sidebars = "transparent",
          floats = "transparent",
        },
      })
      vim.cmd("colorscheme tokyonight-storm")
    end,
  },

  {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        c = { "clang_format" },
        cpp = { "clang_format" },
      },
    })

    vim.keymap.set("n", "<leader>f", function()
      require("conform").format({ async = true })
    end, { desc = "Format file" })
  end,
},

   -- Run Code in Integrated Terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 15,
        open_mapping = [[<C-`>]],
        shade_terminals = true,
        start_in_insert = true,
        persist_size = true,
        direction = "float",
      })

      vim.keymap.set("n", "<C-`>", ":ToggleTerm<CR>", { noremap = true, silent = true })

      -- Smart Run (Ctrl+R)
      vim.keymap.set("n", "<C-r>", function()
        local ft = vim.bo.filetype
        local file = vim.fn.expand("%")
        local output = vim.fn.expand("%:r")
        local cmd = ({
          javascript = "node " .. file,
          typescript = "ts-node " .. file,
          python = "python3 " .. file,
          lua = "lua " .. file,
          sh = "bash " .. file,
          c = "gcc " .. file .. " -o " .. output .. " && " .. output,
          cpp = "g++ " .. file .. " -o " .. output .. " && " .. output,
        })[ft]
        if cmd then
          vim.cmd("ToggleTerm direction=float cmd='" .. cmd .. "'")
        else
          print("⚠ No run command configured for filetype: " .. ft)
        end
      end, { noremap = true, silent = true })
    end,
  },
})

-- ============================================
-- Treesitter
-- ============================================
require("nvim-ts-autotag").setup({
  ensure_installed = { "lua", "javascript", "typescript", "html", "css", "json" },
  highlight = { enable = true },
  autotag = { enable = true },
})

-- ============================================
-- Telescope Setup (Ctrl+P)
-- ============================================
local telescope = require("telescope")
telescope.setup({
  defaults = {
    mappings = {
      i = { ["<C-j>"] = "move_selection_next", ["<C-k>"] = "move_selection_previous" },
    },
  },
})
vim.keymap.set("n", "<C-p>", "<cmd>Telescope find_files<cr>", { noremap = true, silent = true })

-- ============================================ 
-- Autocompletion Setup 
-- ============================================ 
local cmp = require("cmp") 
local lspkind = require("lspkind") 
cmp.setup({ 
  snippet = { 
    expand = function(args) 
      require("luasnip").lsp_expand(args.body) 
    end, 
  }, 
  mapping = cmp.mapping.preset.insert({ 
    ["<C-Space>"] = cmp.mapping.complete(), 
    ["<CR>"] = cmp.mapping.confirm({ select = true }), 
    ["<Tab>"] = cmp.mapping.select_next_item(), 
    ["<S-Tab>"] = cmp.mapping.select_prev_item(), 
  }), 
  sources = cmp.config.sources({ 
    { name = "nvim_lsp" }, 
    { name = "luasnip" }, 
  }, { 
    { name = "buffer" }, 
    { name = "path" }, 
  }), 
  formatting = { 
    format = lspkind.cmp_format({ 
      mode = "symbol_text", 
      maxwidth = 50, 
      ellipsis_char = "...", 
    }), 
  }, 
}) 

-- ============================================ 
-- LSP Setup (MERN Stack) 
-- ============================================ 
require("lspconfig").pyright.setup({
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

local capabilities = require("cmp_nvim_lsp").default_capabilities() 
local lspconfig = require("lspconfig") 

local servers = { "ts_ls", "html", "cssls", "jsonls", "eslint","clangd", "pyright" } 
for _, s in ipairs(servers) do 
  if lspconfig[s] then 
    lspconfig[s].setup({ capabilities = capabilities }) 
  end 
end 


-- ============================================
-- Status Line (Lualine)
-- ============================================
require("lualine").setup({
  options = {
    theme = "tokyonight",
    section_separators = "",
    component_separators = "",
  },
})

-- ============================================
-- File Explorer
-- ============================================
require("nvim-tree").setup({
  view = { width = 30, side = "left" },
  renderer = { highlight_opened_files = "name" },
})
vim.keymap.set("n", "<C-e>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })

-- ============================================
-- Bufferline (Tabs)
-- ============================================
require("bufferline").setup({
  options = {
    mode = "tabs",
    show_buffer_close_icons = true,
    show_close_icon = false,
    diagnostics = "nvim_lsp",
  },
})

-- ============================
-- Conform Setup (Auto Formatter)
-- ============================
require("conform").setup({
  formatters_by_ft = {
    lua = { "stylua" },
    javascript = { "prettier" },
    typescript = { "prettier" },
    html = { "prettier" },
    css = { "prettier" },
    json = { "prettier" },
    c = { "clang_format" },
    cpp = { "clang_format" },
  },
})

-- ============================================
-- VS Code Style Keymaps
-- ============================================
vim.keymap.set("n", "<C-s>", ":w!<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-s>", "<Esc>:w!<CR>a", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>q", ":q!<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<leader>q", "<Esc>:q!<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-a>", "ggVG", { noremap = true, silent = true })
vim.keymap.set("i", "<C-a>", "<Esc>ggVG", { noremap = true, silent = true })

vim.keymap.set("v", "<C-c>", '"+y', { noremap = true, silent = true })
vim.keymap.set("n", "<C-c>", '"+yy', { noremap = true, silent = true })
vim.keymap.set("v", "<C-x>", '"+d', { noremap = true, silent = true })
vim.keymap.set("n", "<C-x>", '"+dd', { noremap = true, silent = true })
vim.keymap.set({ "n", "v", "i" }, "<C-v>", '"+p', { noremap = true, silent = true })

vim.keymap.set("n", "<C-z>", "u", { noremap = true, silent = true })
vim.keymap.set("i", "<C-z>", "<Esc>ua", { noremap = true, silent = true })
vim.keymap.set("n", "<C-y>", "<C-r>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-t>", ":tabnew<CR>", { noremap = true, silent = true })
vim.keymap.set("i", "<C-t>", "<Esc>:tabnew<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-w>", ":tabclose<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<Tab>", ":BufferLineCycleNext<CR>", { silent = true })
vim.keymap.set("i", "<S-Tab>", "<Esc>:BufferLineCycleNext<CR>", { silent = true })

vim.keymap.set("n", "<C-/>", "gcc", { noremap = false, silent = true })
vim.keymap.set("v", "<C-/>", "gc", { noremap = false, silent = true })

vim.keymap.set("n", "<A-Up>", ":m .-2<CR>==", { noremap = true, silent = true })
vim.keymap.set("n", "<A-Down>", ":m .+1<CR>==", { noremap = true, silent = true })
vim.keymap.set("v", "<A-Up>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "<A-Down>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })

vim.keymap.set("n", "<C-f>", "/", { noremap = true, silent = false })

-- Navigate splits with <leader> + arrows
vim.keymap.set('n', '<leader><Left>',  '<C-w>h', { silent = true })
vim.keymap.set('n', '<leader><Right>', '<C-w>l', { silent = true })
vim.keymap.set('n', '<leader><Up>',    '<C-w>k', { silent = true })
vim.keymap.set('n', '<leader><Down>',  '<C-w>j', { silent = true })

-- Error --
vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (file)" })
vim.keymap.set("n", "<leader>xw", "<cmd>Trouble diagnostics toggle workspace=true<cr>", { desc = "Diagnostics (workspace)" })
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List" })
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List" })

require("which-key").setup()

require("tokyonight").setup({
  style = "storm",
  transparent = true,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
  },
})
vim.cmd("colorscheme tokyonight-storm")


