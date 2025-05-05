-- use options from nvchad
require "nvchad.options"

-- additional filetype bindings
vim.filetype.add {
  extension = {
    env = "conf",
  },
  filename = {
    ["terraform.tfstate"] = "json",
    ["terraform.tfstate.backup"] = "json",
  },
  pattern = {
    [".env.*"] = "conf",
  },
}

-- enable inlay hints
vim.lsp.inlay_hint.enable(true, { 0 })

local o = vim.o

-- to enable cursorline
o.cursorlineopt = "both"
-- enables 24-bit RGB color
o.termguicolors = true
-- avoid error when displaying Chinese
o.encoding = "utf-8"
-- don't wrap lines when it's longer than the window width
o.wrap = false
-- -- cursor will always be 3 lines above the window edge
-- o.scrolloff = 3
-- disable search highlighting
o.hlsearch = false
-- enable spell checking
o.spell = true
-- "yusong" refers to nvim/spell/yusong.utf-8.spl
-- every time after nvim/spell/yusong being modified,
-- remember to run command (":mkspell") to generate `.spl`.
o.spelllang = "en_us,cjk,yusong"
-- fold by treesitter
o.foldmethod = "expr"
o.foldexpr = "nvim_treesitter#foldexpr()"
o.foldlevelstart = 99
-- indenting
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
-- disable right-click menu
o.mousemodel = "extend"
-- always show status in the last window
o.laststatus = 3

-- autocmd --
local autocmd = vim.api.nvim_create_autocmd

-- make generated directories and files readonly
autocmd({ "BufRead" }, {
  pattern = {
    "**/node_modules/**",
    "**/.venv/**",
    "**/target/**",
    "**/.direnv/**",
    "flake.lock",
    "Cargo.lock",
    "uv.lock",
  },
  callback = function()
    vim.bo.readonly = true
  end,
})

-- when current buffer is readonly,
-- set no modifiable and disable diagnostics
autocmd("BufReadPost", {
  callback = function()
    vim.bo.modifiable = not vim.bo.readonly
    vim.diagnostic.enable(not vim.bo.readonly, { bufnr = 0 })
  end,
})

-- set indent size by filetype
autocmd("Filetype", {
  command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2",
  pattern = {
    "javascript",
    "typescript",
    "terraform",
    "sshconfig",
    "markdown",
    "xhtml",
    "json",
    "jsonc",
    "html",
    "scss",
    "yaml",
    "yml",
    "xml",
    "css",
    "nix",
    "lua",
  },
})

-- set `textwidth` in markdown files.
autocmd("Filetype", {
  pattern = { "markdown" },
  command = "setlocal textwidth=80",
})

-- restore cursor position on file open
autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line "'\""
    if
      line > 1
      and line <= vim.fn.line "$"
      and vim.bo.filetype ~= "commit"
      and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
    then
      vim.cmd 'normal! g`"'
    end
  end,
})

-- turn off spell checking in terminal mode
autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    vim.o.spell = false
  end,
})
