local uv = vim.uv or vim.loop

local function exists(path)
  return uv.fs_stat(path) ~= nil
end

--- Find the nearest ancestor with node_modules/typescript and classify it.
---
--- TypeScript 7 is the Go port: it ships no `lib/tsserver.js`, only `lib/tsc.js`
--- plus a native binary that speaks LSP directly (`tsc --lsp --stdio`).
--- typescript-tools.nvim requires tsserver.js and asserts without it, so the two
--- eras need different clients.
---
---@param start string file or directory path to search upward from
---@return string|nil root, string|nil kind  -- kind is "native" (TS7+) or "legacy" (TS<=6)
local function detect_typescript(start)
  if start == nil or start == "" then
    start = vim.fn.getcwd()
  end
  if vim.fn.isdirectory(start) == 1 then
    start = start .. "/."
  end

  for dir in vim.fs.parents(start) do
    local ts = dir .. "/node_modules/typescript"
    if exists(ts) then
      if exists(ts .. "/lib/tsserver.js") then
        return dir, "legacy"
      elseif exists(dir .. "/node_modules/.bin/tsc") then
        return dir, "native"
      end
      return dir, nil
    end
  end

  return nil, nil
end

local ts_filetypes = {
  "typescript",
  "typescriptreact",
  "typescript.tsx",
  "javascript",
  "javascriptreact",
}

-- Attach TypeScript 7's built-in native LSP server per-buffer. vim.lsp.start
-- dedupes on name + root_dir, so reopening files in the same project reuses the
-- running server.
vim.api.nvim_create_autocmd("FileType", {
  pattern = ts_filetypes,
  group = vim.api.nvim_create_augroup("tsgo_lsp", { clear = true }),
  callback = function(args)
    local root, kind = detect_typescript(vim.api.nvim_buf_get_name(args.buf))
    if kind ~= "native" then
      return
    end

    vim.lsp.start({
      name = "typescript-go",
      cmd = { root .. "/node_modules/.bin/tsc", "--lsp", "--stdio" },
      root_dir = root,
    }, { bufnr = args.buf })
  end,
})

return {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
    config = function()
      require("lspconfig").lua_ls.setup({})
    end,
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    ft = ts_filetypes,
    -- Only for projects still on TypeScript <= 6. Evaluated once against the cwd
    -- at startup; TS7 projects are served by the native LSP above instead.
    cond = function()
      local _, kind = detect_typescript(vim.fn.getcwd())
      return kind == "legacy"
    end,
    opts = {},
  },
}
