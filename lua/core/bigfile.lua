-- ============================================================================
--  Large-file guard.
--
--  Tree-sitter parses the whole buffer, the LSP sends it to a server, and the
--  animation and colouriser plugins walk it on every redraw. On a normal file
--  that is fine - the largest here, TournamentRegisterModal.jsx at 2793 lines,
--  opens in about 370ms. On a minified bundle, a lock file or a log it is not,
--  and Neovim locks up with no explanation.
--
--  Above the threshold those features are switched off for that buffer only.
--  Everything else still works: you can read, edit, search and save normally.
-- ============================================================================

local M = {}

M.max_bytes = 1024 * 1024   -- 1 MB
M.max_lines = 5000

local function too_big(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return false
  end
  local ok, stats = pcall(vim.uv.fs_stat, name)
  if ok and stats and stats.size > M.max_bytes then
    return true, string.format("%.1f MB", stats.size / 1024 / 1024)
  end
  if vim.api.nvim_buf_line_count(buf) > M.max_lines then
    return true, vim.api.nvim_buf_line_count(buf) .. " lines"
  end
  return false
end

function M.setup()
  -- Any client that attaches to a flagged buffer gets detached again.
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("user_bigfile_lsp", { clear = true }),
    callback = function(event)
      if vim.b[event.buf].big_file then
        vim.schedule(function()
          pcall(vim.lsp.buf_detach_client, event.buf, event.data.client_id)
        end)
      end
    end,
  })

  vim.api.nvim_create_autocmd("BufReadPre", {
    group = vim.api.nvim_create_augroup("user_bigfile", { clear = true }),
    callback = function(event)
      local buf = event.buf
      -- BufReadPre runs before the lines exist, so check the file on disk.
      local name = vim.api.nvim_buf_get_name(buf)
      local ok, stats = pcall(vim.uv.fs_stat, name)
      local big_on_disk = ok and stats and stats.size > M.max_bytes

      vim.api.nvim_create_autocmd("BufReadPost", {
        buffer = buf,
        once = true,
        callback = function()
          local big, why = too_big(buf)
          if not (big or big_on_disk) then
            return
          end
          vim.b[buf].big_file = true

          -- Tree-sitter: the expensive one.
          pcall(vim.treesitter.stop, buf)
          vim.bo[buf].syntax = "off"

          -- Keep the language servers out of it. Detaching here is not enough:
          -- clients attach AFTER BufReadPost, so an immediate detach runs
          -- before they arrive and they attach anyway. The LspAttach autocmd
          -- below catches the ones that turn up later.
          for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
            pcall(vim.lsp.buf_detach_client, buf, client.id)
          end

          -- Per-window redraw work.
          vim.opt_local.foldmethod = "manual"
          vim.opt_local.spell = false
          vim.opt_local.list = false
          vim.opt_local.cursorline = false
          vim.opt_local.relativenumber = false

          -- Plugins that walk the buffer on redraw.
          pcall(function() require("ibl").setup_buffer(buf, { enabled = false }) end)
          pcall(vim.cmd, "ColorizerDetachFromBuffer")

          vim.notify(
            ("Large file (%s): tree-sitter, LSP and indent guides disabled for this buffer."):format(why or "big"),
            vim.log.levels.WARN,
            { title = "big file" }
          )
        end,
      })
    end,
  })
end

return M
