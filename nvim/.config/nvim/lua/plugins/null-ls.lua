return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- optional: auto-install external tools
    { "jay-babu/mason-null-ls.nvim", opts = {
        ensure_installed = { "clang-format", "prettier" },
        automatic_installation = true,
      }
    },
  },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.clang_format.with({
          filetypes = { "c", "cpp", "objc", "objcpp" },
        }),
        -- Prettier for JSON with custom args
        null_ls.builtins.formatting.prettier.with({
          filetypes = { "json" },
          extra_args = {
            "--use-tabs=false",
            "--tab-width=4",
            "--bracket-spacing=true",
            "--print-width=100",
            "--prose-wrap=preserve",
          },
        }),
        -- Prettier defaults for other types
        null_ls.builtins.formatting.prettier.with({
          filetypes = {
            "javascript", "typescript", "typescriptreact",
            "yaml", "html", "css", "markdown",
          },
        }),
      },
      on_attach = function(client, bufnr)
        if client.supports_method("textDocument/formatting") then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({
                bufnr = bufnr,
                filter = function(c)
                  -- none-ls keeps the client name "null-ls" for compatibility;
                  -- some builds may report "none-ls" — allow either.
                  return c.name == "null-ls" or c.name == "none-ls"
                end,
              })
            end,
          })
        end
      end,
    })
  end,
}
