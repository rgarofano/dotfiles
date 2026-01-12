return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
            "nvim-tree/nvim-web-devicons"
        },
        config = function()
            require("telescope").setup({
                extenstions = {
                    fzf = {}
                }
            })
            local builtin = require("telescope.builtin")
            vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
            vim.keymap.set("n", "<C-f>", builtin.live_grep, {})
            vim.keymap.set("n", "gr", builtin.lsp_references, {})
            vim.keymap.set("n", "gs", builtin.grep_string, {})
            vim.keymap.set("n", "<leader>fc", function()
                builtin.find_files({
                    cwd = vim.fn.stdpath("config")
                })
            end)
        end,
    },
}
