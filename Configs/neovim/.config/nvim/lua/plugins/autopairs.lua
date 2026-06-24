return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		require("nvim-autopairs").setup({
			active = true,
			on_config_done = nil,
			disable_filetype = { "TelescopePrompt", "vim" },
			disable_in_macro = false,
			disable_in_visualblock = false,
			disable_in_replace_mode = true,
			check_ts = true,
			ts_ignored_nodes = {},
			ts_config = {
				lua = { "string" },
				javascript = { "template_string" },
			},
			fast_wrap = {
				map = "<M-e>",
				chars = { "{", "}", "(", ")", "[", "]", '"', "'", "`" },
				pattern = [=[[%'%"%>%]%)%}%,]=],
				offset = 0,
				end_key = "$",
				keys = "qwertyuiopzxcvbnmasdfghjkl",
				check_comma = true,
				highlight = "Search",
				highlight_grey = "Comment",
			},
			enable_moveright = true,
			enable_afterquote = true,
			enable_check_bracket_line = true,
			enable_bracket_in_quote = true,
			enable_abbr = false,
			break_undo = true,
			check_ts_simple = true,
		})
		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
		local cmp = require("cmp")
		cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
	end,
}
