-- Omarchy Tokyo Night; upstream plugin specification with an offline palette fallback.
local spec = {
  {
    "folke/tokyonight.nvim",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight-night",
    },
  },
}

-- Keep the upstream editor theme when available; use its exact palette offline.
local function palette_fallback()
  local p = {
    accent = "#7aa2f7",
    selection = "#292e42",
    muted = "#414868",
    background = "#1a1b26",
    dark_background = "#13141c",
    darker_background = "#0e0e14",
    lighter_background = "#24283b",
    foreground = "#a9b1d6",
    dark_foreground = "#565f89",
    light_foreground = "#b4bee6",
    bright_foreground = "#c0caf5",
    red = "#f7768e",
    yellow = "#e0af68",
    orange = "#eb927b",
    green = "#9ece6a",
    cyan = "#449dab",
    blue = "#7aa2f7",
    magenta = "#ad8ee6",
    brown = "#75493d",
    bright_red = "#ff7a93",
    bright_yellow = "#ff9e64",
    bright_green = "#b9f27c",
    bright_cyan = "#0db9d7",
    bright_blue = "#7da6ff",
    bright_magenta = "#bb9af7",
    selection_background = "#292e42",
    selection_foreground = "#c0caf5",
  }
  vim.cmd("highlight clear")
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.g.colors_name = "omarchy-tokyo-night"
  local groups = {
    Normal = { fg = p.foreground, bg = p.background },
    NormalNC = { fg = p.foreground, bg = p.background },
    NormalFloat = { fg = p.foreground, bg = p.dark_background },
    FloatBorder = { fg = p.accent, bg = p.dark_background },
    FloatTitle = { fg = p.accent, bold = true },
    ColorColumn = { bg = p.lighter_background },
    Cursor = { fg = p.background, bg = p.bright_foreground },
    CursorLine = { bg = p.lighter_background },
    CursorLineNr = { fg = p.accent, bold = true },
    LineNr = { fg = p.muted },
    SignColumn = { fg = p.muted, bg = p.background },
    FoldColumn = { fg = p.muted, bg = p.background },
    Folded = { fg = p.muted, bg = p.lighter_background },
    EndOfBuffer = { fg = p.background },
    NonText = { fg = p.muted },
    Whitespace = { fg = p.muted },
    MatchParen = { fg = p.accent, bold = true },
    Visual = { fg = p.selection_foreground, bg = p.selection_background },
    Search = { fg = p.background, bg = p.yellow },
    IncSearch = { fg = p.background, bg = p.orange },
    CurSearch = { fg = p.background, bg = p.orange },
    Pmenu = { fg = p.foreground, bg = p.dark_background },
    PmenuSel = { fg = p.background, bg = p.accent, bold = true },
    PmenuSbar = { bg = p.lighter_background },
    PmenuThumb = { bg = p.muted },
    StatusLine = { fg = p.foreground, bg = p.lighter_background },
    StatusLineNC = { fg = p.muted, bg = p.dark_background },
    WinSeparator = { fg = p.selection },
    TabLine = { fg = p.muted, bg = p.dark_background },
    TabLineSel = { fg = p.background, bg = p.accent, bold = true },
    TabLineFill = { bg = p.dark_background },
    Title = { fg = p.accent, bold = true },
    Directory = { fg = p.blue },
    Comment = { fg = p.muted, italic = true },
    Constant = { fg = p.orange },
    String = { fg = p.green },
    Character = { fg = p.green },
    Number = { fg = p.orange },
    Boolean = { fg = p.orange },
    Identifier = { fg = p.foreground },
    Function = { fg = p.blue },
    Statement = { fg = p.magenta },
    Conditional = { fg = p.magenta },
    Repeat = { fg = p.magenta },
    Label = { fg = p.cyan },
    Operator = { fg = p.cyan },
    Keyword = { fg = p.magenta },
    Exception = { fg = p.magenta },
    PreProc = { fg = p.cyan },
    Type = { fg = p.yellow },
    Special = { fg = p.cyan },
    Delimiter = { fg = p.foreground },
    Error = { fg = p.red },
    ErrorMsg = { fg = p.red },
    WarningMsg = { fg = p.yellow },
    Todo = { fg = p.background, bg = p.yellow, bold = true },
    Added = { fg = p.green },
    Changed = { fg = p.blue },
    Removed = { fg = p.red },
    DiffAdd = { fg = p.green, bg = p.lighter_background },
    DiffChange = { fg = p.blue, bg = p.lighter_background },
    DiffDelete = { fg = p.red, bg = p.lighter_background },
    DiffText = { fg = p.accent, bg = p.selection, bold = true },
    DiagnosticError = { fg = p.red },
    DiagnosticWarn = { fg = p.yellow },
    DiagnosticInfo = { fg = p.blue },
    DiagnosticHint = { fg = p.cyan },
    DiagnosticOk = { fg = p.green },
    DiagnosticUnderlineError = { sp = p.red, undercurl = true },
    DiagnosticUnderlineWarn = { sp = p.yellow, undercurl = true },
    DiagnosticUnderlineInfo = { sp = p.blue, undercurl = true },
    DiagnosticUnderlineHint = { sp = p.cyan, undercurl = true },
    ["@variable"] = { fg = p.foreground },
    ["@variable.builtin"] = { fg = p.red },
    ["@variable.parameter"] = { fg = p.orange },
    ["@property"] = { fg = p.cyan },
    ["@punctuation.bracket"] = { fg = p.foreground },
    ["@markup.heading"] = { fg = p.accent, bold = true },
    ["@markup.link"] = { fg = p.blue, underline = true },
    ["@markup.raw"] = { fg = p.green },
    ["@markup.strong"] = { bold = true },
    ["@markup.italic"] = { italic = true },
  }
  for name, style in pairs(groups) do
    vim.api.nvim_set_hl(0, name, style)
  end
  local terminal = {
    p.background,
    p.red,
    p.green,
    p.yellow,
    p.blue,
    p.magenta,
    p.cyan,
    p.foreground,
    p.muted,
    p.bright_red,
    p.bright_green,
    p.bright_yellow,
    p.bright_blue,
    p.bright_magenta,
    p.bright_cyan,
    p.bright_foreground,
  }
  for index, color in ipairs(terminal) do
    vim.g["terminal_color_" .. (index - 1)] = color
  end
end

for _, plugin in ipairs(spec) do
  if plugin[1] == "LazyVim/LazyVim" then
    local preferred = plugin.opts.colorscheme
    plugin.opts.colorscheme = function()
      vim.o.background = "dark"
      if not pcall(vim.cmd.colorscheme, preferred) then
        palette_fallback()
      end
    end
  else
    plugin.lazy = false
  end
end
return spec
