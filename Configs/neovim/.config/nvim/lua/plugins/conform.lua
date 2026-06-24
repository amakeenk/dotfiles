return {
	"stevearc/conform.nvim",
	lazy = true,
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local conform = require("conform")

		conform.setup({
			formatters_by_ft = {
				python = { "black", "isort" },
				lua = { "stylua" },
				javascript = { "prettier" },
				typescript = { "prettier" },
				json = { "prettier", "jq" },
				jsonc = { "prettier" },
				yaml = { "prettier", "yamlfmt" },
				toml = { "taplo" },
				markdown = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				less = { "prettier" },
				html = { "prettier" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				kdl = { "kdlfmt" },
			},
			-- format_on_save = { timeout_ms = 500, lsp_fallback = true },
		})

		vim.keymap.set({ "n", "v" }, "<leader>cf", function()
			conform.format({ lsp_fallback = true })
		end, { desc = "Format file or range (in visual mode)" })
	end,
}
