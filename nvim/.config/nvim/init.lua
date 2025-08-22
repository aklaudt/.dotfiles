require("aklaudt.core.options")
require("aklaudt.core.keymaps")
vim.loader.enable()
-- Function to open the corresponding header/source file with support for .c and .hpp files
function open_corresponding_file()
    local current_file = vim.api.nvim_buf_get_name(0)
    local file_extension = vim.fn.expand('%:e')
    local base_name = vim.fn.expand('%:t:r')
    local dir_name = vim.fn.expand('%:p:h') -- Get the directory path

    local function file_exists(name)
        local f = io.open(name, "r")
        if f ~= nil then io.close(f) return true else return false end
    end

    -- Define possible extensions for headers and sources
    local header_extensions = { 'h', 'hpp' }
    local source_extensions = { 'c', 'cpp' }

    -- Helper function to check if an item exists in a table
    local function contains(table, val)
        for _, v in ipairs(table) do
            if v == val then
                return true
            end
        end
        return false
    end

    if contains(header_extensions, file_extension) then
        -- Current file is a header file, search for corresponding source files
        for _, ext in ipairs(source_extensions) do
            local source_file = dir_name .. '/' .. base_name .. '.' .. ext
            if file_exists(source_file) then
                vim.cmd("edit " .. source_file)
                return
            end
        end
        print("Corresponding source file does not exist")
    elseif contains(source_extensions, file_extension) then
        -- Current file is a source file, search for corresponding header files
        for _, ext in ipairs(header_extensions) do
            local header_file = dir_name .. '/' .. base_name .. '.' .. ext
            if file_exists(header_file) then
                vim.cmd("edit " .. header_file)
                return
            end
        end
        print("Corresponding header file does not exist")
    else
        print("Not a recognized source or header file")
    end
end

--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- NOTE: Here is where you install your plugins.
--  You can configure plugins using the `config` key.
--
--  You can also configure plugins after the setup call,
--    as they will be available in your neovim runtime.
require('lazy').setup("plugins", {})

-- [[ Highlight on yank ]]
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- Enable ALE globally
vim.g.ale_enabled = 1

-- Enable ALE for JavaScript and TypeScript
-- vim.g.ale_linters = {
--   javascript = { 'eslint' },
--  typescript = { 'eslint' },
-- }
--
-- vim.g.ale_fixers = {
--    cpp = {'clang-format'},
-- }

vim.api.nvim_create_user_command("FormatCurrentBufferWithClang", function()
  local filepath = vim.fn.expand("%:p")
  local git_root = vim.fn.systemlist("git rev-parse --show-toplevel")[1]

  if vim.v.shell_error ~= 0 or git_root == nil or git_root == "" then
    print("Not inside a Git repo.")
    return
  end

  local config_file = git_root .. "/EmbeddedTeam.clang-format"
  local format_options = ""

  if vim.fn.filereadable(config_file) == 0 then
    config_file = vim.fn.systemlist("find " .. git_root .. " -name EmbeddedTeam.clang-format")[1] or ""
    if config_file == nil or config_file == "" then
      config_file = git_root .. "/.clang-format"
      format_options = "-style=file"
    else
      format_options = "-style=file:" .. config_file
    end
  else
    format_options = "-style=file:" .. config_file
  end

  local cmd = "clang-format -i " .. format_options .. " " .. filepath
  print("Running: " .. cmd)
  os.execute(cmd)

  -- Reload buffer
  vim.cmd("edit!")
end, {
  desc = "Format current buffer using EmbeddedTeam.clang-format logic",
})

vim.keymap.set("n", "<leader>cf", ":FormatCurrentBufferWithClang<CR>", { desc = "Clang Format Current File" })

-- Automatically fix linting issues on save
vim.g.ale_fix_on_save = 1

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  -- nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- mason-lspconfig requires that these setup functions are called in this order
-- before setting up the servers.
require("mason").setup()
require("neodev").setup()

local capabilities = capabilities
local on_attach = on_attach

local servers = {
  clangd = {},
  ts_ls = {
    filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
    settings = {
      javascript = { format = { enable = false } },
      typescript = { format = { enable = false } },
    },
  },
  lua_ls = {
    -- wrap Lua settings under `settings`
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
}

local mason_lspconfig = require("mason-lspconfig")
local lspconfig = require("lspconfig")

mason_lspconfig.setup({
  ensure_installed = vim.tbl_keys(servers),
  automatic_enable = false,  -- <- avoid `vim.lsp.enable()` for now
  handlers = {
    function(server_name)
      local cfg = vim.deepcopy(servers[server_name] or {})
      cfg.capabilities = vim.tbl_deep_extend("force", {}, capabilities, cfg.capabilities or {})
      cfg.on_attach = cfg.on_attach or on_attach
      lspconfig[server_name].setup(cfg)
    end,
  },
})
