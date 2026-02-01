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

-- Native LSP completion setup
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('my.lsp', {}),
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        if client:supports_method('textDocument/completion') then
            -- Optional: trigger autocompletion on EVERY keypress. May be slow!
            local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
            client.server_capabilities.completionProvider.triggerCharacters = chars
            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end
    end,
})

vim.cmd [[set completeopt+=menuone,noselect,popup]]

-- Show LSP docs for builtin completion (resolve on selection)
vim.api.nvim_create_autocmd('CompleteChanged', {
    group = vim.api.nvim_create_augroup('my.lsp.completion_docs', { clear = true }),
    callback = function()
        local event = vim.v.event
        if not event or not event.completed_item then return end

        local cy = event.row
        local cx = event.col
        local cw = event.width
        local ch = event.height

        local item = event.completed_item
        local lsp = item.user_data and item.user_data.nvim and item.user_data.nvim.lsp
        local lsp_item = lsp and lsp.completion_item

        local client = lsp and vim.lsp.get_client_by_id(lsp.client_id)
            or vim.lsp.get_clients({ bufnr = 0 })[1]

        if not client or not lsp_item then return end

        client:request('completionItem/resolve', lsp_item, function(_, result)
            vim.cmd('pclose')

            if result and result.documentation then
                local docs = result.documentation.value or result.documentation
                if type(docs) == 'table' then docs = table.concat(docs, '\n') end
                if not docs or docs == '' then return end

                local buf = vim.api.nvim_create_buf(false, true)
                vim.bo[buf].bufhidden = 'wipe'

                local contents = vim.lsp.util.convert_input_to_markdown_lines(docs)
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, contents)
                vim.treesitter.start(buf, 'markdown')

                local dx = cx + cw + 1
                local dw = 60
                local anchor = 'NW'

                if dx + dw > vim.o.columns then
                    dw = vim.o.columns - dx
                    anchor = 'NE'
                end

                local win = vim.api.nvim_open_win(buf, false, {
                    relative = 'editor',
                    row = cy,
                    col = dx,
                    width = dw,
                    height = ch,
                    anchor = anchor,
                    border = 'none',
                    style = 'minimal',
                    zindex = 60,
                })

                vim.wo[win].conceallevel = 2
                vim.wo[win].wrap = true
                vim.wo[win].previewwindow = true
            end
        end)
    end,
})

vim.api.nvim_create_autocmd('CompleteDone', {
    group = vim.api.nvim_create_augroup('my.lsp.completion_docs_done', { clear = true }),
    callback = function()
        vim.cmd('pclose')
    end,
})

-- Set arrow keys for omnicomplete navigation
vim.cmd [[
    inoremap <expr> <Up>   pumvisible() ? "\<C-p>" : "\<Up>"
    inoremap <expr> <Down> pumvisible() ? "\<C-n>" : "\<Down>"
]]
