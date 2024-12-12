-- Leader Key
vim.g.mapleader = " "

-- Tab Size
vim.opt.tabstop = 8
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = false

-- Remap copy to system clipboard
vim.keymap.set("n", "<leader>y", '"+y', {})
vim.keymap.set("v", "<leader>y", '"+y', {})

-- Remove search highlighting
vim.keymap.set("n", "<C-c>", "<cmd>nohlsearch<CR>")

-- Line numbers
vim.opt.relativenumber = true

-- Line Wrapping
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching
-- Except when one or more capital letters are in the search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Show markers for LSP errors
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Minimum number of lines above and below the cursor
vim.opt.scrolloff = 10

-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function ()
	vim.highlight.on_yank()
    end,
})
