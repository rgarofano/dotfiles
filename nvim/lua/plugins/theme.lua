return {
    "bluz71/vim-nightfly-colors",
    name = "nightfly",
    lazy = false,
    priority = 1000,
    config = function()
        vim.g.nightflyTransparent = false -- Set this to true for transparent background
        vim.cmd([[colorscheme nightfly]])
    end,
}
