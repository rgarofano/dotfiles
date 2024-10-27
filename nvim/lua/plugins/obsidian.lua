return {
	"epwalsh/obsidian.nvim",
	version = "*", -- recommended, use latest release instead of latest commit
	lazy = true,
	ft = "markdown",
	dependencies = {
		-- Required.
		"nvim-lua/plenary.nvim",
	},
	config = function()
		require("obsidian").setup({
			workspaces = {
				{
					name = "personal",
					path = "~/Notes",
				},
			},
			completion = {
				nvim_cmp = true,
				min_chars = 2,
			},
			mappings = {
				["<leader>ot"] = {
					action = function()
						return require("obsidian").util.toggle_checkbox()
					end,
					opts = { buffer = true },
				},
			},
			picker = {
				-- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
				name = "telescope.nvim",
			},
		})
		-- Nice UI features
		vim.opt.conceallevel = 1
		-- Following Links
		vim.keymap.set("n", "gd", function()
			if require("obsidian").util.cursor_on_markdown_link() then
				return "<cmd>ObsidianFollowLink<CR>"
			else
				return "gd"
			end
		end, { noremap = false, expr = true })
		-- Creating New Notes
		vim.keymap.set("n", "<leader>oc", function()
			return "<cmd>ObsidianNew<CR>"
		end, { noremap = false, expr = true })
		-- Renaming Notes
		vim.keymap.set("n", "<leader>or", function()
			return "<cmd>ObsidianRename<CR>"
		end, { noremap = false, expr = true })
		-- Notes Fuzzy Finder
		vim.keymap.set("n", "<leader>off", function()
			return "<cmd>ObsidianQuickSwitch<CR>"
		end, { noremap = false, expr = true })
	end,
}
