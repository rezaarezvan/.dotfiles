return require("packer").startup(function()
  use ( "wbthomason/packer.nvim"              ) -- Package manager
  use ( "sbdchd/neoformat"                    ) -- Formatting
  use ( "TimUntersberger/neogit"              ) -- Magit for Neovim
  use ( "nvim-lua/plenary.nvim"               ) -- Lua stuff
  use ( "nvim-lua/popup.nvim"                 ) -- Lua stuff
  use ( "nvim-telescope/telescope.nvim"       ) -- Fuzzy Finder
  use { 'nvim-telescope/telescope-fzf-native.nvim', 
    run = 'make', 
    cond = vim.fn.executable "make" == 1        -- FZF Sorter
  }   
  use ( "neovim/nvim-lspconfig"               ) -- Collection of configurations for built-in LSP client
  use ( "hrsh7th/cmp-nvim-lsp"                ) -- Autocompletion
  use ( "hrsh7th/nvim-cmp"                    ) -- Autocompletion
  use ( "hrsh7th/cmp-buffer"                  )
  use ( "onsails/lspkind-nvim"                )
  use ( "nvim-lua/lsp_extensions.nvim"        )
  use ( "glepnir/lspsaga.nvim"                )
  use ( "L3MON4D3/LuaSnip"                    )
  use ( "saadparwaiz1/cmp_luasnip"            )
  use ( "ThePrimeagen/harpoon"                ) -- HARPOOOOOOOON
  use ( "tpope/vim-fugitive"                  ) -- Git commands in nvim
  use ( "tpope/vim-rhubarb"                   ) -- Fugitive-companion to interact with github
  use ( "lewis6991/gitsigns.nvim"             )  -- Add git related info in the signs columns and popups
  use ( "numToStr/Comment.nvim"               ) -- "gc" to comment visual regions/lines
  use ( "williamboman/mason.nvim"             ) -- Automatically install language servers to stdpath
  use ( "williamboman/mason-lspconfig.nvim"   )
  require("mason").setup()
  
  -- Color themes
  use ( "gruvbox-community/gruvbox" )
  use ( "folke/tokyonight.nvim" )
  use { 'shaunsingh/oxocarbon.nvim', branch = 'fennel' }
  use ( {"catppuccin/nvim", as = "catppuccin"  })
  use ( { 'rose-pine/neovim', as = 'rose-pine' })
  
  -- Misc
  use ( "nvim-lualine/lualine.nvim"           ) -- Fancier statusline
  use ( "lukas-reineke/indent-blankline.nvim" ) -- Add indentation guides even on blank lines
  use ( "tpope/vim-sleuth"                    ) -- Detect tabstop and shiftwidth automatically
  use ( "nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
  use ( "nvim-treesitter/nvim-treesitter-textobjects" ) -- Additional textobjects for treesitter
  
  -- Debugger
  use ( "mfussenegger/nvim-dap" )
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" }}
  use ('theHamsta/nvim-dap-virtual-text')
end)

