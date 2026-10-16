-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

require("oil").setup({})

require("catppuccin").setup({
  flavour = "macchiato", -- latte, frappe, macchiato, mocha
  backgorund = {
    light = "latte",
    dark = "macchiato",
  },
  transparent_background = false,
})
--[[
require("moonlight").set({
  moonlight_disable_background = true,
})
--]]
vim.cmd([[colorscheme catppuccin]])
