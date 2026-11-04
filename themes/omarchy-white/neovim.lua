-- Omarchy White; upstream plugin specification with an offline palette fallback.
local spec = {
  {
    "bjarneo/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#ffffff",
        dark_bg = "#f5f5f5",
        darker_bg = "#e8e8e8",
        lighter_bg = "#c0c0c0",

        fg = "#000000",
        dark_fg = "#c0c0c0",
        light_fg = "#000000",
        bright_fg = "#000000",
        muted = "#808080",

        red = "#2a2a2a",
        yellow = "#4a4a4a",
        orange = "#4a4a4a",
        green = "#3a3a3a",
        cyan = "#3e3e3e",
        blue = "#1a1a1a",
        magenta = "#2e2e2e",
        brown = "#2a2a2a",

        bright_red = "#2a2a2a",
        bright_yellow = "#4a4a4a",
        bright_green = "#3a3a3a",
        bright_cyan = "#3e3e3e",
        bright_blue = "#1a1a1a",
        bright_magenta = "#2e2e2e",

        accent = "#6e6e6e",
        cursor = "#000000",
        foreground = "#000000",
        background = "#ffffff",
        selection = "#c0c0c0",
        selection_foreground = "#000000",
        selection_background = "#c0c0c0",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}

-- Keep the upstream editor theme when available; use its exact palette offline.
local function palette_fallback()
  local p = {
    accent = "#6e6e6e",
    selection = "#c0c0c0",
    muted = "#808080",
    background = "#ffffff",
    dark_background = "#f5f5f5",
    darker_background = "#e8e8e8",
    lighter_background = "#c0c0c0",
    foreground = "#000000",
    dark_foreground = "#c0c0c0",
    light_foreground = "#000000",
    bright_foreground = "#000000",
    red = "#2a2a2a",
    yellow = "#4a4a4a",
    green = "#3a3a3a",
    cyan = "#3e3e3e",
    blue = "#1a1a1a",
    magenta = "#2e2e2e",
    bright_red = "#2a2a2a",
    bright_yellow = "#4a4a4a",
    bright_green = "#3a3a3a",
    bright_cyan = "#3e3e3e",
    bright_blue = "#1a1a1a",
    bright_magenta = "#2e2e2e",
    orange = "#4a4a4a",
    brown = "#2a2a2a",
    selection_background = "#c0c0c0",
    selection_foreground = "#000000",
  }
  vim.cmd("highlight clear")
  vim.o.termguicolors = true
  vim.o.background = "light"
  vim.g.colors_name = "omarchy-white"
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
      vim.o.background = "light"
      if not pcall(vim.cmd.colorscheme, preferred) then
        palette_fallback()
      end
    end
  else
    plugin.lazy = false
  end
end
return spec
