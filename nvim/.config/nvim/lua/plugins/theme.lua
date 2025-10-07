  -- return {
  --   -- Theme inspired by Atom
  --   'navarasu/onedark.nvim',
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme 'onedark'
  --   end,
  -- }

  -- return {
  --   'rebelot/kanagawa.nvim',
  --     config = function()
  --     vim.cmd.colorscheme 'kanagawa-lotus'
  --   end,
  -- }
  --
  return {
  'sainnhe/everforest',
  lazy = false,
  priority = 1000,
  config = function()
    -- Optionally configure and load the colorscheme
    -- directly inside the plugin declaration.
    vim.g.everforest_enable_italic = true
    vim.cmd.colorscheme('everforest')
  end
}
 -- lua/plugins/rose-pine.lua
-- return {
--   "folke/tokyonight.nvim",
--   lazy = false,
--   priority = 1000,
--   opts = {},
-- }
-- return { 
-- 	"rose-pine/neovim", 
-- 	name = "rose-pine",
-- 	config = function()
-- 		vim.cmd("colorscheme rose-pine-moon")
-- 	end
-- }
