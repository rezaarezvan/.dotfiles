vim.g.mapleader       = ' '
vim.g.maplocalleader  = ' '

vim.opt.splitright    = true
vim.opt.tabstop       = 4
vim.opt.softtabstop   = 4
vim.opt.shiftwidth    = 4
vim.opt.expandtab     = true
vim.opt.smartindent   = true
vim.opt.wrap          = false
vim.opt.hlsearch      = false
vim.opt.termguicolors = true
vim.opt.scrolloff     = 8
vim.opt.signcolumn    = "yes"
vim.opt.isfname:append("@-@")
vim.opt.colorcolumn    = "80"
vim.opt.updatetime     = 50
vim.opt.foldmethod     = "indent"
vim.opt.foldlevel      = 0
vim.opt.foldnestmax    = 20
vim.opt.foldenable     = true
vim.opt.nu             = true
vim.opt.relativenumber = true
vim.opt.swapfile       = false
vim.opt.backup         = false
vim.opt.undodir        = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile       = true
vim.o.mouse            = 'a'
vim.o.breakindent      = true
vim.o.ignorecase       = true
vim.o.smartcase        = true
vim.opt.clipboard:append('unnamedplus')
vim.opt.statusline = ' %f %m %= %y  %l:%c  %P '
vim.opt.laststatus = 2

local opts         = { noremap = true, silent = true }

-- Movement
vim.keymap.set({ "n", "v" }, "<C-h>", "b", opts)
vim.keymap.set({ "n", "v" }, "<C-l>", "w", opts)
vim.keymap.set({ "n", "v" }, "<C-k>", "5k", opts)
vim.keymap.set({ "n", "v" }, "<C-j>", "5j", opts)
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", opts)
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", opts)

-- Disable arrow keys
vim.keymap.set({ "n", "i", "v" }, "<Left>", "<nop>", opts)
vim.keymap.set({ "n", "i", "v" }, "<Right>", "<nop>", opts)
vim.keymap.set({ "n", "i", "v" }, "<Down>", "<nop>", opts)
vim.keymap.set({ "n", "i", "v" }, "<Up>", "<nop>", opts)

-- QoL
vim.keymap.set({ "n", "v" }, "<tab>", ">>", opts)
vim.keymap.set({ "n", "v" }, "<S-tab>", "<<", opts)
vim.keymap.set("n", "<C-z>", "u", opts)
vim.keymap.set("v", "<C-x>", "d", opts)
vim.keymap.set("n", "<C-v>", "p", opts)
vim.keymap.set("v", "<leader>c", "y", opts)

-- Wrapping-aware movement
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Folding
vim.keymap.set("n", "<Space>", "za", opts)

-- Oil as file explorer
vim.cmd [[command! Ex Oil]]

-- Harpoon
vim.keymap.set("n", "<leader>a", function() require("harpoon"):list():add() end)
vim.keymap.set("n", "<C-e>", function()
    require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
end)
for j = 1, 9 do
    vim.keymap.set("n", "<leader>" .. j, function() require("harpoon"):list():select(j) end)
end

-- Undotree
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)

vim.pack.add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/nvim-telescope/telescope.nvim",
    { src = "https://github.com/ThePrimeagen/harpoon",            version = "harpoon2" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    "https://github.com/mbbill/undotree",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/stevearc/oil.nvim",
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",
    "https://github.com/L3MON4D3/LuaSnip",
    "https://github.com/mitch1000/backpack.nvim",
    "https://github.com/github/copilot.vim",
}, { load = true })

vim.api.nvim_create_autocmd('User', {
    pattern = 'PackChanged',
    callback = function()
        local ok, ts = pcall(require, 'nvim-treesitter.install')
        if ok then ts.update() end
    end,
})

local yank_group = vim.api.nvim_create_augroup('HighlightYank', {})
vim.api.nvim_create_autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 40 })
    end,
})

vim.api.nvim_create_autocmd('BufWritePre', {
    group = vim.api.nvim_create_augroup('TrimWhitespace', {}),
    pattern = '*',
    command = [[%s/\s\+$//e]],
})

-- Colors / transparency ------------------------------------------------
vim.opt.background = "dark"
pcall(vim.cmd.colorscheme, "backpack")

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalSB", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalSBFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalSBNC", { bg = "none" })
vim.api.nvim_set_hl(0, "CopilotSuggestion", { fg = "#555555", ctermfg = 8 })

-- Harpoon setup
do
    local ok, harpoon = pcall(require, "harpoon")
    if ok then harpoon:setup() end
end

-- Telescope ------------------------------------------------------------
do
    local ok, telescope = pcall(require, 'telescope')
    if ok then
        local actions = require("telescope.actions")
        telescope.setup {
            defaults = {
                file_sorter      = require("telescope.sorters").get_fzy_sorter,
                prompt_prefix    = " >",
                color_devicons   = true,
                file_previewer   = require("telescope.previewers").vim_buffer_cat.new,
                grep_previewer   = require("telescope.previewers").vim_buffer_vimgrep.new,
                qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
                mappings         = {
                    i = {
                        ['<C-x>'] = false,
                        ['<C-q>'] = actions.send_to_qflist,
                    },
                },
            },
        }
        pcall(telescope.load_extension, 'fzf')

        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>p', builtin.oldfiles, { desc = 'Find recently opened files' })
        vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = 'Find existing buffers' })
        vim.keymap.set('n', '<leader>f', function()
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10, previewer = false,
            })
        end, { desc = 'Fuzzily search in current buffer' })
        vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = 'Search Files' })
        vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'Search Help' })
        vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = 'Search current Word' })
        vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = 'Search by Grep' })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'Search Diagnostics' })
    end
