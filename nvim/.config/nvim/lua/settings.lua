-- Leader Key
vim.g.mapleader = " "
-- Tab Size
vim.opt.tabstop = 8
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
-- Line numbers
vim.opt.number = true
-- Save undo history
vim.opt.undofile = true
-- Show markers for LSP errors
vim.opt.signcolumn = "yes"
-- Decrease update time
vim.opt.updatetime = 250
-- Highlight when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})
-- Include files in sub directories when tab completing :find
vim.opt.path = "**"
-- Maximum scrollback in terminals
vim.opt.scrollback = 1000000
-- Leave terminal mode easily
vim.keymap.set("t", "<C-[><C-[>", "<C-\\><C-n>")
-- Use terminal mode by default
vim.api.nvim_create_autocmd({ "TermOpen", "BufEnter", "WinEnter" }, {
    pattern = "term://*",
    command = "startinsert"
})
-- Operate on tabs and windows in terminal mode
vim.keymap.set("t", "<C-w>h", "<cmd>wincmd h<CR>")
vim.keymap.set("t", "<C-w>j", "<cmd>wincmd j<CR>")
vim.keymap.set("t", "<C-w>k", "<cmd>wincmd k<CR>")
vim.keymap.set("t", "<C-w>l", "<cmd>wincmd l<CR>")
vim.keymap.set("t", "<C-w>T", "<cmd>wincmd T<CR>")
for i = 1, 9 do
    vim.keymap.set({ "n", "t" }, "<C-w>" .. i, "<C-\\><C-n>" .. i .. "gt")
end
-- Unified clipboard
vim.opt.clipboard = "unnamedplus"
