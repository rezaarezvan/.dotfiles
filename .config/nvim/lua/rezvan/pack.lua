-- vim.pack plugin manager (neovim 0.12+)
vim.pack.add({
    -- Core
    "https://github.com/nvim-lua/plenary.nvim",

    -- Navigation
    "https://github.com/nvim-telescope/telescope.nvim",
    { src = "https://github.com/ThePrimeagen/harpoon",            version = "harpoon2" },

    -- Editor
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
    "https://github.com/mbbill/undotree",
    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/stevearc/oil.nvim",

    -- LSP (Mason for installation, native for config)
    "https://github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",
    "https://github.com/mason-org/mason-lspconfig.nvim",

    -- Snippets (autosnippets work independently)
    "https://github.com/L3MON4D3/LuaSnip",

    -- Completion
    "https://github.com/hrsh7th/nvim-cmp",
    "https://github.com/hrsh7th/cmp-nvim-lsp",

    -- Appearance
    "https://github.com/mitch1000/backpack.nvim",
    "https://github.com/nvim-lualine/lualine.nvim",

    -- AI
    "https://github.com/github/copilot.vim",
}, { load = true }) -- Force immediate loading

-- Run TSUpdate after plugin changes
vim.api.nvim_create_autocmd('User', {
    pattern = 'PackChanged',
    callback = function()
        local ok, ts = pcall(require, 'nvim-treesitter.install')
        if ok then ts.update() end
    end,
})
