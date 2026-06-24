return {
	"akinsho/toggleterm.nvim",
	version = "*",
	config = function()
		require("toggleterm").setup({
			size = 10,
			open_mapping = [[<c-\>]],
			hide_numbers = true,
			shade_filetypes = {},
			shade_terminals = true,
			shading_factor = 2,
			start_in_insert = true,
			insert_mappings = true,
			persist_size = true,
			direction = "float",
			close_on_exit = true,
			shell = vim.o.shell,
			float_opts = {
				border = "curved",
				winblend = 0,
				highlights = {
					border = "Normal",
					background = "Normal",
				},
			},
		})
		local Terminal = require("toggleterm.terminal").Terminal
		local lazygit = Terminal:new({ cmd = "lazygit", hidden = true })

		function _LAZYGIT_TOGGLE()
			lazygit:toggle()
		end
		vim.keymap.set(
			"n",
			"<leader>t",
			"<cmd>ToggleTerm<cr>",
			{ noremap = true, silent = true, desc = "Toggle terminal" }
		)
		vim.keymap.set("i", "<leader>t", "<cmd>ToggleTerm<cr>", { noremap = true, silent = true })
		vim.keymap.set("t", "<leader>t", "<cmd>ToggleTerm<cr>", { noremap = true, silent = true })
		vim.keymap.set(
			"n",
			"<leader>tr",
			"<cmd>ToggleTermToggleAll<CR>",
			{ noremap = true, silent = true, desc = "Toggle all terminals" }
		)
		vim.keymap.set(
			"n",
			"<leader>g",
			"<cmd>lua _LAZYGIT_TOGGLE()<CR>",
			{ noremap = true, silent = true, desc = "Toggle lazygit" }
		)
	end,
}

