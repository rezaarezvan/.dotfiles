vim.g.mapleader       = ' '
vim.g.maplocalleader  = ' '

vim.opt.splitright    = true
vim.opt.tabstop       = 4
vim.opt.softtabstop   = 4
vim.opt.shiftwidth    = 4
vim.opt.expandtab     = true
vim.opt.wrap          = false
vim.opt.hlsearch      = false
vim.opt.termguicolors = true
vim.opt.scrolloff     = 8
vim.opt.signcolumn    = "yes"
vim.opt.isfname:append("@-@")
vim.opt.colorcolumn    = "80"
vim.opt.foldmethod     = "expr"
vim.opt.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevelstart = 1
vim.opt.nu             = true
vim.opt.relativenumber = true
vim.opt.swapfile       = false
vim.opt.undodir        = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile       = true
vim.o.mouse            = 'a'
vim.o.breakindent      = true
vim.o.ignorecase       = true
vim.o.smartcase        = true
vim.opt.clipboard:append('unnamedplus')
vim.opt.winborder      = "rounded"

local opts         = { silent = true }

vim.g.canola = {
    hidden = { enabled = false, patterns = { "^%." }, always = {} },
    columns = { "permissions", "size", "mtime" },
    highlights = { columns = true },
    confirm = "delete",
    save = "auto",
    delete = { wipe = true },
}

vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-telescope/telescope.nvim",
    { src = "https://github.com/ThePrimeagen/harpoon",            version = "harpoon2" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    "https://github.com/lewis6991/gitsigns.nvim",
    { src = "https://github.com/barrettruth/canola.nvim", version = "canola", },
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/L3MON4D3/LuaSnip",
    "https://github.com/mitch1000/backpack.nvim",
    "https://github.com/github/copilot.vim",
})

-- Theme
vim.opt.background = "dark"
vim.cmd.colorscheme("backpack")

-- Transparent background
vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalSB", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalSBFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalSBNC", { bg = "none" })
vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#555555", ctermfg = 8 })

-- Movement
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", opts)
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", opts)

-- QoL
vim.keymap.set("v", "<tab>", ">gv", opts)
vim.keymap.set("v", "<S-tab>", "<gv", opts)

-- Wrapping-aware movement
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Folding
vim.keymap.set("n", "<Space>", function()
    return vim.fn.foldclosed(vim.fn.line('.')) == -1 and 'zc' or 'zO'
end, { expr = true, silent = true })

-- Canola as file explorer
vim.cmd [[command! Ex Canola]]

-- Undotree
vim.cmd("packadd nvim.undotree")
vim.keymap.set("n", "<leader>u", function()
    require("undotree").open({ command = "leftabove 30vnew" })
end)

vim.api.nvim_create_autocmd('User', {
    pattern = 'PackChanged',
    callback = function(event)
        if event.data.spec.name == 'nvim-treesitter' and event.data.kind ~= 'delete' then
            require('nvim-treesitter.install').update()
        end
    end,
})

local yank_group = vim.api.nvim_create_augroup('HighlightYank', {})
vim.api.nvim_create_autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.hl.hl_op({ higroup = 'IncSearch', timeout = 40 })
    end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('TrimWhitespace', {}),
    pattern = '*',
    callback = function()
        local view = vim.fn.winsaveview()
        vim.cmd([[keeppatterns %s/\s\+$//e]])
        vim.fn.winrestview(view)
    end,
})

-- Harpoon setup
do
    local harpoon = require("harpoon")
    harpoon:setup()

    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
    vim.keymap.set("n", "<C-e>", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
    end)
    for j = 1, 9 do
        vim.keymap.set("n", "<leader>" .. j, function() harpoon:list():select(j) end)
    end
end

-- Telescope ------------------------------------------------------------
do
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search Files' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Search by Grep' })
end

-- Treesitter -----------------------------------------------------------
do
    local ts = require('nvim-treesitter')
    ts.install({ 'python', 'lua', 'latex', 'markdown', 'markdown_inline', 'vim', 'vimdoc', 'bash', 'c', 'cpp',
        'typst' })
    vim.treesitter.language.register('latex', 'plaintex')
    vim.api.nvim_create_autocmd('FileType', {
        callback = function(args) pcall(vim.treesitter.start, args.buf) end,
    })
end

-- LSP ------------------------------------------------------------------
require('mason').setup() -- Prepends mason/bin to Neovim's PATH.

-- Server configs live in lsp/<name>.lua; install binaries once with :MasonInstall
vim.lsp.enable({ 'pyright', 'ruff', 'clangd', 'tinymist' })

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(event)
        local client = assert(vim.lsp.get_client_by_id(event.data.client_id))
        local bufnr = event.buf
        local o = { buffer = bufnr }

        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, o)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, o)
        vim.keymap.set('n', '<C-s>', function()
            vim.lsp.buf.format()
            vim.cmd('w')
        end, o)

        if client:supports_method('textDocument/completion') then
            vim.lsp.completion.enable(true, client.id, bufnr)
        end
    end,
})

vim.diagnostic.config({ virtual_text = true })

vim.opt.autocomplete = true
vim.opt.complete:prepend('o')
vim.opt.completeopt:append({ 'menuone', 'noselect' })
vim.keymap.set('i', '<Up>', function() return vim.fn.pumvisible() == 1 and '<C-p>' or '<Up>' end, { expr = true })
vim.keymap.set('i', '<Down>', function() return vim.fn.pumvisible() == 1 and '<C-n>' or '<Down>' end, { expr = true })

-- LuaSnip --------------------------------------------------------------
do
    require("luasnip").setup({ enable_autosnippets = true })
    require("snippets").setup()
end
