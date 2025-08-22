-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Open the corresponding header/source file
vim.keymap.set('n', '<leader>hf', ':lua open_corresponding_file()<CR>', { noremap = true, silent = true, desc = 'Open [H]eader/[F]ile' })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Set "jj" as  an additional escape sequence from insert mode
-- vim.keymap.set('i', 'jk', '<Esc>', { noremap = true })
-- vim.keymap.set('i', 'kj', '<Esc>', { noremap = true })

-- Set "ww" as  write all
vim.keymap.set('n', 'wa', ':wa<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<C-p>", "<cmd>silent !~/.config/bin/tmux-sessionizer.sh<CR>")

vim.keymap.set('n', '<CR>', 'o<ESC>', { noremap = true})
vim.keymap.set("n", '<leader>ex', vim.cmd.Ex)

-- Move selected line / block of text in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Paste text without emptying yank buffer
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Reload Config
vim.keymap.set('n', "<space><space>x", ":luafile ~/.config/nvim/init.lua<CR>")
vim.keymap.set('v', "<space>x", ":lua<CR>")


