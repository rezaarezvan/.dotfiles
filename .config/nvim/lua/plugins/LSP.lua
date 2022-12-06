local lsp = require('lsp-zero')
local cmp = require('cmp')

lsp.preset('recommended')
lsp.setup_nvim_cmp({
    mapping = cmp.mapping.preset.insert({
        ['<Tab>'] = cmp.config.disable
    }),
})
lsp.setup()