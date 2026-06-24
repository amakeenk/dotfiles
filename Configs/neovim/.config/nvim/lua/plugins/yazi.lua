return {
	"mikavilpas/yazi.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	opts = {
		floating_window_scaling_factor = 0.9,
		floating_window_border = "rounded",
		yazi_floating_window_winblend = 0,
		keymaps = {},
		open_file_in_prev_win = true,
		additional_yazi_args = {},
	},
	keys = {
		{
			"gy",
			"<cmd>Yazi<CR>",
			desc = "Open yazi file manager",
		},
	},
	config = function(_, opts)
		require("yazi").setup(opts)
	end,
}
