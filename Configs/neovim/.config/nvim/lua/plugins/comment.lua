return {
	"numToStr/Comment.nvim",
	opts = {
		toggler = {
			line = "gcc",
			block = "gbc",
		},
		opleader = {
			line = "gc",
			block = "gb",
		},
		extra = {
			above = "gcO",
			below = "gco",
			eol = "gcA",
		},
		mappings = {
			basic = true,
			extra = true,
		},
		pre_hook = function(ctx)
			local ok, integration = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
			if ok then
				return integration.create_pre_hook()(ctx)
			end
		end,
	},
	dependencies = {
		{
			"JoosepAlviste/nvim-ts-context-commentstring",
			lazy = false,
			dependencies = { "nvim-treesitter/nvim-treesitter" },
			opts = {
				enable_autocmd = false,
			},
		},
	},
	config = function(_, opts)
		require("Comment").setup(opts)
	end,
}

