-- Set colorscheme
vim.o.termguicolors       = true
vim.g.tokyonight_style    = "night"
vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }
vim.g.tokyonight_colors   = { hint = "orange", error = "#ff0000" }
vim.cmd [[colorscheme tokyonight]]
--vim.api.nvim_command('hi Normal guibg=NONE')