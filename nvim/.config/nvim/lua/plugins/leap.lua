return {
    'ggandor/leap.nvim',
    config = function()
        require("leap").add_default_mappings()
    end,
    opts = {
        dependencies = {
            "tpope/vim-repeate",
        },
        lazy = false,
    }
}
