return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        elixir = { "mix" },
        eelixir = { "mix" },
        heex = { "mix" },
      },
    },
  },

  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        providers = {
          lsp = {
            transform_items = function(ctx, items)
              if vim.bo.filetype ~= "elixir" then return items end
              for _, item in ipairs(items) do
                if item.label:sub(1, 1) == "@" then
                  if item.textEdit and item.textEdit.newText:sub(1, 1) ~= "@" then
                    item.textEdit.newText = "@" .. item.textEdit.newText
                  end
                  if item.insertText and item.insertText:sub(1, 1) ~= "@" then
                    item.insertText = "@" .. item.insertText
                  end
                end
              end
              return items
            end,
          },
        },
      },
    },
  },
}
