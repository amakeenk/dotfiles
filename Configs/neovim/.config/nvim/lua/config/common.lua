vim.opt.number = true
vim.opt.cursorline = true
vim.opt.mouse = "a"
vim.opt.mousefocus = true
vim.opt.showmode = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.laststatus = 2
vim.opt.updatetime = 100
vim.opt.scrolloff = 8
vim.opt.wrap = false
vim.opt.virtualedit = "block"
vim.opt.undofile = true
vim.opt.clipboard:append("unnamedplus")
vim.opt.colorcolumn = "80"
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣", lead = "·" }
vim.opt.termguicolors = true

vim.wo.signcolumn = "yes"
vim.wo.linebreak = true

-- Disable legacy nvim-ts-context-commentstring behavior
vim.g.skip_ts_context_commentstring_module = true

-- Auto command to open neo-tree when vim starts with no files
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if vim.fn.argc() == 0 then
			if vim.fn.exists(":Neotree") == 2 then
				vim.cmd("Neotree focus")
			end
		end
	end,
})

-- Auto command to show notification when file is saved
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function()
		vim.notify("Файл сохранён: " .. vim.fn.expand("%:t"), "info", { title = "Сохранение" })
	end,
	desc = "Показывать уведомление при сохранении файла",
})
