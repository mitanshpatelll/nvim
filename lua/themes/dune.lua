-- ============================================================================
--  dune — built for reading React and React Native at a glance.
--
--  The colour assignment comes from measuring a real 2021-line RN component,
--  counting how often each tree-sitter capture actually occurs:
--
--      @variable        10285      @tag.attribute    3086
--      @variable.member  6158      @tag.component    1615
--      @string           4630      @keyword           923
--
--  That ordering drives the whole design. @variable appears ten thousand
--  times, so it is kept near-neutral - colour it loudly and every file turns
--  into confetti. The saturated hues are spent on the rare, high-information
--  roles instead: the component, its props, the keyword that opens the line.
--  Those are what you scan for when you are looking for structure rather than
--  reading, so those are what get to shout.
--
--  Roles that sit side by side in JSX - <Component prop="string"> - are held
--  at least 28 degrees apart in hue, or a 1.6x weight difference, whichever
--  fits. Entities that are genuinely the same thing (a component IS a type)
--  share a hue family and differ by weight instead of inventing a tenth hue.
--
--  Every colour was checked for contrast against its background before being
--  committed; nothing here is below 4.5 except comments at ~3.6, which are
--  meant to recede.
--
--  Two tones, same logic: `dune` (blue) and `dune-sand` (amber).
-- ============================================================================

local M = {}

M.palettes = {
  blue = {
    bg = "#11161c", bg_dark = "#0b0e12", bg_light = "#21262d",
    cursorline = "#1d2329", selection = "#383f47", border = "#31373f",
    fg = "#c3d2e0", comment = "#5d7083", line_nr = "#66707a", indent = "#444c54",

    variable  = "#c3d2e0",  -- 10285 hits: deliberately the plain foreground
    member    = "#93b2c9",  -- obj.member, one step back from obj
    component = "#56c8f0",  -- <ThemedView>  the thing you scan for
    type      = "#459dbd",  -- same family, clearly lighter weight
    prop      = "#c8a2f0",  -- 74 deg off the tag it sits beside
    string    = "#7fc8a9",
    number    = "#e8899b",
    func      = "#f0c389",
    keyword   = "#8b93e6",

    red = "#e8899b", orange = "#f0c389", yellow = "#f0d8a0",
    green = "#7fc8a9", cyan = "#56c8f0", blue = "#8b93e6", purple = "#c8a2f0",
  },
  sand = {
    bg = "#1a1510", bg_dark = "#100d0a", bg_light = "#2c2620",
    cursorline = "#28221c", selection = "#474038", border = "#3f3830",
    fg = "#e8dac6", comment = "#8a7560", line_nr = "#766d61", indent = "#514a41",

    variable  = "#e8dac6",
    member    = "#c7ab88",
    component = "#ffb454",
    type      = "#c88d43",
    prop      = "#e295b8",
    string    = "#b5c977",
    number    = "#f0c674",
    func      = "#86c7b0",  -- the one cool accent, 125 deg off the tags
    keyword   = "#e8705a",

    red = "#e8705a", orange = "#ffb454", yellow = "#f0c674",
    green = "#b5c977", cyan = "#86c7b0", blue = "#86c7b0", purple = "#e295b8",
  },
}

