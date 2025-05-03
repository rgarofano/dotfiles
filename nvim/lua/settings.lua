-- Leader Key
vim.g.mapleader = " "

-- Tab Size
vim.opt.tabstop = 8
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
-- Line numbers
vim.opt.number = true
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
vim.opt.signcolumn = "yes"
-- Decrease update time
vim.opt.updatetime = 250
-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300
-- Minimum number of lines above and below the cursor
vim.opt.scrolloff = 10
-- Highlight the current line
vim.opt.cursorline = true

-- Set <C-c> to the command key
vim.keymap.set('i', '<C-c>', '<Esc>', { noremap = true })
-- Remap copy to system clipboard
vim.keymap.set("n", "<leader>y", '"+y', {})
vim.keymap.set("v", "<leader>y", '"+y', {})
-- Remove search highlighting
vim.keymap.set("n", "<C-c>", "<cmd>nohlsearch<CR>")
-- Cycle through quick fix list
vim.keymap.set("n", "<leader>cn", "<cmd>cnext<CR>", {})
vim.keymap.set("n", "<leader>cp", "<cmd>cprevious<CR>", {})
-- Navigate between vim windows with C-{h,j,k,l}
vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<CR>", {})
vim.keymap.set("n", "<C-j>", "<cmd>wincmd j<CR>", {})
vim.keymap.set("n", "<C-k>", "<cmd>wincmd k<CR>", {})
vim.keymap.set("n", "<C-l>", "<cmd>wincmd k<CR>", {})
-- enable inline diagnostics
vim.diagnostic.config({ virtual_text = true })

-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.filetype.add({
    extension = {
        bsv = "bluespec",
    },
})
