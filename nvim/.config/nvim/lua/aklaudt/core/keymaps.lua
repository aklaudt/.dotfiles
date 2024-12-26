-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- vim.api.nvim_set_keymap('n', ';', ':', { noremap = true })
vim.api.nvim_set_keymap('n', '<CR>', 'o<ESC>', { noremap = true})

-- Create a key mapping for opening the corresponding header/source file
vim.keymap.set('n', '<leader>hf', ':lua open_corresponding_file()<CR>', { noremap = true, silent = true, desc = 'Open [H]eader/[F]ile' })

-- [[ Basic Keymaps ]]
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Set "jj" as  an additional escape sequence from insert mode
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true })
vim.api.nvim_set_keymap('i', 'kj', '<Esc>', { noremap = true })

vim.keymap.set("n", "<C-p>", "<cmd>silent !tmux neww ~/.config/bin/tmux-sessionizer<CR>")

-- Open explorer
vim.keymap.set("n", '<leader>ex', vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Paste text without emptying yank buffer
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Diagnostic keymaps
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
-- vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Reload Config
vim.keymap.set('n', "<space><space>x", ":luafile ~/.config/nvim/init.lua<CR>")
vim.keymap.set('v', "<space>x", ":lua<CR>")

-- Copilot
vim.keymap.set('i', '<S-Tab>', 'copilot#Accept("\\<CR>")', {
  expr = true,
  replace_keycodes = false
})
vim.g.copilot_no_tab_map = true

