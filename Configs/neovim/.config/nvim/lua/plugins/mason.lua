return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "⟳",
						package_uninstalled = "✗",
					},
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"pylsp",
					"bashls",
					"jsonls",
					"yamlls",
					"taplo",
					"cssls",
					"html",
					"emmet_ls",
				},
				handlers = {
					pylsp = function()
						require("lspconfig").pylsp.setup({
							settings = {
								pylsp = {
									plugins = {
										pycodestyle = { enabled = false },
										pyflakes = { enabled = false },
										mccabe = { enabled = false },
									},
								},
							},
						})
					end,
					ruff_lsp = function()
						require("lspconfig").ruff_lsp.setup({
							init_options = {
								settings = {
									lineLength = 80,
								},
							},
						})
					end,
					ruff = function()
						require("lspconfig").ruff_lsp.setup({
							init_options = {
								settings = {
									lineLength = 80,
								},
							},
						})
					end,
					bashls = function()
						require("lspconfig").bashls.setup({})
					end,
					jsonls = function()
						require("lspconfig").jsonls.setup({})
					end,
					yamlls = function()
						require("lspconfig").yamlls.setup({})
					end,
					taplo = function()
						require("lspconfig").taplo.setup({})
					end,
					cssls = function()
						require("lspconfig").cssls.setup({})
					end,
					html = function()
						require("lspconfig").html.setup({})
					end,
					emmet_ls = function()
						require("lspconfig").emmet_ls.setup({})
					end,
					function(server_name)
						require("lspconfig")[server_name].setup({})
					end,
				},
			})
		end,
	},
}
