local ok, mason = pcall(require, 'mason')
if not ok then return end

mason.setup()
require('mason-lspconfig').setup({
    ensure_installed = { 'pyright', 'clangd', 'tinymist', 'ruff' },
    -- automatic_enable = true is default in mason-lspconfig 2.0
})

-- LSP keybindings on attach
-- Neovim 0.11+ defaults: gd=definition, K=hover, grn=rename, gra=code_action, grr=refs, [d/]d=diagnostics
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local bufnr = event.buf
        local opts = { buffer = bufnr }

        -- LSP navigation (gd is not mapped by default in 0.11+)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

        vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, opts)

        -- Ctrl-s: format and save
        vim.keymap.set('n', '<C-s>', function()
            vim.lsp.buf.format({ async = false })
            vim.cmd('w')
        end, opts)

        -- Format on save (only if server supports it and doesn't handle willSaveWaitUntil)
        if not client:supports_method('textDocument/willSaveWaitUntil')
            and client:supports_method('textDocument/formatting') then
            vim.api.nvim_create_autocmd('BufWritePre', {
                buffer = bufnr,
                callback = function()
                    vim.lsp.buf.format({ bufnr = bufnr, id = client.id, timeout_ms = 1000 })
                end,
            })
        end
    end,
})

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
})

-- nvim-cmp setup
local ok_cmp, cmp = pcall(require, 'cmp')
if ok_cmp then

    local luasnip = require('luasnip')

    cmp.setup({
        sources = {
            { name = 'nvim_lsp' },
            { name = 'buffer', keyword_length = 3 },
        },
        snippet = {
            expand = function(args)
                luasnip.lsp_expand(args.body)
            end,
        },
        mapping = cmp.mapping.preset.insert({
            ['<CR>'] = cmp.mapping.confirm({ select = false }),
            ['<C-Space>'] = cmp.mapping.complete(),
            ['<Up>'] = cmp.mapping.select_prev_item(),
            ['<Down>'] = cmp.mapping.select_next_item(),
            ['<Tab>'] = cmp.mapping(function(fallback)
                if luasnip.expand_or_locally_jumpable() then
                    luasnip.expand_or_jump()
                else
                    fallback()
                end
            end, { 'i', 's' }),
            ['<S-Tab>'] = cmp.mapping(function(fallback)
                if luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, { 'i', 's' }),
        }),
    })
end

vim.opt.completeopt = { "menuone", "noselect" }
