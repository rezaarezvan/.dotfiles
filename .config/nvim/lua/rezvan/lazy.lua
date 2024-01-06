local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

return require("lazy").setup({
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    { "nvim-treesitter/playground" },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate"
    },

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { { "nvim-lua/plenary.nvim" } }
    },

    { "mbbill/undotree" },
    { "tpope/vim-fugitive" },
    { "lewis6991/gitsigns.nvim" },
    { "numToStr/Comment.nvim" },

    -- Color theme
    { "nyoom-engineering/oxocarbon.nvim" },
    { "https://github.com/Biscuit-Colorscheme/nvim" },
    -- -- LSP
    {
        "VonHeikemen/lsp-zero.nvim",
        branch = 'v3.x'
    },

    -- LSP Support
    { "neovim/nvim-lspconfig" },
    { "williamboman/mason.nvim" },
    { "williamboman/mason-lspconfig.nvim" },

    -- Autocompletion
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "L3MON4D3/LuaSnip" },

    -- Misc
    { "nvim-lualine/lualine.nvim" },
    { "github/copilot.vim" },

    -- Debugger
    { "mfussenegger/nvim-dap" },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap" }
    },

    { "theHamsta/nvim-dap-virtual-text" },
})
