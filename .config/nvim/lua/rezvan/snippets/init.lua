local M = {}

M.setup = function()
    local ls = require("luasnip")
    local utils = require("rezvan.snippets.util.utils")
    local is_math = utils.with_opts(utils.is_math, true)

    local autosnippets = {}

    for _, s in ipairs({
        "math",
        "math_wrA",
    }) do
        vim.list_extend(
            autosnippets,
            require(("rezvan.snippets.%s"):format(s)).retrieve(is_math)
        )
    end

    for _, ft in ipairs({ "plaintex", "tex", "markdown" }) do
        ls.add_snippets(ft, autosnippets, {
            type = "autosnippets",
            default_priority = 0,
        })
    end
end


return M
