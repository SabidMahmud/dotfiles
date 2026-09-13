return {
  colorscheme = "tokyonight",
  setup = function()
    -- We alias coolnight to tokyonight with night style
    -- because coolnight is fundamentally a tweak of it.
    vim.g.tokyonight_style = "night"
    vim.g.tokyonight_transparent = true
  end,
}
