-- ============================================================================
--  Neovim config  —  minimal, VS Code-flavoured, leader-driven
--
--  Leader key is <Space>. Press <Space> in normal mode and WAIT — a popup
--  menu appears showing every key you can press next. You never have to
--  memorise anything; the menu teaches you.
--
--  Full key list:  :Cheatsheet     (or open ~/.config/nvim/CHEATSHEET.md)
--  Plugin manager: :Lazy
--  LSP / tools:    :Mason
--  Health check:   :checkhealth
-- ============================================================================

-- ---------------------------------------------------------------------------
-- Version guard.
--
-- This config calls vim.lsp.config, vim.diagnostic.jump and vim.hl.on_yank,
-- all of which landed in Neovim 0.11. On anything older every one of those is
-- nil and you get a cascade of unrelated errors on each keystroke, which tells
-- you nothing. Fail once, clearly, instead.
--
-- Ubuntu 24.04's apt ships 0.9.5. Install a current build from the official
-- release tarball (see install-ubuntu.sh) rather than apt.
-- ---------------------------------------------------------------------------
if vim.fn.has("nvim-0.11") == 0 then
  local msg = {
    "",
    "  This Neovim is too old for this config.",
    "",
    "    running : " .. tostring(vim.version()),
    "    needed  : 0.11 or newer",
    "",
    "  Nothing below will work until that is fixed. On Ubuntu, apt ships 0.9.5;",
    "  install the official tarball instead:",
    "",
    "    curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz",
    "    sudo rm -rf /opt/nvim && sudo mkdir -p /opt/nvim",
    "    sudo tar -C /opt/nvim --strip-components=1 -xzf nvim-linux-x86_64.tar.gz",
    "    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim",
    "",
    "  Or run install-ubuntu.sh from this repo, which does it for you.",
    "",
  }
  vim.schedule(function()
    vim.api.nvim_echo({ { table.concat(msg, "\n"), "ErrorMsg" } }, true, {})
  end)
  return
end

-- Leader must be set BEFORE plugins load, or mappings bind to the wrong key.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")

-- ---------------------------------------------------------------------------
-- Bootstrap lazy.nvim (the plugin manager). Clones itself on first launch.
-- ---------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" },
}, {
  ui = { border = "rounded" },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = false },          -- don't nag about plugin updates
  rocks = { enabled = false },           -- no plugin here needs luarocks, and
                                         -- leaving it on makes :checkhealth
                                         -- report a permanent ERROR
  change_detection = { notify = false },  -- don't nag when you edit this config
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "zipPlugin", "tutor" },
    },
  },
})

-- Apply the saved colour theme (<leader>ut cycles between the three installed).
require("core.theme").load()

-- Keymaps and autocmds load AFTER plugins so every command they reference exists.
require("core.keymaps")
require("core.autocmds")
