-- Treesitter (new main branch - uses native neovim APIs)
vim.schedule(function()
    local ok, ts = pcall(require, 'nvim-treesitter')
    if not ok then return end

    -- Optional: set install directory
    ts.setup {
        install_dir = vim.fn.stdpath('data') .. '/site'
    }

    -- Install parsers you need
    local parsers = { 'python', 'lua', 'latex', 'markdown', 'markdown_inline', 'vim', 'vimdoc', 'bash', 'c', 'cpp', 'typst' }
    ts.install(parsers)
end)

-- Map plaintex filetype to use latex parser
vim.treesitter.language.register('latex', 'plaintex')

-- Enable treesitter highlighting for all buffers
vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})
