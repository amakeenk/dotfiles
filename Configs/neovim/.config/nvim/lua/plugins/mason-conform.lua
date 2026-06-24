return {
	"zapling/mason-conform.nvim",
	dependencies = {
		"stevearc/conform.nvim",
		"williamboman/mason.nvim",
	},
	config = function()
		require("mason-conform").setup({
			ensure_installed = {
				"black",
				"isort",
				"stylua",
				"prettier",
				"shfmt",
				"jq",
				"yamlfmt",
				"taplo",
				"kdlfmt",
			},
		})
	end,
}

