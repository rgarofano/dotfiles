return {
    "tpope/vim-rails",
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            callback = function(args)
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                if client and client.name == "ruby_lsp" then
                    vim.keymap.set("n", "<leader>rc", "<cmd>Econtroller<CR>")
                    vim.keymap.set("n", "<leader>rv", "<cmd>Eview<CR>")
                    vim.keymap.set("n", "<leader>rm", "<cmd>Emodel<CR>")
                end
            end
        })
    end
}
