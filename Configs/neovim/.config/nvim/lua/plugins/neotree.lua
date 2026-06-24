return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("neo-tree").setup({
			close_if_last_window = false,
			use_default_mappings = true,
			window = {
				width = 70,
				mappings = {},
			},
			filesystem = {
				window = {
					mappings = {},
				},
				filtered_items = {
					hide_dotfiles = false,
					hide_gitignored = false,
				},
			},
			source_selector = {
				winbar = true,
				statusline = true,
			},
		})
		vim.keymap.set("n", "<leader>e", ":Neotree left reveal<CR>")
		vim.keymap.set("n", "<leader>s", ":Neotree float git_status<CR>")
	end,
}
