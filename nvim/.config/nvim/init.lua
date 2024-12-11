require("aklaudt.core.options")
require("aklaudt.core.keymaps")
require("aklaudt.core.colorscheme")

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
-- See `:help vim.highlight.on_yank()`
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
require('mason').setup()
require('mason-lspconfig').setup()

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
--
--  If you want to override the default filetypes that your language server will attach to you can
--  define the property 'filetypes' to the map in question.
local servers = {
  clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},
  -- html = { filetypes = { 'html', 'twig', 'hbs'} },

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Disable the "readability-identifier-naming" warning in clangd
require'lspconfig'.clangd.setup{
  cmd = { "clangd", 
          "--clang-tidy", 
          "--clang-tidy-checks=-readability-identifier-naming,*",  -- Disable only the readability-identifier-naming check
          "--header-insertion=never" 
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
      filetypes = (servers[server_name] or {}).filetypes,
    }
  end,
}

-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require 'cmp'
local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup {}

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}


vim.api.nvim_create_user_command("WatchTest", function()
  local overseer = require("overseer")
  overseer.run_template({ name = "npm test" }, function(task)
    if task then
      task:add_component({ "restart_on_save", paths = {vim.fn.expand("%:p")} })
      local main_win = vim.api.nvim_get_current_win()
      vim.cmd("set splitright")
      overseer.run_action(task, "open vsplit")
      vim.api.nvim_win_set_width(0, 80)
      vim.api.nvim_set_current_win(main_win)
    else
      vim.notify("WatchTest not supported for filetype " .. vim.bo.filetype, vim.log.levels.ERROR)
    end
  end)
end, {})

vim.api.nvim_create_user_command("WatchTestLinux", function()
  local overseer = require("overseer")
  overseer.run_template({ name = "bash test" }, function(task)
    if task then
      task:add_component({ "restart_on_save", paths = {vim.fn.expand("%:p")} })
      local main_win = vim.api.nvim_get_current_win()
      vim.cmd("set splitright")
      overseer.run_action(task, "open vsplit")
      vim.api.nvim_win_set_width(0, 80)
      vim.api.nvim_set_current_win(main_win)
    else
      vim.notify("WatchTestLinux not supported for filetype " .. vim.bo.filetype, vim.log.levels.ERROR)
    end
  end)
end, {})


vim.api.nvim_create_user_command("WatchBuild", function()
  local overseer = require("overseer")
  overseer.run_template({ name = "cmake build" }, function(task)
    if task then
      task:add_component({ "restart_on_save", paths = {vim.fn.expand("%:p")} })
      local main_win = vim.api.nvim_get_current_win()
      vim.cmd("set splitright")
      overseer.run_action(task, "open vsplit")
      vim.api.nvim_win_set_width(0, 80)
      vim.api.nvim_set_current_win(main_win)
    else
      vim.notify("Unable to build file type " .. vim.bo.filetype, vim.log.levels.ERROR)
    end
  end)
end, {})
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et

