return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	lazy = false,
	opts = {
		ensure_installed = {
			"lua",
			"vim",
			"vimdoc",
			"javascript",
			"typescript",
			"python",
			"bash",
			"json",
			"yaml",
			"html",
			"css",
			"markdown",
			"markdown_inline",
		},
		highlight = {
			enable = true,
		},
		indent = {
			enable = true,
		},
	},
	config = function(_, opts)
		local ok, configs = pcall(require, "nvim-treesitter.configs")
		if ok then
			configs.setup(opts)
		end
	end,
}
