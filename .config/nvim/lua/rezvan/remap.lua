-- Leader settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Default options
local opts = { noremap = true, silent = true }

-- Keymap definitions
local keys = {
    -- Movement
    { "n", "<C-h>",     "b",                         opts },
    { "n", "<C-l>",     "w",                         opts },
    { "n", "<C-k>",     "5k",                        opts },
    { "n", "<C-j>",     "5j",                        opts },
    { "n", "<C-d>",     "<C-d>zz",                   opts },
    { "n", "<C-u>",     "<C-u>zz",                   opts },
    { "v", "<C-h>",     "b",                         opts },
    { "v", "<C-l>",     "w",                         opts },
    { "v", "<C-k>",     "5k",                        opts },
    { "v", "<C-j>",     "5j",                        opts },
    { "v", "<C-d>",     "<C-d>zz",                   opts },
    { "v", "<C-u>",     "<C-u>zz",                   opts },

    -- Disable arrow keys
    { "n", "<Left>",    "<nop>",                     opts },
    { "n", "<Right>",   "<nop>",                     opts },
    { "n", "<Down>",    "<nop>",                     opts },
    { "n", "<Up>",      "<nop>",                     opts },
    { "i", "<Left>",    "<nop>",                     opts },
    { "i", "<Right>",   "<nop>",                     opts },
    { "i", "<Down>",    "<nop>",                     opts },
    { "i", "<Up>",      "<nop>",                     opts },
    { "v", "<Left>",    "<nop>",                     opts },
    { "v", "<Right>",   "<nop>",                     opts },
    { "v", "<Down>",    "<nop>",                     opts },
    { "v", "<Up>",      "<nop>",                     opts },

    -- QoL
    { "n", "<S-a>",     ":tabp<cr>",                 opts },
    { "n", "<S-d>",     ":tabn<cr>",                 opts },
    { "n", "<tab>",     ">>",                        opts },
    { "n", "<S-tab>",   "<<",                        opts },
    { "v", "<tab>",     ">gv",                       opts },
    { "v", "<S-tab>",   "<gv",                       opts },
    { "n", "<C-z>",     "u",                         opts },
    { "v", "<C-x>",     "d",                         opts },
    { "n", "<C-v>",     "p",                         opts },
    { "v", "<leader>c", "y",                         opts },
    { "n", "<Space>",   "<Nop>",                     opts },
    { "v", "<Space>",   "<Nop>",                     opts },

    -- Wrapping
    { "n", "k",         "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true } },
    { "n", "j",         "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true } },

    -- Folding
    { "n", "<Space>",   "za",                        opts },
}

-- Setup function
local function setup()
    for _, key in pairs(keys) do
        vim.keymap.set(key[1], key[2], key[3], key[4])
    end
    vim.cmd [[command! Ex Oil]]
end

-- Export and run setup
setup()
return setup
