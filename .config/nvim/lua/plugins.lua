return require("packer").startup(function()
  use ( "wbthomason/packer.nvim"              ) -- Package manager
  use ( "sbdchd/neoformat"                    ) -- Formatting
  use ( "TimUntersberger/neogit"              ) -- Magit for Neovim
  use ( "nvim-lua/plenary.nvim"               ) -- Lua stuff
  use ( "nvim-lua/popup.nvim"                 ) -- Lua stuff
  use ( "nvim-telescope/telescope.nvim"       ) -- Fuzzy Finder
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make', cond = vim.fn.executable "make" == 1 } -- FZF Sorter
  use ( "neovim/nvim-lspconfig"               ) -- Collection of configurations for built-in LSP client
  use ( "hrsh7th/cmp-nvim-lsp"                ) -- Autocompletion
  use ( "hrsh7th/nvim-cmp"                    ) -- Autocompletion
  use ( "ThePrimeagen/harpoon"                ) 
  use ( "tpope/vim-fugitive"                  ) -- Git commands in nvim
  use ( "tpope/vim-rhubarb"                   ) -- Fugitive-companion to interact with github
  use ( "lewis6991/gitsigns.nvim"             )  -- Add git related info in the signs columns and popups
  use ( "numToStr/Comment.nvim"               ) -- "gc" to comment visual regions/lines
  use ( "williamboman/mason.nvim"             ) -- Automatically install language servers to stdpath
  use ( "williamboman/nvim-lsp-installer"     )
  require("mason").setup()
  use("gruvbox-community/gruvbox")
  use("folke/tokyonight.nvim")
  use({"catppuccin/nvim", as = "catppuccin" })
  use({
    'rose-pine/neovim',
    as = 'rose-pine',
    config = function()
        vim.cmd('colorscheme rose-pine')
    end
})
  use ( "nvim-lualine/lualine.nvim"           ) -- Fancier statusline
  use ( "lukas-reineke/indent-blankline.nvim" ) -- Add indentation guides even on blank lines
  use ( "tpope/vim-sleuth"                    ) -- Detect tabstop and shiftwidth automatically

  use { 'L3MON4D3/LuaSnip', requires = { 'saadparwaiz1/cmp_luasnip' } } -- Snippet Engine and Snippet Expansion

  use ( "nvim-treesitter/nvim-treesitter", {
    run = ":TSUpdate"
  })

  use ( "nvim-treesitter/nvim-treesitter-textobjects" ) -- Additional textobjects for treesitter
  
  -- Debugger
  use ( "mfussenegger/nvim-dap" )
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
  use 'theHamsta/nvim-dap-virtual-text'
end)

