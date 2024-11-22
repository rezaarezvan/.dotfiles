local ls = require("luasnip")
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local s = ls.snippet

local MATH_NODES = {
    displayed_equation = true,
    inline_formula = true,
    math_environment = true,
}

local TEXT_NODES = {
    text_mode = true,
    label_definition = true,
    label_reference = true,
}

local function get_node_at_cursor()
    local pos = vim.api.nvim_win_get_cursor(0)
    local row, col = pos[1] - 1, pos[2]

    local parser = vim.treesitter.get_parser(0, "latex")
    if not parser then return end

    local root_tree = parser:parse({ row, col, row, col })[1]
    local root = root_tree and root_tree:root()
    if not root then return end

    return root:named_descendant_for_range(row, col, row, col)
end

local function is_math()
    local node = get_node_at_cursor()
    while node do
        if TEXT_NODES[node:type()] then
            return false
        elseif MATH_NODES[node:type()] then
            return true
        end
        node = node:parent()
    end
    return false
end

local function pipe(fns)
    return function(...)
        for _, fn in ipairs(fns) do
            if not fn(...) then
                return false
            end
        end
        return true
    end
end

local function no_backslash(line_to_cursor, matched_trigger)
    return not line_to_cursor:find("\\%a+$", - #line_to_cursor)
end

local function math_snippet(trigger, nodes, name)
    return s({
        trig = trigger,
        name = name or trigger,
        dscr = name,
        snippetType = "autosnippet",
        condition = pipe({ is_math, no_backslash })
    }, nodes)
end

local function greek_snippet(name)
    return math_snippet(name, { t("\\" .. name) }, name)
end

local snippets = {
    math_snippet("to", { t("\\to") }),
    math_snippet("mapsto", { t("\\mapsto") }),
    math_snippet("leq", { t("\\leq") }),
    math_snippet("geq", { t("\\geq") }),
    math_snippet("neq", { t("\\neq") }),

    math_snippet("sum", {
        t("\\sum_{i=1}^{n}")
    }, "sum"),

    math_snippet("prod", {
        t("\\prod_{i=1}^{n}")
    }, "product"),

    math_snippet("lim", {
        t("\\lim_{n\\to\\infty}")
    }, "limit"),

    math_snippet("RR", { t("\\mathbb{R}") }, "real numbers"),
    math_snippet("NN", { t("\\mathbb{N}") }, "natural numbers"),
    math_snippet("ZZ", { t("\\mathbb{Z}") }, "integers"),
    math_snippet("QQ", { t("\\mathbb{Q}") }, "rational numbers"),

    greek_snippet("alpha"),
    greek_snippet("beta"),
    greek_snippet("gamma"),
    greek_snippet("delta"),
    greek_snippet("epsilon"),
    greek_snippet("varepsilon"),
    greek_snippet("zeta"),
    greek_snippet("eta"),
    greek_snippet("theta"),
    greek_snippet("vartheta"),
    greek_snippet("iota"),
    greek_snippet("kappa"),
    greek_snippet("lambda"),
    greek_snippet("mu"),
    greek_snippet("nu"),
    greek_snippet("xi"),
    greek_snippet("pi"),
    greek_snippet("rho"),
    greek_snippet("varrho"),
    greek_snippet("sigma"),
    greek_snippet("tau"),
    greek_snippet("phi"),
    greek_snippet("varphi"),
    greek_snippet("chi"),
    greek_snippet("psi"),
    greek_snippet("omega"),

    s({
        trig = "([a-zA-Z])(%d)",
        regTrig = true,
        name = "auto subscript",
        snippetType = "autosnippet",
        condition = is_math
    }, {
        f(function(_, snip)
            return snip.captures[1] .. "_" .. snip.captures[2]
        end)
    })
}

local function setup()
    ls.add_snippets("tex", snippets, {
        type = "autosnippets",
    })
    ls.add_snippets("markdown", snippets, {
        type = "autosnippets",
    })
end

return {
    setup = setup
}
