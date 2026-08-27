require("settings")

vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",         -- dependency
    "https://github.com/nvim-tree/nvim-web-devicons",   -- dependency
    "https://github.com/nvim-telescope/telescope.nvim", -- fancy grep
    "https://github.com/windwp/nvim-autopairs",         -- autopairs
    "https://github.com/lewis6991/gitsigns.nvim",       -- git integration
    "https://github.com/neovim/nvim-lspconfig",         -- lsp
    "https://github.com/saghen/blink.lib",              -- dependency
    "https://github.com/saghen/blink.cmp",              -- completions
    "https://github.com/edeneast/nightfox.nvim",        -- theme
    "https://github.com/catppuccin/nvim",               -- theme
})

-- fancy grep
require("telescope").setup({})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<C-f>", builtin.live_grep, {})
vim.keymap.set("n", "gs", builtin.grep_string, {})
vim.keymap.set("n", "<leader>fc", function()
    builtin.find_files({
        cwd = vim.fn.stdpath("config")
    })
end)

-- autopairs
require("nvim-autopairs").setup({})

-- git integration
require("gitsigns").setup()
vim.keymap.set("n", "<leader>gi", "<cmd>Gitsigns preview_hunk<Enter>")
vim.keymap.set("n", "<leader>gn", "<cmd>Gitsigns next_hunk<Enter>")
vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns prev_hunk<Enter>")
vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<Enter>")
vim.keymap.set("n", "<leader>gu", "<cmd>Gitsigns reset_hunk<Enter>")

-- lsp
require("lsp")

-- completions
local cmp = require("blink.cmp")
cmp.build():pwait()
cmp.setup()

-- theme
require("theme")
