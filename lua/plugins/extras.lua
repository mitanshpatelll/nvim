-- ============================================================================
--  Additions from the config audit: git UI and editor polish.
-- ============================================================================

return {

  -- --------------------------------------------------------------------------
  -- LAZYGIT — full-screen git. Stage by line, browse the log, switch branches,
  -- resolve merge conflicts. Gitsigns still handles inline hunks.
  -- Inside lazygit: ? for help, q to quit, arrow keys / hjkl to move.
  -- --------------------------------------------------------------------------
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitCurrentFile", "LazyGitFilterCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    init = function()
      vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
      vim.g.lazygit_floating_window_scaling_factor = 0.95
    end,
  },

  -- --------------------------------------------------------------------------
  -- DIFFVIEW — side-by-side diffs and file history, the thing gitsigns can't do.
  -- Inside: <Tab> next file, q to close.
  -- --------------------------------------------------------------------------
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = { layout = "diff3_mixed", disable_diagnostics = true },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- INDENT GUIDES — your JSX nests 7+ levels deep; this draws the rails and
  -- highlights the block the cursor is actually inside.
  -- --------------------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│", tab_char = "│" },
      scope = { enabled = true, show_start = false, show_end = false },
      exclude = {
        filetypes = { "help", "alpha", "neo-tree", "Trouble", "lazy", "mason", "markdown", "toggleterm" },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- COLOURISER — paints the actual colour behind hex codes and rgb()/hsl().
  -- You have 461 CSS files.
  -- --------------------------------------------------------------------------
  {
    "catgoose/nvim-colorizer.lua",
    event = "BufReadPre",
    opts = {
      filetypes = { "css", "scss", "javascript", "javascriptreact", "typescript",
                    "typescriptreact", "html", "lua", "conf" },
      user_default_options = {
        names = false,        -- don't colour the word "red" in prose
        tailwind = true,      -- your web client uses tailwind
        css = true,
        css_fn = true,
        mode = "background",
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- FIND AND REPLACE across the project. Telescope's grep only finds;
  -- this edits. Results are a normal buffer you can edit and sync back.
  -- --------------------------------------------------------------------------
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar" },
    opts = { headerMaxWidth = 80 },
  },

  -- --------------------------------------------------------------------------
  -- TEXTOBJECTS — select and jump by syntax, not by line.
  --   vaf  select a whole function      vif  just its body
  --   vac  a class                      via  a parameter
  --   ]f / [f  next / previous function
  -- --------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "master",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter.configs").setup({
        textobjects = {
          select = {
            enable = true,
            lookahead = true,   -- jump forward to the next one automatically
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
              ["aa"] = "@parameter.outer",
              ["ia"] = "@parameter.inner",
              ["ai"] = "@conditional.outer",
              ["ii"] = "@conditional.inner",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start     = { ["]f"] = "@function.outer", ["]c"] = "@class.outer" },
            goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer" },
          },
          swap = {
            enable = true,
            swap_next     = { ["<leader>cA"] = "@parameter.inner" },
            swap_previous = { ["<leader>ca"] = "@parameter.inner" },
          },
        },
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- SURROUND — change what wraps a selection.
  --   cs"'   swap double quotes for single
  --   ysiw)  wrap the word in parentheses
  --   dst    delete the surrounding JSX/HTML tag
  -- --------------------------------------------------------------------------
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    opts = {},
  },

  -- --------------------------------------------------------------------------
  -- LSP PROGRESS + NOTIFICATIONS
  --
  -- tsserver takes ~8 seconds to index a project the size of the web client.
  -- During that window completions are thin and it looks broken, when it is
  -- only warming up. This puts a spinner in the corner saying so.
  --
  -- fidget also backs vim.notify, so messages become corner popups with a
  -- history (:Fidget history) instead of flashing once in the command line.
  -- --------------------------------------------------------------------------
  {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = {
      progress = {
        display = {
          done_icon = "",
          progress_icon = { pattern = "dots", period = 1 },
        },
      },
      notification = {
        override_vim_notify = true,   -- vim.notify -> fidget
        window = {
          winblend = 0,               -- keep the terminal blur visible
          border = "rounded",
          align = "bottom",
        },
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- BREADCRUMBS — the symbol path at the top of the window. Useful when JSX
  -- is nested seven levels deep and the opening tag has scrolled away.
  -- Click a crumb, or <leader>; to pick one from the keyboard.
  -- --------------------------------------------------------------------------
  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
    opts = {
      bar = {
        -- Don't draw a bar in panels, terminals or the dashboard.
        enable = function(buf, win, _)
          if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
            return false
          end
          local ft = vim.bo[buf].filetype
          local skip = { ["neo-tree"] = true, gitpanel = true, alpha = true,
                         TelescopePrompt = true, lazy = true, mason = true, help = true }
          if skip[ft] or vim.bo[buf].buftype ~= "" then
            return false
          end
          -- A winbar costs a line; not worth it in a short split.
          return vim.api.nvim_win_get_height(win) > 8
        end,
      },
    },
  },

  -- --------------------------------------------------------------------------
  -- ANIMATION — scroll, window resize, split open/close.
  -- Cursor is deliberately left to smear-cursor below, which does it better.
  -- --------------------------------------------------------------------------
  {
    "echasnovski/mini.animate",
    event = "VeryLazy",
    config = function()
      local animate = require("mini.animate")
      local function timing(ms)
        return animate.gen_timing.linear({ duration = ms, unit = "total" })
      end
      animate.setup({
        cursor = { enable = false },
        scroll = { enable = true, timing = timing(120) },
        resize = { enable = true, timing = timing(100) },
        open   = { enable = true, timing = timing(100) },
        close  = { enable = true, timing = timing(100) },
      })
    end,
  },

  -- --------------------------------------------------------------------------
  -- SMEAR CURSOR — a trail that follows the cursor between jumps.
  -- --------------------------------------------------------------------------
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      -- Every theme here is transparent, so Normal has no background and the
      -- plugin cannot blend the trail (its own comment: "Blending breaks with
      -- transparent backgrounds"). It then falls back to a neutral #303030.
      -- The right colour is whatever is ACTUALLY behind the text, which is
      -- Ghostty's background - #1d2129 - not the nvim theme's.
      transparent_bg_fallback_color = "#1d2129",

      -- Subtle and quick: you see the motion, you never wait for it.
      stiffness = 0.8,
      trailing_stiffness = 0.6,
      damping = 0.8,
      time_interval = 10,

      -- No trail while typing or in the terminal; it is distracting there.
      smear_insert_mode = false,
      smear_terminal_mode = false,

      -- Panels where a trail is just noise.
      filetypes_disabled = { "neo-tree", "gitpanel", "alpha", "TelescopePrompt", "lazy", "mason" },
    },
  },

  -- --------------------------------------------------------------------------
  -- TODO COMMENTS — highlights TODO / FIXME / HACK / NOTE and makes them
  -- searchable across the project.
  -- --------------------------------------------------------------------------
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TodoTelescope", "TodoQuickFix" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },   -- keep the gutter for gitsigns
  },
}
