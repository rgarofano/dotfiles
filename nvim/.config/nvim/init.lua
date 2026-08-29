require("settings")

vim.pack.add({
    -- telescope
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
    "https://github.com/nvim-telescope/telescope.nvim",
    -- autopairs
    "https://github.com/windwp/nvim-autopairs",
    -- git integration
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/neogitorg/neogit",
    -- LSP
    "https://github.com/neovim/nvim-lspconfig",
    -- completions
    "https://github.com/saghen/blink.lib",
    "https://github.com/saghen/blink.cmp",
    -- themes
    "https://github.com/edeneast/nightfox.nvim",
    "https://github.com/catppuccin/nvim",
})

-- telescope
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
vim.keymap.set("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<Enter>")
vim.keymap.set("n", "<leader>gn", "<cmd>Gitsigns next_hunk<Enter>")
vim.keymap.set("n", "<leader>gp", "<cmd>Gitsigns prev_hunk<Enter>")
vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns blame_line<Enter>")
vim.keymap.set("n", "<leader>gu", "<cmd>Gitsigns reset_hunk<Enter>")
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<CR>")

-- LSP
require("lsp")

-- completions
local cmp = require("blink.cmp")
cmp.build():pwait()
cmp.setup()

-- themes
require("theme")
