vim.schedule(function()
    local ok, telescope = pcall(require, 'telescope')
    if not ok then return end

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
    vim.keymap.set('n', '<leader>p', builtin.oldfiles, { desc = '[?] Find recently opened files' })
    vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>f', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
        })
    end, { desc = '[/] Fuzzily search in current buffer]' })

    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
end)
