-- Settings
vim.opt.guicursor     = ""

-- Splits
vim.opt.splitbelow    = true
vim.opt.splitright    = true

-- Tings
vim.opt.lazyredraw    = true
vim.opt.ruler         = true
vim.opt.showcmd       = true
vim.opt.errorbells    = false
vim.opt.tabstop       = 4
vim.opt.softtabstop   = 4
vim.opt.shiftwidth    = 4
vim.opt.expandtab     = true
vim.opt.smartindent   = true
vim.opt.wrap          = false

-- Set highlight on search
vim.opt.hlsearch      = false
vim.opt.incsearch     = true
vim.opt.termguicolors = true
vim.opt.scrolloff     = 8
vim.opt.signcolumn    = "yes"
vim.opt.isfname:append("@-@")
vim.opt.colorcolumn = "80"
vim.opt.updatetime = 50

-- Make line numbers default
vim.opt.nu = true
vim.opt.relativenumber = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- Case insensitive searching
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 250
vim.wo.signcolumn = 'yes'

vim.api.nvim_command('set clipboard+=unnamedplus')

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.highlight.on_yank()
    end,
    group = highlight_group,
    pattern = '*',
})

vim.diagnostic.config({ virtual_lines = false })
