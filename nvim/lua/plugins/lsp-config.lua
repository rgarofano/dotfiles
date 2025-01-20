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
		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		local lspconfig = require("lspconfig")
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
		})
		lspconfig.clangd.setup({
			capabilities = capabilities,
			cmd = {
				"clangd",
				"--fallback-style=webkit",
			},
		})
		lspconfig.svlangserver.setup({
			cmd = { "svlangserver" },
			filetypes = { "bluespec" },
			root_dir = require("lspconfig").util.root_pattern(".git", "*.bsv"),
		})
		lspconfig.ts_ls.setup({
			capabilities = capabilities,
		})
		vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, {})
	end,
}
