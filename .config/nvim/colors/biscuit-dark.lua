-- biscuit-dark
--
-- Biscuit Mar Dark (github.com/Biscuit-Theme), matching .config/ghostty/config
-- byte for byte. Unlike the light variant almost nothing needed adjusting:
-- most Biscuit colors already clear 4.5:1 on #1a1515. Only red, purple and cyan
-- were lifted, and those use Biscuit's own *bright* variants rather than
-- invented values.
--
-- Designed to be used with a transparent Normal -- init.lua strips the
-- background after loading.

vim.cmd.highlight("clear")
if vim.fn.exists("syntax_on") == 1 then
    vim.cmd.syntax("reset")
end

vim.o.background = "dark"
vim.g.colors_name = "biscuit-dark"

local c = {
    bg0   = "#1a1515", -- licorice
    bg1   = "#2d2424", -- floats, cursorline
    bg2   = "#312727", -- statusline
    bg3   = "#453636", -- visual
    bg4   = "#553f3f", -- matchparen, splits

    fg0   = "#ffe9c7", -- papaya whip           15.26:1
    fg1   = "#e6d2b3", -- slightly dimmer ink   12.25:1
    fg2   = "#8c8882", -- line numbers, ghost text

    gray0 = "#967a7a", -- comments               4.61:1
    gray1 = "#9c8181", -- subtle text            5.05:1

    red    = "#e3556f", -- 4.99:1  (color9, lifted from #cf2241 @ 3.41)
    green  = "#f07942", -- 6.47:1
    yellow = "#e39c45", -- 7.84:1
    blue   = "#949f6b", -- 6.39:1
    purple = "#9894b3", -- 6.22:1  (color13, lifted from #716c97 @ 3.70)
    aqua   = "#ca6bac", -- 5.34:1  (color14, lifted from #ae3f8a @ 3.34)
    orange = "#f49d75", -- 8.15:1
}

-- terminal palette: stock Biscuit Mar Dark, matching ghostty exactly
local term = {
    "#2d2424", "#cf2241", "#f07942", "#e39c45",
    "#949f6b", "#716c97", "#ae3f8a", "#9c8181",
    "#725a5a", "#e3556f", "#f49d75", "#edbf86",
    "#b0b893", "#9894b3", "#ca6bac", "#ffe9c7",
}

for i, v in ipairs(term) do
    vim.g["terminal_color_" .. (i - 1)] = v
end

local hl = function(group, spec) vim.api.nvim_set_hl(0, group, spec) end

local groups = {
    -- editor ---------------------------------------------------------------
    Normal       = { fg = c.fg0, bg = c.bg0 },
    NormalNC     = { link = "Normal" },
    -- floats stay flat: init.lua strips NormalFloat's bg for transparency, so
    -- the border must not carry one either or it sits on a mismatched patch.
    NormalFloat  = { fg = c.fg0, bg = c.bg0 },
    FloatBorder  = { fg = c.bg4 },
    FloatTitle   = { fg = c.aqua, bold = true },
    ColorColumn  = { bg = c.bg1 },
    Cursor       = { fg = c.bg0, bg = c.fg0 },
    CursorLine   = { bg = c.bg1 },
    CursorColumn = { link = "CursorLine" },
    CursorLineNr = { fg = c.yellow, bold = true },
    LineNr       = { fg = c.fg2 },
    SignColumn   = { fg = c.fg2 },
    FoldColumn   = { fg = c.fg2 },
    Folded       = { fg = c.gray1, bg = c.bg1, italic = true },
    VertSplit    = { fg = c.bg4 },
    WinSeparator = { fg = c.bg4 },
    NonText      = { fg = c.bg4 },
    Whitespace   = { fg = c.bg4 },
    EndOfBuffer  = { fg = c.bg0 },
    Conceal      = { fg = c.fg2 },
    MatchParen   = { bg = c.bg4, bold = true },
    Directory    = { fg = c.blue },
    Title        = { fg = c.aqua, bold = true },
    Question     = { fg = c.green },
    MoreMsg      = { fg = c.green },
    ModeMsg      = { fg = c.fg0, bold = true },
    ErrorMsg     = { fg = c.red, bold = true },
    WarningMsg   = { fg = c.yellow, bold = true },
    SpecialKey   = { fg = c.fg2 },
    Visual       = { bg = c.bg3 },
    VisualNOS    = { link = "Visual" },
    Search       = { fg = c.bg0, bg = c.yellow },
    IncSearch    = { fg = c.bg0, bg = c.orange },
    CurSearch    = { link = "IncSearch" },
    Substitute   = { link = "IncSearch" },
    QuickFixLine = { bg = c.bg1, bold = true },
    WinBar       = { fg = c.fg0, bold = true },
    WinBarNC     = { fg = c.gray1 },

    StatusLine   = { fg = c.fg0, bg = c.bg2 },
    StatusLineNC = { fg = c.gray1, bg = c.bg1 },
    TabLine      = { fg = c.gray1, bg = c.bg1 },
    TabLineFill  = { bg = c.bg1 },
    TabLineSel   = { fg = c.bg0, bg = c.orange, bold = true },

    Pmenu        = { fg = c.fg0, bg = c.bg1 },
    PmenuSel     = { fg = c.bg0, bg = c.aqua, bold = true },
    PmenuSbar    = { bg = c.bg1 },
    PmenuThumb   = { bg = c.bg4 },

    -- syntax ---------------------------------------------------------------
    Comment      = { fg = c.gray0, italic = true },
    Constant     = { fg = c.purple },
    String       = { fg = c.green },
    Character    = { fg = c.green },
    Number       = { fg = c.purple },
    Boolean      = { fg = c.purple, bold = true },
    Float        = { fg = c.purple },
    Identifier   = { fg = c.fg0 },
    Function     = { fg = c.blue, bold = true },
    Statement    = { fg = c.purple },
    Conditional  = { fg = c.purple },
    Repeat       = { fg = c.purple },
    Label        = { fg = c.aqua },
    Operator     = { fg = c.purple },
    Keyword      = { fg = c.purple },
    Exception    = { fg = c.red },
    PreProc      = { fg = c.aqua },
    Include      = { fg = c.aqua },
    Define       = { fg = c.aqua },
    Macro        = { fg = c.aqua },
    PreCondit    = { fg = c.aqua },
    Type         = { fg = c.yellow },
    StorageClass = { fg = c.yellow },
    Structure    = { fg = c.yellow },
    Typedef      = { fg = c.yellow },
    Special      = { fg = c.orange },
    SpecialChar  = { fg = c.orange, bold = true },
    Tag          = { fg = c.red },
    Delimiter    = { fg = c.fg1 },
    SpecialComment = { fg = c.gray0, bold = true },
    Debug        = { fg = c.red },
    Underlined   = { fg = c.blue, underline = true },
    Ignore       = { fg = c.fg2 },
    Error        = { fg = c.red, bold = true },
    Todo         = { fg = c.orange, bold = true },

    -- diff / git -----------------------------------------------------------
    DiffAdd      = { fg = c.blue, bg = c.bg1 },
    DiffChange   = { fg = c.yellow, bg = c.bg1 },
    DiffDelete   = { fg = c.red, bg = c.bg1 },
    DiffText     = { fg = c.orange, bg = c.bg3, bold = true },
    Added        = { fg = c.blue },
    Changed      = { fg = c.yellow },
    Removed      = { fg = c.red },
    diffAdded    = { fg = c.blue },
    diffRemoved  = { fg = c.red },
    diffChanged  = { fg = c.yellow },
    diffFile     = { fg = c.aqua, bold = true },
    diffLine     = { fg = c.gray1 },

    GitSignsAdd    = { fg = c.blue },
    GitSignsChange = { fg = c.yellow },
    GitSignsDelete = { fg = c.red },

    -- diagnostics ----------------------------------------------------------
    DiagnosticError = { fg = c.red },
    DiagnosticWarn  = { fg = c.yellow },
    DiagnosticInfo  = { fg = c.aqua },
    DiagnosticHint  = { fg = c.blue },
    DiagnosticOk    = { fg = c.green },
    DiagnosticUnderlineError = { sp = c.red, undercurl = true },
    DiagnosticUnderlineWarn  = { sp = c.yellow, undercurl = true },
    DiagnosticUnderlineInfo  = { sp = c.aqua, undercurl = true },
    DiagnosticUnderlineHint  = { sp = c.blue, undercurl = true },
    DiagnosticUnderlineOk    = { sp = c.green, undercurl = true },

    -- spelling -------------------------------------------------------------
    SpellBad   = { sp = c.red, undercurl = true },
    SpellCap   = { sp = c.yellow, undercurl = true },
    SpellLocal = { sp = c.aqua, undercurl = true },
    SpellRare  = { sp = c.orange, undercurl = true },

    -- treesitter -----------------------------------------------------------
    ["@comment"]              = { link = "Comment" },
    ["@comment.error"]        = { fg = c.red, bold = true },
    ["@comment.warning"]      = { fg = c.yellow, bold = true },
    ["@comment.todo"]         = { link = "Todo" },
    ["@comment.note"]         = { fg = c.aqua, bold = true },
    ["@constant"]             = { link = "Constant" },
    ["@constant.builtin"]     = { fg = c.purple, bold = true },
    ["@constant.macro"]       = { link = "Macro" },
    ["@string"]               = { link = "String" },
    ["@string.escape"]        = { fg = c.orange, bold = true },
    ["@string.special"]       = { fg = c.orange },
    ["@string.regexp"]        = { fg = c.orange },
    ["@character"]            = { link = "Character" },
    ["@number"]               = { link = "Number" },
    ["@boolean"]              = { link = "Boolean" },
    ["@float"]                = { link = "Float" },
    ["@function"]             = { link = "Function" },
    ["@function.builtin"]     = { fg = c.yellow, bold = true },
    ["@function.macro"]       = { link = "Macro" },
    ["@function.method"]      = { link = "Function" },
    ["@constructor"]          = { fg = c.purple, bold = true },
    ["@parameter"]            = { fg = c.fg1 },
    ["@variable"]             = { fg = c.fg0 },
    ["@variable.builtin"]     = { fg = c.fg1, bold = true },
    ["@variable.parameter"]   = { fg = c.fg1 },
    ["@variable.member"]      = { fg = c.blue },
    ["@property"]             = { fg = c.blue },
    ["@field"]                = { fg = c.blue },
    ["@keyword"]              = { link = "Keyword" },
    ["@keyword.function"]     = { link = "Keyword" },
    ["@keyword.return"]       = { fg = c.purple, bold = true },
    ["@keyword.operator"]     = { link = "Operator" },
    ["@keyword.import"]       = { link = "Include" },
    ["@keyword.directive"]    = { fg = c.blue },
    ["@keyword.exception"]    = { link = "Exception" },
    ["@operator"]             = { link = "Operator" },
    ["@type"]                 = { link = "Type" },
    ["@type.builtin"]         = { fg = c.yellow, italic = true },
    ["@type.definition"]      = { link = "Typedef" },
    ["@attribute"]            = { fg = c.fg1 },
    ["@namespace"]            = { fg = c.fg1 },
    ["@module"]               = { fg = c.aqua },
    ["@label"]                = { link = "Label" },
    ["@punctuation"]          = { link = "Delimiter" },
    ["@punctuation.bracket"]  = { fg = c.fg1 },
    ["@punctuation.delimiter"] = { fg = c.fg1 },
    ["@punctuation.special"]  = { fg = c.orange },
    ["@tag"]                  = { link = "Tag" },
    ["@tag.attribute"]        = { fg = c.blue },
    ["@tag.delimiter"]        = { fg = c.fg1 },
    ["@markup.heading"]       = { fg = c.aqua, bold = true },
    ["@markup.strong"]        = { bold = true },
    ["@markup.italic"]        = { italic = true },
    ["@markup.strikethrough"] = { strikethrough = true },
    ["@markup.underline"]     = { underline = true },
    ["@markup.link"]          = { fg = c.red },
    ["@markup.link.url"]      = { fg = c.green, underline = true },
    ["@markup.raw"]           = { fg = c.red },
    ["@markup.list"]          = { fg = c.orange },
    ["@markup.quote"]         = { fg = c.gray1, italic = true },
    ["@diff.plus"]            = { fg = c.blue },
    ["@diff.minus"]           = { fg = c.red },
    ["@diff.delta"]           = { fg = c.yellow },

    -- lsp semantic tokens --------------------------------------------------
    ["@lsp.type.class"]         = { link = "Type" },
    ["@lsp.type.decorator"]     = { link = "Macro" },
    ["@lsp.type.enum"]          = { link = "Type" },
    ["@lsp.type.enumMember"]    = { link = "Constant" },
    ["@lsp.type.function"]      = { link = "Function" },
    ["@lsp.type.interface"]     = { link = "Type" },
    ["@lsp.type.macro"]         = { link = "Macro" },
    ["@lsp.type.method"]        = { link = "Function" },
    ["@lsp.type.namespace"]     = { link = "@namespace" },
    ["@lsp.type.operator"]      = { link = "Operator" },
    ["@lsp.type.parameter"]     = { link = "@parameter" },
    ["@lsp.type.property"]      = { link = "@property" },
    ["@lsp.type.struct"]        = { link = "Structure" },
    ["@lsp.type.type"]          = { link = "Type" },
    ["@lsp.type.typeParameter"] = { link = "Typedef" },
    ["@lsp.type.variable"]      = { link = "@variable" },
    ["@lsp.typemod.function.defaultLibrary"] = { link = "@function.builtin" },
    ["@lsp.typemod.variable.defaultLibrary"] = { link = "@variable.builtin" },
    ["@lsp.typemod.variable.readonly"]       = { link = "Constant" },

    -- telescope ------------------------------------------------------------
    TelescopeBorder        = { fg = c.bg4 },
    TelescopeTitle         = { fg = c.orange, bold = true },
    TelescopePromptPrefix  = { fg = c.red },
    TelescopeSelection     = { bg = c.bg1, bold = true },
    TelescopeMatching      = { fg = c.orange, bold = true },

    -- misc plugins ---------------------------------------------------------
    CopilotSuggestion = { fg = c.fg2, italic = true },
    LspInlayHint      = { fg = c.fg2, italic = true },
    LspReferenceText  = { bg = c.bg1 },
    LspReferenceRead  = { bg = c.bg1 },
    LspReferenceWrite = { bg = c.bg1, bold = true },
    SnippetTabstop    = { bg = c.bg1 },
}

for group, spec in pairs(groups) do
    hl(group, spec)
end
