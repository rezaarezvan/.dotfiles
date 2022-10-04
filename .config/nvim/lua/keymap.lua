-- Keymaps
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Movement
--vim.keymap.set('n', '<C-Left>', 'b', { silent = true })
--vim.keymap.set('n', '<C-Right>', 'w', { silent = true })
--vim.keymap.set('n', '<C-Up>', '5k', { silent = true })
--vim.keymap.set('n', '<C-Down>', '5j', { silent = true })

-- Movement
vim.keymap.set('n', '<C-h>', 'b', { silent = true })
vim.keymap.set('n', '<C-l>', 'w', { silent = true })
vim.keymap.set('n', '<C-k>', '5k', { silent = true })
vim.keymap.set('n', '<C-j>', '5j', { silent = true })

-- Disable arrow keys
vim.keymap.set('n', '<Left>', '<nop>', { silent = true })
vim.keymap.set('n', '<Right>', '<nop>', { silent = true })
vim.keymap.set('n', '<Down>', '<nop>', { silent = true })
vim.keymap.set('n', '<Up>', '<nop>', { silent = true })

vim.keymap.set('i', '<Left>', '<nop>', { silent = true })
vim.keymap.set('i', '<Right>', '<nop>', { silent = true })
vim.keymap.set('i', '<Down>', '<nop>', { silent = true })
vim.keymap.set('i', '<Up>', '<nop>', { silent = true })

-- QoL
vim.keymap.set('i', '<C-BS>', '<C-w>', { silent = true })
vim.keymap.set('n', '<C-s>', ':Neoformat<cr>:w<cr>', { silent = true })
vim.keymap.set('n', '<S-a>', ':tabp<cr>', { silent = true })
vim.keymap.set('n', '<S-d>', ':tabn<cr>', { silent = true })
vim.keymap.set('n', '<tab>', '>>', { silent = true })
vim.keymap.set('n', '<S-tab>', '<<', { silent = true })
vim.keymap.set('v', '<tab>', '>gv', { silent = true })
vim.keymap.set('v', '<S-tab>', '<gv', { silent = true })
vim.keymap.set('n', '<C-z>', 'u', { silent = true })
vim.keymap.set('v', '<C-x>', 'd', { silent = true })
vim.keymap.set('n', '<C-v>', 'p', { silent = true })
vim.keymap.set('v', '<leader>c', 'y', { silent = true })

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Wrapping
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader><S-d>', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader><d>', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

-- Harpoon
vim.keymap.set('n',"<leader>w",  function() require("harpoon.mark").add_file() end, { silent = true })
vim.keymap.set('n',"<C-e>", function() require("harpoon.ui").toggle_quick_menu() end, { silent = true })
