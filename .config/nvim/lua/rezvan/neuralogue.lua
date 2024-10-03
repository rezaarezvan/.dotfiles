local M = {}

function M.open_chat()
    local width = math.floor(vim.o.columns * 0.8)
    local height = math.floor(vim.o.lines * 0.8)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_option(buf, 'buftype', 'prompt')
    vim.fn.prompt_setprompt(buf, 'User: ')

    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        row = row,
        col = col,
        style = 'minimal',
        border = 'rounded',
    })

    vim.api.nvim_win_set_option(win, 'winblend', 10)
    vim.api.nvim_buf_set_keymap(buf, 'i', '<CR>', '<CR>', { noremap = true, silent = true })

    vim.cmd([[
    autocmd BufEnter <buffer> lua require('neuralogue').handle_input()
  ]])
end

function M.handle_input()
    local buf = vim.api.nvim_get_current_buf()
    vim.fn.prompt_setcallback(buf, function(text)
        vim.api.nvim_buf_set_lines(buf, -1, -1, false, { 'Bot: ' .. text })
        vim.fn.prompt_setprompt(buf, 'User: ')
    end)
end

return M