end

-- Treesitter -----------------------------------------------------------
do
    local ok, ts = pcall(require, 'nvim-treesitter')
    if ok then
        ts.setup { install_dir = vim.fn.stdpath('data') .. '/site' }
        ts.install({ 'python', 'lua', 'latex', 'markdown', 'markdown_inline', 'vim', 'vimdoc', 'bash', 'c', 'cpp',
            'typst' })
        vim.treesitter.language.register('latex', 'plaintex')
        vim.api.nvim_create_autocmd('FileType', {
            callback = function(args) pcall(vim.treesitter.start, args.buf) end,
        })
    end
end

-- LSP ------------------------------------------------------------------
do
    local ok, mason = pcall(require, 'mason')
    if ok then
        mason.setup()
        require('mason-lspconfig').setup({
            ensure_installed = { 'pyright', 'clangd', 'tinymist', 'ruff' },
        })
    end
end

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local bufnr = event.buf
        local o = { buffer = bufnr }

        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, o)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, o)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, o)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, o)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, o)
        vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, o)

        vim.keymap.set('n', '<C-s>', function()
            vim.lsp.buf.format({ async = false })
            vim.cmd('w')
        end, o)

        if not client:supports_method('textDocument/willSaveWaitUntil')
            and client:supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
                end,
            })
        end
    end,
})

vim.diagnostic.config({ virtual_text = true, signs = true, underline = true })

-- Native LSP completion
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method('textDocument/completion') then
            local chars = {}
            for i = 32, 126 do table.insert(chars, string.char(i)) end
            client.server_capabilities.completionProvider.triggerCharacters = chars
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end,
})

vim.cmd [[set completeopt+=menuone,noselect,popup]]

-- Completion docs popup
vim.api.nvim_create_autocmd('CompleteChanged', {
    group = vim.api.nvim_create_augroup('my.lsp.completion_docs', { clear = true }),
    callback = function()
        local event = vim.v.event
        if not event or not event.completed_item then return end

        local cy, cx, cw, ch = event.row, event.col, event.width, event.height
        local item = event.completed_item
        local lsp = item.user_data and item.user_data.nvim and item.user_data.nvim.lsp
        local lsp_item = lsp and lsp.completion_item
        local client = lsp and vim.lsp.get_client_by_id(lsp.client_id)
            or vim.lsp.get_clients({ bufnr = 0 })[1]
        if not client or not lsp_item then return end

        client:request('completionItem/resolve', lsp_item, function(_, result)
            vim.cmd('pclose')
            if result and result.documentation then
                local docs = result.documentation.value or result.documentation
                if type(docs) == 'table' then docs = table.concat(docs, '\n') end
                if not docs or docs == '' then return end

                local buf = vim.api.nvim_create_buf(false, true)
                vim.bo[buf].bufhidden = 'wipe'
                local contents = vim.lsp.util.convert_input_to_markdown_lines(docs)
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
                vim.treesitter.start(buf, 'markdown')

                local dx = cx + cw + 1
                local dw = 60
                local anchor = 'NW'
                if dx + dw > vim.o.columns then
                    dw = vim.o.columns - dx
                    anchor = 'NE'
                end

                local win = vim.api.nvim_open_win(buf, false, {
                    relative = 'editor',
                    row = cy,
                    col = dx,
                    width = dw,
                    height = ch,
                    anchor = anchor,
                    border = 'none',
                    style = 'minimal',
                    zindex = 60,
                })
                vim.wo[win].conceallevel = 2
                vim.wo[win].wrap = true
                vim.wo[win].previewwindow = true
            end
        end)
    end,
})

vim.api.nvim_create_autocmd('CompleteDone', {
    group = vim.api.nvim_create_augroup('my.lsp.completion_docs_done', { clear = true }),
    callback = function() vim.cmd('pclose') end,
})

vim.cmd [[
    inoremap <expr> <Up>   pumvisible() ? "\<C-p>" : "\<Up>"
    inoremap <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
]]

-- Oil ------------------------------------------------------------------
do
    local ok, oil = pcall(require, "oil")
    if ok then
        oil.setup({ default_file_explorer = true, view_options = { show_hidden = true } })
    end
end

-- Gitsigns -------------------------------------------------------------
do
    local ok, gitsigns = pcall(require, 'gitsigns')
    if ok then
        gitsigns.setup {
            signs = {
                add          = { text = '+' },
                change       = { text = '~' },
                delete       = { text = '_' },
                topdelete    = { text = '‾' },
                changedelete = { text = '~' },
            },
        }
    end
end

-- LuaSnip --------------------------------------------------------------
do
    local ok, ls = pcall(require, "luasnip")
    if ok then
        ls.setup({ enable_autosnippets = true })
        require("snippets").setup()
    end
end
