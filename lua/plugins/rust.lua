-- `<leader>p` mirrors vim-prettier's default mapping, which it sets globally but
-- only when nothing else has claimed the key (plugin/prettier.vim:165). A global
-- override here would silently suppress it in TypeScript buffers, so this is
-- buffer-local to Rust: the local map wins in .rs files, prettier keeps the rest.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  group = vim.api.nvim_create_augroup("rust_format_keymap", { clear = true }),
  callback = function(args)
    vim.keymap.set("n", "<leader>p", function()
      require("conform").format({ bufnr = args.buf, async = true, lsp_format = "fallback" })
    end, { buffer = args.buf, desc = "Format with rustfmt" })
  end,
})

-- Supplements `lazyvim.plugins.extras.lang.rust`, which owns rust-analyzer
-- (via rustaceanvim), crates.nvim, codelldb, and the rust/ron parsers.
-- Only the gaps it leaves live here.
return {
  {
    "mrcjkb/rustaceanvim",
    -- rustaceanvim v9 dropped Neovim 0.11 ("feat!: drop Neovim 0.11 support");
    -- its ftplugin/rust.lua bails early on <0.12, which silently leaves Rust
    -- buffers with no LSP at all. LazyVim's extra tracks master, so pin to the
    -- last 0.11-compatible line until this Neovim is upgraded past 0.12.
    version = vim.fn.has("nvim-0.12") == 1 and false or "^8",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            -- The extra enables checkOnSave but leaves the command at the
            -- default `cargo check`. Clippy is a superset, and it's installed.
            check = { command = "clippy" },
          },
        },
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "toml" } },
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt" },
      },
    },
  },
}
