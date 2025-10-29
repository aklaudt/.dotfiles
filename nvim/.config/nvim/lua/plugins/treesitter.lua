return {
  'nvim-treesitter/nvim-treesitter',
  dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
  build = ':TSUpdate',
  event = 'VeryLazy',
  config = function()
    vim.defer_fn(function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'c', 'cpp', 'cmake', 'json', -- <- added cmake + json
          'go', 'lua', 'python', 'rust',
          'tsx', 'javascript', 'typescript',
          'vimdoc', 'vim', 'bash'
        },
        auto_install = false,

        highlight = { enable = true },

        -- keep indent on, but not for C/C++
        indent = {
          enable = true,
          disable = { 'c', 'cpp' }, -- <- avoids busted indent
        },

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<c-space>',
            node_incremental = '<c-space>',
            scope_incremental = '<c-s>',
            node_decremental = '<M-space>',
          },
        },

        textobjects = {
          select = {
            enable = true, lookahead = true,
            keymaps = {
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
            },
          },
          move = {
            enable = true, set_jumps = true,
            goto_next_start  = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
            goto_next_end    = { [']M'] = '@function.outer', [']['] = '@class.outer' },
            goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
            goto_previous_end   = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
          },
          swap = {
            enable = true,
            swap_next     = { ['<leader>a'] = '@parameter.inner' },
            swap_previous = { ['<leader>A'] = '@parameter.inner' },
          },
        },
      }
    end, 0)
  end,
}

