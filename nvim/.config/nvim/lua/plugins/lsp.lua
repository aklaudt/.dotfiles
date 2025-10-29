-- LSP: mason + mason-lspconfig + lspconfig + neodev + clangd config
return {
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "folke/neodev.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("neodev").setup({})

      -- capabilities from cmp so completion actually works
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- shared on_attach for keymaps
      local on_attach = function(_, bufnr)
        local nmap = function(lhs, rhs, desc)
          vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc and ("LSP: " .. desc) or nil })
        end
        nmap("gd", require("telescope.builtin").lsp_definitions, "Goto Definition")
        nmap("gr", require("telescope.builtin").lsp_references, "Goto References")
        nmap("gI", require("telescope.builtin").lsp_implementations, "Goto Implementation")
        nmap("<leader>rn", vim.lsp.buf.rename, "Rename")
        nmap("<leader>ca", vim.lsp.buf.code_action, "Code Action")
        nmap("K", vim.lsp.buf.hover, "Hover")

        -- clangd header/source switch (better than custom file swap)
        nmap("gs", function()
          vim.lsp.buf.execute_command({ command = "clangd.switchSourceHeader" })
        end, "Clangd: Switch Header/Source")

        -- :Format buffer
        vim.api.nvim_buf_create_user_command(bufnr, "Format", function() vim.lsp.buf.format() end,
          { desc = "Format current buffer with LSP" })
      end

      local lspconfig = require("lspconfig")

      -- Servers
      local servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--completion-style=detailed",
            "--header-insertion=iwyu",
            "--cross-file-rename",
            "--function-arg-placeholders",
            "--log=error",
            "--pch-storage=memory",
            -- adjust if your compile_commands.json lives in build/
            "--compile-commands-dir=build",
            -- widen for your toolchains (tweak paths if needed)
            "--query-driver=/usr/bin/clang-*,/usr/bin/clang++,/usr/bin/g++*,/usr/bin/cc*,/usr/bin/arm-none-eabi-*",
          },
          capabilities = capabilities,
          on_attach = on_attach,
        },
        lua_ls = {
          settings = { Lua = { workspace = { checkThirdParty = false }, telemetry = { enable = false } } },
          capabilities = capabilities,
          on_attach = on_attach,
        },
        ts_ls = {
          filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
          settings = {
            javascript = { format = { enable = false } },
            typescript = { format = { enable = false } },
          },
          capabilities = capabilities,
          on_attach = on_attach,
        },
      }

      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "lua_ls", "ts_ls" },
        handlers = {
          function(server)
            lspconfig[server].setup(servers[server] or {
              capabilities = capabilities, on_attach = on_attach
            })
          end,
        },
      })
    end,
  },
}

