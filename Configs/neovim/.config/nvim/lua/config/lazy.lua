local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup({
	require("plugins.autopairs"),
	require("plugins.blink"),
	require("plugins.bufferline"),
	require("plugins.cmp"),
	require("plugins.comment"),
	require("plugins.conform"),
	require("plugins.fidget"),
	require("plugins.gitsigns"),
	require("plugins.indent-blankline"),
	require("plugins.kanagawa-theme"),
	require("plugins.lsp"),
	require("plugins.mason"),
	require("plugins.mason-conform"),
	require("plugins.mini-icons"),
	require("plugins.neotree"),
	require("plugins.notify"),
	require("plugins.render-markdown"),
	require("plugins.telescope"),
	require("plugins.toggleterm"),
	require("plugins.treesitter"),
	require("plugins.trouble"),
	require("plugins.yazi"),
	checker = { enabled = true },
})
