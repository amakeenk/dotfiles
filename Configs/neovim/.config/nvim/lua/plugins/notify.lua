return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	opts = {
		stages = "fade_in_slide_out",
		timeout = 1000,
		render = "default",
		max_width = 60,
		max_height = 20,
		minimum_width = 20,
		level = "Info",
		top_center = "Notification Center",
		background_colour = "NormalFloat",
		icons = {
			ERROR = "",
			WARN = "",
			INFO = "",
			DEBUG = "",
			TRACE = "✎",
		},
		border = "single",
		highlight = "NotifyBackground",
		on_open = function(win)
			vim.api.nvim_win_set_option(win, "winhl", "Normal:NotifyBackground,FloatBorder:NotifyBorder")
		end,
	},
	init = function()
		vim.notify = require("notify")
	end,
}
