-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

vim.opt.rtp:prepend(lazypath)

return require("lazy").setup({
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate"
    },

    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" }
    },

    { "mbbill/undotree" },
    { "tpope/vim-fugitive" },
    { "lewis6991/gitsigns.nvim" },
    { "numToStr/Comment.nvim" },
    {
        "lervag/vimtex",
        lazy = false,
        init = function()
            vim.g.vimtex_view_method = "sioyek"
            vim.g.vimtex_compiler_method = "tectonic"
        end
    },

    -- Color theme(s)
    { "nyoom-engineering/oxocarbon.nvim" },
    { "Biscuit-Colorscheme/nvim" },
    {
        'yobibyte/helix-nvim',
        version = "*"
    },
    -- LSP
    { "neovim/nvim-lspconfig" },
    { "mason-org/mason.nvim" },
    { "mason-org/mason-lspconfig.nvim" },

    -- Autocompletion
    { "hrsh7th/nvim-cmp" },
    { "hrsh7th/cmp-nvim-lsp" },
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        config = function()
            require("luasnip").setup({ enable_autosnippets = true })
            require("rezvan.snippets").setup()
        end
    },

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
