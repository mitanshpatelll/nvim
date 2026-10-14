-- ============================================================================
--  :Doctor — check that this machine has everything the config needs.
--
--  Written because the same config behaves differently on macOS and Linux:
--  Ubuntu's apt Neovim is too old, the clipboard needs a helper that macOS
--  provides for free, and tree-sitter needs a compiler that may not be there.
--  Each failure produces its own confusing error at a different moment, so
--  this reports all of them at once with the fix next to each.
-- ============================================================================

local M = {}

local function exists(bin)
  return vim.fn.executable(bin) == 1
end

--- @return table rows  {status, label, detail, fix}
local function collect()
  local rows = {}
  local function add(ok, label, detail, fix)
    rows[#rows + 1] = { ok = ok, label = label, detail = detail or "", fix = fix }
  end

  local linux = vim.fn.has("unix") == 1 and vim.fn.has("mac") == 0

  -- Neovim ---------------------------------------------------------------
  local v = vim.version()
  add(vim.fn.has("nvim-0.11") == 1, "Neovim >= 0.11",
    string.format("%d.%d.%d", v.major, v.minor, v.patch),
    "Ubuntu apt ships 0.9.5. Use the official tarball or install-ubuntu.sh")

  -- Build toolchain ------------------------------------------------------
  local cc = exists("cc") or exists("gcc") or exists("clang")
  add(cc, "C compiler", cc and (exists("cc") and "cc" or exists("gcc") and "gcc" or "clang") or "missing",
    linux and "sudo apt install build-essential" or "xcode-select --install")
  add(exists("make"), "make", exists("make") and "found" or "missing",
    linux and "sudo apt install build-essential" or "xcode-select --install")

  -- Core tools -----------------------------------------------------------
  add(exists("git"), "git", exists("git") and "found" or "missing",
    linux and "sudo apt install git" or "brew install git")
  add(exists("rg"), "ripgrep", exists("rg") and "found" or "missing",
    linux and "sudo apt install ripgrep" or "brew install ripgrep")
  add(exists("node"), "node", exists("node") and vim.fn.system("node -v"):gsub("%s+$", "") or "missing",
    "needed by the JS/TS language servers; install via nvm")
  add(exists("lazygit"), "lazygit", exists("lazygit") and "found" or "missing (only <leader>gg needs it)",
    linux and "download from github.com/jesseduffield/lazygit/releases" or "brew install lazygit")

  -- Clipboard: the classic Linux trap ------------------------------------
  local clip = vim.fn.has("clipboard") == 1
  local clip_tool = exists("pbcopy") and "pbcopy"
    or exists("wl-copy") and "wl-copy"
    or exists("xclip") and "xclip"
    or exists("xsel") and "xsel"
    or nil
  add(clip and clip_tool ~= nil, "system clipboard", clip_tool or "NO HELPER FOUND",
    "sudo apt install wl-clipboard xclip  (without one, yank never leaves Neovim)")

  -- Tree-sitter ----------------------------------------------------------
  local parser_dir = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter/parser"
  local parsers = vim.fn.glob(parser_dir .. "/*.so", false, true)
  add(#parsers >= 15, "tree-sitter parsers", #parsers .. " compiled",
    "if this is low, the C compiler is missing; fix that then run :TSUpdateSync")

  -- Mason ----------------------------------------------------------------
  local mason_dir = vim.fn.stdpath("data") .. "/mason/packages"
  local tools = vim.fn.isdirectory(mason_dir) == 1 and vim.fn.readdir(mason_dir) or {}
  add(#tools >= 10, "mason tools", #tools .. " installed",
    "run :Mason and check for failures; most need node")

  -- Plugins --------------------------------------------------------------
  local ok_lazy, lazy = pcall(require, "lazy")
  if ok_lazy then
    local stats = lazy.stats()
    add(stats.count > 0, "plugins", stats.count .. " loaded, startup " ..
      string.format("%.1f", stats.startuptime) .. "ms", "run :Lazy for details")
  end

  -- Font -----------------------------------------------------------------
  add(true, "Nerd Font", "cannot be detected from inside Neovim",
    "if icons look like boxes, install JetBrainsMono Nerd Font and set it in your terminal")

  return rows
end

function M.run()
  local rows = collect()
  local lines = { "", "  Neovim setup check", "  " .. string.rep("-", 62), "" }
  local problems = 0

  for _, r in ipairs(rows) do
    local mark = r.ok and "OK  " or "FAIL"
    if not r.ok then
      problems = problems + 1
    end
    lines[#lines + 1] = string.format("  [%s] %-22s %s", mark, r.label, r.detail)
    if not r.ok and r.fix then
      lines[#lines + 1] = string.format("         -> %s", r.fix)
    end
  end

  lines[#lines + 1] = ""
  if problems == 0 then
    lines[#lines + 1] = "  Everything the config needs is present."
  else
    lines[#lines + 1] = string.format("  %d problem%s found. Fix the FAIL lines above, then restart Neovim.",
      problems, problems == 1 and "" or "s")
  end
  lines[#lines + 1] = ""

  -- Show in a scratch buffer so it can be read, scrolled and copied.
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  local width = 70
  local height = math.min(#lines + 2, vim.o.lines - 6)
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " :Doctor ",
    title_pos = "center",
  })
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
end

vim.api.nvim_create_user_command("Doctor", M.run, { desc = "Check this machine has what the config needs" })

return M
