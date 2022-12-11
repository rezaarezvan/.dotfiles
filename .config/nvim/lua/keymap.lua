-- Keymaps
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Movement
vim.keymap.set('n', '<C-h>', 'b', { silent = true })
vim.keymap.set('n', '<C-l>', 'w', { silent = true })
vim.keymap.set('n', '<C-k>', '5k', { silent = true })
vim.keymap.set('n', '<C-j>', '5j', { silent = true })
vim.keymap.set('n', '<C-d>', '<C-d>zz', { silent = true })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { silent = true })

vim.keymap.set('v', '<C-h>', 'b', { silent = true })
vim.keymap.set('v', '<C-l>', 'w', { silent = true })
vim.keymap.set('v', '<C-k>', '5k', { silent = true })
vim.keymap.set('v', '<C-j>', '5j', { silent = true })
vim.keymap.set('v', '<C-d>', '<C-d>zz', { silent = true })
vim.keymap.set('v', '<C-u>', '<C-u>zz', { silent = true })

-- Disable arrow keys
vim.keymap.set('n', '<Left>', '<nop>', { silent = true })
vim.keymap.set('n', '<Right>', '<nop>', { silent = true })
vim.keymap.set('n', '<Down>', '<nop>', { silent = true })
vim.keymap.set('n', '<Up>', '<nop>', { silent = true })

vim.keymap.set('i', '<Left>', '<nop>', { silent = true })
vim.keymap.set('i', '<Right>', '<nop>', { silent = true })
vim.keymap.set('i', '<Down>', '<nop>', { silent = true })
vim.keymap.set('i', '<Up>', '<nop>', { silent = true })

vim.keymap.set('v', '<Left>', '<nop>', { silent = true })
vim.keymap.set('v', '<Right>', '<nop>', { silent = true })
vim.keymap.set('v', '<Down>', '<nop>', { silent = true })
vim.keymap.set('v', '<Up>', '<nop>', { silent = true })

-- QoL
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

-- Harpoon
vim.keymap.set('n',"<leader>w",  function() require("harpoon.mark").add_file() end, { silent = true })
vim.keymap.set('n',"<C-e>", function() require("harpoon.ui").toggle_quick_menu() end, { silent = true })
