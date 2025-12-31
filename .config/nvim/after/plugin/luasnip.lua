-- LuaSnip (deferred to ensure plugin is loaded)
vim.schedule(function()
    local ok, ls = pcall(require, "luasnip")
    if not ok then return end

    ls.setup({ enable_autosnippets = true })
    require("rezvan.snippets").setup()
end)
