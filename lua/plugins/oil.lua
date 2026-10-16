return {
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    -- vim-vinegar style: `-` opens the parent directory. Oil maps `-` inside its
    -- own buffers to `actions.parent`, and that buffer-local map wins there, so
    -- this only claims the key in normal file buffers.
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory (Oil)" },
    },
    -- Optional dependencies
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
}
