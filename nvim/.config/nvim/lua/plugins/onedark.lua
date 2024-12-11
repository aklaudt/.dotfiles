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

 -- lua/plugins/rose-pine.lua
return { 
	"rose-pine/neovim", 
	name = "rose-pine",
	config = function()
		vim.cmd("colorscheme rose-pine-moon")
	end
}
