local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local previewers = require("telescope.previewers")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local actions = require("telescope.actions")

-- Telescope
require('telescope').setup {
    defaults = {
		  file_sorter    = require("telescope.sorters").get_fzy_sorter,
		  prompt_prefix  = " >",
		  color_devicons = true,

		  file_previewer   = require("telescope.previewers").vim_buffer_cat.new,
		  grep_previewer   = require("telescope.previewers").vim_buffer_vimgrep.new,
		  qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

      mappings = {
        i = {
          ['<C-x>'] = false,
          ['<C-q>'] = actions.send_to_qflist,
        },
      },
    },
  }

  -- Enable telescope
  pcall(require('telescope').load_extension, 'fzf')

  -- Keymaps for telescope
  vim.keymap.set('n', '<leader>p', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
  vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>f', function()
    require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = '[/] Fuzzily search in current buffer]' })

  vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
  vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
  vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
