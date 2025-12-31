vim.schedule(function()
    local ok, mason = pcall(require, 'mason')
    if not ok then return end

    mason.setup()
    require('mason-lspconfig').setup({
        ensure_installed = { 'pyright', 'clangd', 'tinymist', 'ruff' },
        -- automatic_enable = true is default in mason-lspconfig 2.0
    })
end)

-- LSP keybindings on attach
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local bufnr = event.buf
        local opts = { buffer = bufnr }

        -- Keybindings (0.11 has defaults: grn=rename, gra=code_action, grr=refs)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, opts)
        vim.keymap.set('n', '[d', vim.diagnostic.goto_next, opts)
        vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, opts)

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
vim.schedule(function()
    local ok, cmp = pcall(require, 'cmp')
    if not ok then return end

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
end)

vim.opt.completeopt = { "menuone", "noselect" }
