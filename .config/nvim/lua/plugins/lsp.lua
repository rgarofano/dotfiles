return {
    "neovim/nvim-lspconfig",
    lazy = false,
    dependencies = {
        {
            "folke/lazydev.nvim",
            ft = "lua", -- only load on lua files
            opts = {
                library = {
                    -- See the configuration section for more details
                    -- Load luvit types when the `vim.uv` word is found
                    { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                },
            },
        },
    },
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("lsp.format", {}),
            callback = function(args)
                -- Format on save
                local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
                if not client:supports_method("textDocument/willSaveWaitUntil")
                    and client:supports_method("textDocument/formatting") then
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = vim.api.nvim_create_augroup("lsp.format", { clear = false }),
                        buffer = args.buf,
                        callback = function()
                            vim.lsp.buf.format({ bufnr = args.buf, id = client.id, timeout_ms = 1000 })
                        end,
                    })
                end
                -- LSP bindings
                vim.keymap.set("n", "K", vim.lsp.buf.hover)
                vim.keymap.set("n", "gd", vim.lsp.buf.definition)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
                vim.keymap.set("n", "mv", vim.lsp.buf.rename)
                -- Diagnostics
                vim.diagnostic.config({ virtual_text = true })
                vim.keymap.set("n", "<leader>qd", vim.diagnostic.setqflist)
            end
        })
        vim.lsp.config.clangd = {
            cmd = {
                "clangd",
                "--clang-tidy",
                "--fallback-style=webkit"
            }
        }
        vim.lsp.enable({
            "bashls",
            "clangd",
            "jedi_language_server",
            "lua_ls",
            "ruby_lsp",
            "ts_ls",
            "tailwindcss",
        })
    end,
}
