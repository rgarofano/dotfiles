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
        vim.keymap.set("n", "gd", vim.lsp.buf.definition)
        vim.diagnostic.config({ virtual_text = true })
    end
})

vim.lsp.config["lua_ls"] = {
    settings = {
        Lua = {
            diagnostics = {
                globals = {
                    "vim"
                }
            }
        }
    }
}

vim.lsp.config["clangd"] = {
    cmd = {
        "clangd",
        "--clang-tidy",
        "--fallback-style=webkit"
    },
    on_attach = function(client, _)
        -- disable additional syntax highlighting
        client.server_capabilities.semanticTokensProvider = nil
    end
}

vim.lsp.enable({
    "lua_ls",
    "clangd"
})
