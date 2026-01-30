local ok, ls = pcall(require, "luasnip")
if not ok then return end

ls.setup({ enable_autosnippets = true })
require("rezvan.snippets").setup()
