local ok, ts = pcall(require, 'nvim-treesitter')
if not ok then return end

ts.setup {
    install_dir = vim.fn.stdpath('data') .. '/site'
}

local parsers = { 'python', 'lua', 'latex', 'markdown', 'markdown_inline', 'vim', 'vimdoc', 'bash', 'c', 'cpp', 'typst' }
ts.install(parsers)

-- Map plaintex filetype to use latex parser
vim.treesitter.language.register('latex', 'plaintex')

-- Enable treesitter highlighting for all buffers
vim.api.nvim_create_autocmd('FileType', {
    callback = function(args)
        pcall(vim.treesitter.start, args.buf)
    end,
})
