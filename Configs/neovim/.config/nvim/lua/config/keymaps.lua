vim.g.mapleader = " "

vim.keymap.set("v", "p", '"_dP', { desc = "Paste from system clipboard over visual selection" })

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Show line diagnostics" })

vim.keymap.set("n", "<C-a>", "ggVG", { desc = "Select all" })

-- При вставке в визуальном режиме удалять выделенное в "черную дыру" (_),
-- чтобы сохранить текущий буфер обмена
vim.keymap.set("x", "p", [["_dP]])

vim.keymap.set("n", "Q", ":q!<CR>", { desc = "Quit current buffer without save" })
vim.keymap.set("n", "QA", ":qa!<CR>", { desc = "Quit all buffers without save and exit" })
vim.keymap.set("n", "W", ":w<CR>", { desc = "Save current buffer" })
vim.keymap.set("n", "WA", ":wa<CR>", { desc = "Save all buffers" })
vim.keymap.set("n", "WQA", ":wqa<CR>", { desc = "Save all buffers and exit" })