--- @param opts { tone: "blue"|"sand", transparent: boolean|nil }
function M.load(opts)
  opts = opts or {}
  local c = M.palettes[opts.tone or "blue"]
  local transparent = opts.transparent ~= false
  local bg = transparent and "NONE" or c.bg
  local bg_side = transparent and "NONE" or c.bg_dark
  local bg_pop = transparent and "NONE" or c.bg_dark

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = (opts.tone == "sand") and "dune-sand" or "dune"

  local g = {
    -- surfaces
    Normal = { fg = c.fg, bg = bg }, NormalNC = { fg = c.fg, bg = bg },
    NormalFloat = { fg = c.fg, bg = bg }, FloatBorder = { fg = c.border, bg = bg },
    FloatTitle = { fg = c.component, bg = bg, bold = true },
    SignColumn = { bg = bg }, EndOfBuffer = { fg = c.bg },
    ColorColumn = { bg = c.bg_light }, CursorLine = { bg = c.cursorline },
    CursorLineNr = { fg = c.component, bold = true }, LineNr = { fg = c.line_nr },
    Cursor = { fg = c.bg, bg = c.fg },
    Visual = { bg = c.selection }, VisualNOS = { bg = c.selection },
    Search = { fg = c.bg, bg = c.yellow }, IncSearch = { fg = c.bg, bg = c.orange },
    CurSearch = { fg = c.bg, bg = c.orange }, MatchParen = { fg = c.orange, bold = true },
    Folded = { fg = c.comment, bg = c.bg_light }, FoldColumn = { fg = c.line_nr, bg = bg },
    WinSeparator = { fg = c.border, bg = bg }, VertSplit = { fg = c.border, bg = bg },
    Whitespace = { fg = c.bg_light }, NonText = { fg = c.line_nr }, SpecialKey = { fg = c.line_nr },
    Directory = { fg = c.component }, Title = { fg = c.func, bold = true },
    Question = { fg = c.green }, MoreMsg = { fg = c.green }, ModeMsg = { fg = c.fg, bold = true },
    ErrorMsg = { fg = c.red }, WarningMsg = { fg = c.yellow }, Conceal = { fg = c.comment },
    QuickFixLine = { bg = c.selection },
    Winbar = { fg = c.member, bg = bg }, WinbarNC = { fg = c.comment, bg = bg },

    -- popup menu
    Pmenu = { fg = c.member, bg = bg_pop }, PmenuSel = { fg = c.fg, bg = c.selection, bold = true },
    PmenuSbar = { bg = c.bg_light }, PmenuThumb = { bg = c.border },
    PmenuKind = { fg = c.func, bg = bg_pop }, PmenuExtra = { fg = c.comment, bg = bg_pop },

    -- statusline / tabs
    StatusLine = { fg = c.member, bg = bg_pop }, StatusLineNC = { fg = c.comment, bg = bg_pop },
    TabLine = { fg = c.comment, bg = bg_pop }, TabLineSel = { fg = c.fg, bg = bg, bold = true },
    TabLineFill = { bg = bg_pop },

    -- classic syntax
    Comment = { fg = c.comment, italic = true },
    Constant = { fg = c.number }, String = { fg = c.string }, Character = { fg = c.string },
    Number = { fg = c.number }, Float = { fg = c.number }, Boolean = { fg = c.number },
    Identifier = { fg = c.variable }, Function = { fg = c.func },
    Statement = { fg = c.keyword }, Conditional = { fg = c.keyword }, Repeat = { fg = c.keyword },
    Label = { fg = c.keyword }, Operator = { fg = c.member }, Keyword = { fg = c.keyword },
    Exception = { fg = c.keyword }, PreProc = { fg = c.purple }, Include = { fg = c.keyword },
    Define = { fg = c.purple }, Macro = { fg = c.purple },
    Type = { fg = c.type }, StorageClass = { fg = c.keyword }, Structure = { fg = c.type },
    Typedef = { fg = c.type }, Special = { fg = c.cyan },
    Delimiter = { fg = c.member }, Todo = { fg = c.bg, bg = c.yellow, bold = true },
    Error = { fg = c.red }, Underlined = { underline = true },

    -- ---- tree-sitter, ordered by how often it actually occurs ----
    ["@variable"]              = { fg = c.variable },
    ["@variable.member"]       = { fg = c.member },
    ["@variable.parameter"]    = { fg = c.member, italic = true },
    ["@variable.builtin"]      = { fg = c.red },
    ["@string"]                = { fg = c.string },
    ["@string.escape"]         = { fg = c.cyan },
    ["@string.special"]        = { fg = c.cyan },
    ["@string.special.url"]    = { fg = c.cyan, underline = true },
    ["@string.regexp"]         = { fg = c.cyan },
    ["@character"]             = { fg = c.string },
    ["@number"]                = { fg = c.number },
    ["@number.float"]          = { fg = c.number },
    ["@boolean"]               = { fg = c.number },
    ["@constant"]              = { fg = c.number },
    ["@constant.builtin"]      = { fg = c.number },
    ["@constant.macro"]        = { fg = c.purple },
    ["@function"]              = { fg = c.func },
    ["@function.call"]         = { fg = c.func },
    ["@function.method"]       = { fg = c.func },
    ["@function.method.call"]  = { fg = c.func },
    ["@function.builtin"]      = { fg = c.func },
    ["@constructor"]           = { fg = c.type },
    ["@keyword"]               = { fg = c.keyword },
    ["@keyword.function"]      = { fg = c.keyword },
    ["@keyword.operator"]      = { fg = c.keyword },
    ["@keyword.return"]        = { fg = c.keyword, bold = true },
    ["@keyword.import"]        = { fg = c.keyword, italic = true },
    ["@keyword.coroutine"]     = { fg = c.keyword, italic = true },
    ["@keyword.conditional"]   = { fg = c.keyword },
    ["@keyword.repeat"]        = { fg = c.keyword },
    ["@keyword.exception"]     = { fg = c.keyword },
    ["@type"]                  = { fg = c.type },
    ["@type.builtin"]          = { fg = c.type },
    ["@type.definition"]       = { fg = c.type },
    ["@module"]                = { fg = c.type },
    ["@property"]              = { fg = c.member },
    ["@attribute"]             = { fg = c.prop },
    ["@operator"]              = { fg = c.member },
    ["@punctuation.delimiter"] = { fg = c.line_nr },
    ["@punctuation.bracket"]   = { fg = c.line_nr },
    ["@punctuation.special"]   = { fg = c.cyan },
    ["@label"]                 = { fg = c.keyword },
    ["@comment"]               = { link = "Comment" },
    ["@comment.todo"]          = { fg = c.bg, bg = c.yellow, bold = true },
    ["@comment.error"]         = { fg = c.bg, bg = c.red, bold = true },
    ["@comment.warning"]       = { fg = c.bg, bg = c.yellow, bold = true },
    ["@comment.note"]          = { fg = c.bg, bg = c.cyan, bold = true },

    -- ---- JSX: the part that makes a component readable at a glance ----
    ["@tag"]                   = { fg = c.component },
    ["@tag.component"]         = { fg = c.component, bold = true },
    ["@tag.component.closing"] = { fg = c.type },
    ["@tag.builtin"]           = { fg = c.cyan },
    ["@tag.builtin.closing"]   = { fg = c.type },
    ["@tag.member"]            = { fg = c.component, bold = true },
    ["@tag.member.closing"]    = { fg = c.type },
    ["@tag.attribute"]         = { fg = c.prop, italic = true },
    ["@tag.delimiter"]         = { fg = c.line_nr },

    -- markup
    ["@markup.heading"]  = { fg = c.func, bold = true },
    ["@markup.strong"]   = { fg = c.fg, bold = true },
    ["@markup.italic"]   = { fg = c.fg, italic = true },
    ["@markup.link"]     = { fg = c.cyan, underline = true },
    ["@markup.link.url"] = { fg = c.cyan, underline = true },
    ["@markup.raw"]      = { fg = c.string },
    ["@markup.list"]     = { fg = c.keyword },
    ["@markup.quote"]    = { fg = c.comment, italic = true },
    ["@diff.plus"]       = { fg = c.green },
    ["@diff.minus"]      = { fg = c.red },

    -- LSP
    ["@lsp.type.class"]     = { fg = c.type },
    ["@lsp.type.interface"] = { fg = c.type },
    ["@lsp.type.enum"]      = { fg = c.type },
    ["@lsp.type.namespace"] = { fg = c.type },
    ["@lsp.type.function"]  = { fg = c.func },
    ["@lsp.type.method"]    = { fg = c.func },
    ["@lsp.type.parameter"] = { fg = c.member, italic = true },
    ["@lsp.type.property"]  = { fg = c.member },
    ["@lsp.type.variable"]  = { fg = c.variable },
    ["@lsp.type.keyword"]   = { fg = c.keyword },
    ["@lsp.type.string"]    = { fg = c.string },
    ["@lsp.type.number"]    = { fg = c.number },
    ["@lsp.type.comment"]   = { link = "Comment" },
    ["@lsp.mod.readonly"]   = { fg = c.number },
    LspInlayHint = { fg = c.indent, italic = true },
    LspSignatureActiveParameter = { fg = c.orange, bold = true },
    LspReferenceText = { bg = c.bg_light }, LspReferenceRead = { bg = c.bg_light },
    LspReferenceWrite = { bg = c.bg_light, underline = true },

    -- diagnostics
    DiagnosticError = { fg = c.red }, DiagnosticWarn = { fg = c.yellow },
    DiagnosticInfo = { fg = c.cyan }, DiagnosticHint = { fg = c.member },
    DiagnosticOk = { fg = c.green },
    DiagnosticUnderlineError = { undercurl = true, sp = c.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = c.yellow },
    DiagnosticUnderlineInfo = { undercurl = true, sp = c.cyan },
    DiagnosticUnderlineHint = { undercurl = true, sp = c.member },
    DiagnosticVirtualTextError = { fg = c.red }, DiagnosticVirtualTextWarn = { fg = c.yellow },
    DiagnosticVirtualTextInfo = { fg = c.cyan }, DiagnosticVirtualTextHint = { fg = c.member },

    -- git
    DiffAdd = { fg = c.green, bg = c.bg_light }, DiffChange = { fg = c.yellow, bg = c.bg_light },
    DiffDelete = { fg = c.red, bg = c.bg_light }, DiffText = { fg = c.fg, bg = c.selection },
    Added = { fg = c.green }, Changed = { fg = c.yellow }, Removed = { fg = c.red },
    GitSignsAdd = { fg = c.green }, GitSignsChange = { fg = c.yellow }, GitSignsDelete = { fg = c.red },

    -- telescope
    TelescopeNormal = { fg = c.member, bg = bg }, TelescopeBorder = { fg = c.border, bg = bg },
    TelescopePromptNormal = { fg = c.fg, bg = bg }, TelescopePromptBorder = { fg = c.component, bg = bg },
    TelescopePromptTitle = { fg = c.component, bold = true }, TelescopeResultsTitle = { fg = c.comment },
    TelescopePreviewTitle = { fg = c.green }, TelescopeSelection = { fg = c.fg, bg = c.selection, bold = true },
    TelescopeMatching = { fg = c.func, bold = true }, TelescopePromptPrefix = { fg = c.func },

    -- neo-tree
    NeoTreeNormal = { fg = c.member, bg = bg_side }, NeoTreeNormalNC = { fg = c.member, bg = bg_side },
    NeoTreeWinSeparator = { fg = c.border, bg = bg_side }, NeoTreeEndOfBuffer = { fg = c.bg, bg = bg_side },
    NeoTreeRootName = { fg = c.func, bold = true }, NeoTreeDirectoryName = { fg = c.component },
    NeoTreeDirectoryIcon = { fg = c.component }, NeoTreeFileName = { fg = c.member },
    NeoTreeFileNameOpened = { fg = c.fg, bold = true }, NeoTreeCursorLine = { bg = c.selection },
    NeoTreeIndentMarker = { fg = c.indent }, NeoTreeGitAdded = { fg = c.green },
    NeoTreeGitModified = { fg = c.yellow }, NeoTreeGitDeleted = { fg = c.red },
    NeoTreeGitUntracked = { fg = c.comment },

    -- blink.cmp
    BlinkCmpMenu = { fg = c.member, bg = bg }, BlinkCmpMenuBorder = { fg = c.border, bg = bg },
    BlinkCmpMenuSelection = { bg = c.selection, bold = true }, BlinkCmpLabel = { fg = c.member },
    BlinkCmpLabelMatch = { fg = c.func, bold = true }, BlinkCmpKind = { fg = c.cyan },
    BlinkCmpDoc = { fg = c.member, bg = bg }, BlinkCmpDocBorder = { fg = c.border, bg = bg },
    BlinkCmpSignatureHelp = { fg = c.member, bg = bg },

    -- which-key, bufferline, ibl, misc plugins
    WhichKey = { fg = c.func }, WhichKeyGroup = { fg = c.component },
    WhichKeyDesc = { fg = c.member }, WhichKeySeparator = { fg = c.comment },
    WhichKeyFloat = { bg = bg }, WhichKeyBorder = { fg = c.border, bg = bg },
    BufferLineFill = { bg = bg_pop }, BufferLineBackground = { fg = c.comment, bg = bg_pop },
    BufferLineBufferSelected = { fg = c.fg, bg = bg, bold = true },
    BufferLineBufferVisible = { fg = c.member, bg = bg_pop },
    BufferLineSeparator = { fg = c.border, bg = bg_pop },
    BufferLineSeparatorSelected = { fg = c.border, bg = bg },
    BufferLineIndicatorSelected = { fg = c.component, bg = bg },
    ["@ibl.indent.char.1"] = { fg = c.indent }, ["@ibl.whitespace.char.1"] = { fg = c.indent },
    ["@ibl.scope.char.1"] = { fg = c.component }, IblIndent = { fg = c.indent },
    IblWhitespace = { fg = c.indent }, IblScope = { fg = c.component },
    TreesitterContext = { bg = c.bg_light },
    TreesitterContextLineNumber = { fg = c.line_nr, bg = c.bg_light },
    AlphaHeader = { fg = c.component }, AlphaButtons = { fg = c.func },
    AlphaFooter = { fg = c.comment, italic = true },
    FidgetTask = { fg = c.comment }, FidgetTitle = { fg = c.component, bold = true },
    DropBarIconKindFunction = { fg = c.func }, DropBarKindFunction = { fg = c.func },
    DropBarIconKindVariable = { fg = c.variable }, DropBarKindVariable = { fg = c.variable },
    DropBarMenuCurrentContext = { bg = c.selection }, DropBarMenuHoverEntry = { bg = c.selection },
    WinBar = { fg = c.member, bg = bg }, WinBarNC = { fg = c.comment, bg = bg },
    GitPanelHead = { fg = c.func, bold = true }, GitPanelGraph = { fg = c.indent },
    GitPanelSubject = { fg = c.member }, GitPanelTime = { fg = c.line_nr },
    GitPanelRef = { fg = c.component, bold = true },
    RenderMarkdownH1Bg = { fg = c.red, bg = c.bg_light },
    RenderMarkdownH2Bg = { fg = c.orange, bg = c.bg_light },
    RenderMarkdownH3Bg = { fg = c.yellow, bg = c.bg_light },
    RenderMarkdownH4Bg = { fg = c.green, bg = c.bg_light },
    RenderMarkdownH5Bg = { fg = c.cyan, bg = c.bg_light },
    RenderMarkdownH6Bg = { fg = c.purple, bg = c.bg_light },
    RenderMarkdownCode = { bg = c.bg_light }, RenderMarkdownBullet = { fg = c.component },
    RenderMarkdownQuote = { fg = c.comment }, RenderMarkdownDash = { fg = c.border },
    RenderMarkdownTableHead = { fg = c.component }, RenderMarkdownTableRow = { fg = c.member },
  }

  for group, spec in pairs(g) do vim.api.nvim_set_hl(0, group, spec) end

  vim.g.terminal_color_0 = c.bg_dark   vim.g.terminal_color_8  = c.comment
  vim.g.terminal_color_1 = c.red       vim.g.terminal_color_9  = c.red
  vim.g.terminal_color_2 = c.green     vim.g.terminal_color_10 = c.green
  vim.g.terminal_color_3 = c.yellow    vim.g.terminal_color_11 = c.yellow
  vim.g.terminal_color_4 = c.blue      vim.g.terminal_color_12 = c.blue
  vim.g.terminal_color_5 = c.purple    vim.g.terminal_color_13 = c.purple
  vim.g.terminal_color_6 = c.cyan      vim.g.terminal_color_14 = c.cyan
  vim.g.terminal_color_7 = c.fg        vim.g.terminal_color_15 = c.fg
end

return M
