-- Leader settings
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Default options
local opts = { noremap = true, silent = true }

-- Keymap definitions
local keys = {
    -- Movement
    { { "n", "v" },      "<C-h>",     "b",                         opts },
    { { "n", "v" },      "<C-l>",     "w",                         opts },
    { { "n", "v" },      "<C-k>",     "5k",                        opts },
    { { "n", "v" },      "<C-j>",     "5j",                        opts },
    { { "n", "v" },      "<C-d>",     "<C-d>zz",                   opts },
    { { "n", "v" },      "<C-u>",     "<C-u>zz",                   opts },

    -- Disable arrow keys
    { { "n", "i", "v" }, "<Left>",    "<nop>",                     opts },
    { { "n", "i", "v" }, "<Right>",   "<nop>",                     opts },
    { { "n", "i", "v" }, "<Down>",    "<nop>",                     opts },
    { { "n", "i", "v" }, "<Up>",      "<nop>",                     opts },

    -- QoL
    { { "n", "v" },      "<tab>",     ">>",                        opts },
    { { "n", "v" },      "<S-tab>",   "<<",                        opts },
    { "n",               "<C-z>",     "u",                         opts },
    { "v",               "<C-x>",     "d",                         opts },
    { "n",               "<C-v>",     "p",                         opts },
    { "v",               "<leader>c", "y",                         opts },

    -- Wrapping
    { "n",               "k",         "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true } },
    { "n",               "j",         "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true } },

    -- Folding
    { "n",               "<Space>",   "za",                        opts },
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
