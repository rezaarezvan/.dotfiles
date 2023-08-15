local map = vim.api.nvim_set_keymap
local conf = { noremap = true, silent = true }

-- Leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local keys = {
    -- -- Movement
    { "n", "<C-h>",     "b" },
    { "n", "<C-l>",     "w" },
    { "n", "<C-k>",     "5k" },
    { "n", "<C-j>",     "5j" },
    { "n", "<C-d>",     "<C-d>zz" },
    { "n", "<C-u>",     "<C-u>zz" },
    { "v", "<C-h>",     "b" },
    { "v", "<C-l>",     "w" },
    { "v", "<C-k>",     "5k" },
    { "v", "<C-j>",     "5j" },
    { "v", "<C-d>",     "<C-d>zz" },
    { "v", "<C-u>",     "<C-u>zz" },

    -- Disable arrow keys
    { "n", "<Left>",    "<nop>" },
    { "n", "<Right>",   "<nop>" },
    { "n", "<Down>",    "<nop>" },
    { "n", "<Up>",      "<nop>" },
    { "i", "<Left>",    "<nop>" },
    { "i", "<Right>",   "<nop>" },
    { "i", "<Down>",    "<nop>" },
    { "i", "<Up>",      "<nop>" },
    { "v", "<Left>",    "<nop>" },
    { "v", "<Right>",   "<nop>" },
    { "v", "<Down>",    "<nop>" },
    { "v", "<Up>",      "<nop>" },

    -- -- QoL
    { "n", "<C-s>",     ":LspZeroFormat<cr>:w<cr>" },
    { "n", "<S-a>",     ":tabp<cr>" },
    { "n", "<S-d>",     ":tabn<cr>" },
    { "n", "<tab>",     ">>" },
    { "n", "<S-tab>",   "<<" },
    { "v", "<tab>",     ">gv" },
    { "v", "<S-tab>",   "<gv" },
    { "n", "<C-z>",     "u" },
    { "v", "<C-x>",     "d" },
    { "n", "<C-v>",     "p" },
    { "v", "<leader>c", "y" },
    { "n", "<Space>",   "<Nop>" },
    { "v", "<Space>",   "<Nop>" },

    -- -- Wrapping
    { 'n', 'k',         "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true } },
    { 'n', 'j',         "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true } },
}

local setup = function()
    for _, v in pairs(keys) do
        if #v == 3 then
            map(v[1], v[2], v[3], conf)
        elseif #v == 4 then
            map(v[1], v[2], v[3], v[4])
        end
    end
end

return setup()
