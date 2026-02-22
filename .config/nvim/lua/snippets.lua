local M = {}

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

local function in_mathzone()
    local node = vim.treesitter.get_node({ ignore_injections = false })
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
            if not fn(...) then return false end
        end
        return true
    end
end

local function no_backslash(line_to_cursor, matched_trigger)
    return not line_to_cursor:find("\\%a+$", - #line_to_cursor)
end

local function is_math()
    return in_mathzone()
end

local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node
local i = ls.insert_node
local t = ls.text_node

local postfix_trig = function(match)
    return string.format("(%s)", match)
end

local postfix_node = f(function(_, snip)
    return string.format("\\%s", snip.captures[1])
end, {})

local function build_snippet(trig, node, match, priority, name)
    return s({
        name = name and name(match) or match,
        trig = trig(match),
        priority = priority,
    }, vim.deepcopy(node))
end

local function build_with_priority(trig, node, priority, name)
    return function(match)
        return build_snippet(trig, node, match, priority, name)
    end
end

local function vargreek_postfix_completions()
    local re = "varepsilon|varphi|varrho|vartheta"
    local build = build_with_priority(postfix_trig, postfix_node, 200)
    return vim.tbl_map(build, vim.split(re, "|"))
end

local function greek_postfix_completions()
    local re =
    "[aA]lpha|[bB]eta|[cC]hi|[dD]elta|[eE]psilon|[gG]amma|[iI]ota|[kK]appa|[lL]ambda|[mM]u|[nN]u|[oO]mega|[pP]hi|[pP]i|[pP]si|[rR]ho|[sS]igma|[tT]au|[tT]heta|[zZ]eta|[eE]ta"
    local build = build_with_priority(postfix_trig, postfix_node, 200)
    return vim.tbl_map(build, vim.split(re, "|"))
end

local function postfix_completions()
    local re = "sin|cos|tan|csc|sec|cot|ln|log|exp|star"
    local build = build_with_priority(postfix_trig, postfix_node)
    return vim.tbl_map(build, vim.split(re, "|"))
end

local frac_no_parens = {
    f(function(_, snip)
        return string.format("\\frac{%s}", snip.captures[1])
    end, {}),
    t("{"), i(1), t("}"), i(0),
}

local frac_node = {
    f(function(_, snip)
        local match = snip.trigger
        local stripped = match:sub(1, #match - 1)

        local idx = #stripped
        local depth = 0
        while idx >= 0 do
            if stripped:sub(idx, idx) == ")" then depth = depth + 1 end
            if stripped:sub(idx, idx) == "(" then depth = depth - 1 end
            if depth == 0 then break end
            idx = idx - 1
        end

        if depth ~= 0 then
            return string.format("%s\\frac{}", stripped)
        else
            return string.format("%s\\frac{%s}", stripped:sub(1, idx - 1), stripped:sub(idx + 1, #stripped - 1))
        end
    end, {}),
    t("{"), i(1), t("}"), i(0),
}

local frac_no_parens_triggers = {
    "(\\?[%w]+\\?^%w)/",
    "(\\?[%w]+\\?_%w)/",
    "(\\?[%w]+\\?^{%w*})/",
    "(\\?[%w]+\\?_{%w*})/",
    "(\\?%w+)/",
}

function M.setup()
    local cond = pipe({ is_math, no_backslash })

    local parse_snippet = ls.extend_decorator.apply(ls.parser.parse_snippet, {
        wordTrig = false,
        condition = cond,
    })

    local with_priority = ls.extend_decorator.apply(parse_snippet, {
        priority = 10,
    })

    local decorator = {
        wordTrig = true,
        trigEngine = "pattern",
        condition = cond,
    }

    -- Reassign module-level s so build_snippet (used by greek/postfix) picks up the condition
    s = ls.extend_decorator.apply(ls.snippet, decorator)

    local snippets = {}

    -- Greek / postfix completions
    vim.list_extend(snippets, vargreek_postfix_completions())
    vim.list_extend(snippets, greek_postfix_completions())
    vim.list_extend(snippets, postfix_completions())
    vim.list_extend(snippets, { build_snippet(postfix_trig, postfix_node, "q?quad", 200) })

    -- Math operator / symbol snippets
    vim.list_extend(snippets, {
        parse_snippet({ trig = "sqrt", name = "sqrt" }, "\\sqrt{$1}$0"),

        with_priority({ trig = "hat", name = "hat" }, "\\hat{$1}$0"),
        with_priority({ trig = "bar", name = "bar" }, "\\bar{$1}$0"),

        parse_snippet({ trig = "infty", name = "\\infty" }, "\\infty"),
        parse_snippet({ trig = "iin", name = "in" }, "\\in "),
        parse_snippet({ trig = "notin", name = "notin" }, "\\not\\in "),

        parse_snippet({ trig = "sum", name = "sum" }, "\\sum_{$1}^{${2:N}} $0"),
        parse_snippet({ trig = "prod", name = "prod" }, "\\prod_{$1}^{${2:N}} $0"),
        parse_snippet({ trig = "int", name = "integral" }, "\\int_{$1}^{$2} $0"),
        parse_snippet({ trig = "lim", name = "lim" }, "\\lim_{$1 \\to ${2:\\infty}} $0"),
        parse_snippet({ trig = "partial", name = "partial" }, "\\frac{\\partial $1}{\\partial $2} $0"),

        parse_snippet({ trig = "bmat", name = "bmat" }, "\\begin{bmatrix} $1 \\end{bmatrix} $0"),
        parse_snippet({ trig = "pmat", name = "pmat" }, "\\begin{pmatrix} $1 \\end{pmatrix} $0"),
        parse_snippet({ trig = "vmat", name = "vmat" }, "\\begin{vmatrix} $1 \\end{vmatrix} $0"),

        parse_snippet({ trig = "lr(", name = "left( right)" }, "\\left( $1 \\right) $0"),
        parse_snippet({ trig = "lr|", name = "left| right|" }, "\\left| $1 \\right| $0"),
        parse_snippet({ trig = "lr{", name = "left{ right}" }, "\\left\\{ $1 \\right\\} $0"),
        parse_snippet({ trig = "lr[", name = "left[ right]" }, "\\left[ $1 \\right] $0"),

        with_priority({ trig = "arcsin", name = "arcsin" }, "\\arcsin "),
        with_priority({ trig = "arctan", name = "arctan" }, "\\arctan "),
        with_priority({ trig = "arcsec", name = "arcsec" }, "\\arcsec "),
        with_priority({ trig = "asin", name = "asin" }, "\\arcsin "),
        with_priority({ trig = "atan", name = "atan" }, "\\arctan "),
        with_priority({ trig = "asec", name = "asec" }, "\\arcsec "),

        parse_snippet({ trig = "abs", name = "abs" }, "\\abs{$1}$0"),
        parse_snippet({ trig = "l1", name = "l1" }, "\\Vert $1 \\Vert_1 $0"),
        parse_snippet({ trig = "l2", name = "l2" }, "\\Vert $1 \\Vert_2 $0"),
        parse_snippet({ trig = "exits", name = "exists" }, "\\exists "),
        parse_snippet({ trig = "forall", name = "forall" }, "\\forall "),
        parse_snippet({ trig = "ldots", name = "ldots", priority = 100 }, "\\ldots "),
        parse_snippet({ trig = "vdots", name = "vdots", priority = 100 }, "\\vdots "),
        parse_snippet({ trig = "cdots", name = "cdots", priority = 100 }, "\\cdots "),
        parse_snippet({ trig = "ddots", name = "ddots", priority = 100 }, "\\ddots "),
        parse_snippet({ trig = "maps", name = "maps" }, "\\mapsto "),
        parse_snippet({ trig = "nabla", name = "nabla" }, "\\nabla "),
        parse_snippet({ trig = "frac", name = "Fraction" }, "\\frac{$1}{$2}$0"),
        parse_snippet({ trig = "to", name = "to", priority = 100 }, "\\to "),
        parse_snippet({ trig = "times", name = "cross" }, "\\times "),
        parse_snippet({ trig = "cdot", name = "cdot", priority = 100 }, "\\cdot "),

        parse_snippet({ trig = "text", name = "text" }, "\\text{$1}$0"),

        parse_snippet({ trig = "cvec", name = "column vector" },
            "\\begin{pmatrix}\n$1\n\\newline\n$2\n\\end{pmatrix}\n$0"),
        parse_snippet({ trig = "rvec", name = "row vector" },
            "\\begin{pmatrix} $1 & \\cdots & $2 \\end{pmatrix}$0"),

        parse_snippet({ trig = "mathcal", name = "mathcal" }, "\\mathcal{$1}$0"),
        parse_snippet({ trig = "mathsf", name = "mathsf" }, "\\mathsf{$1}$0"),
        parse_snippet({ trig = "mathbf", name = "mathbf" }, "\\mathbf{$1}$0"),
        parse_snippet({ trig = "mathbb", name = "mathbb" }, "\\mathbb{$1}$0"),
        parse_snippet({ trig = "mathrm", name = "mathrm" }, "\\mathrm{$1}$0"),
        parse_snippet({ trig = "RR", name = "R" }, "\\mathbb{R}"),
        parse_snippet({ trig = "DD", name = "D" }, "\\mathcal{D}"),
        parse_snippet({ trig = "EE", name = "expec" }, "\\mathbb{E}"),
        parse_snippet({ trig = "Var", name = "var" }, "\\mathrm{Var}"),
        parse_snippet({ trig = "Cov", name = "cov" }, "\\mathrm{Cov}"),
        parse_snippet({ trig = "ell", name = "l" }, "\\ell"),

        parse_snippet({ trig = "__", name = "subscript" }, "_{$1}$0"),
        parse_snippet({ trig = "^^", name = "superscript" }, "^{$1}$0"),
        parse_snippet({ trig = "neq", name = "neq" }, "\\neq "),
        parse_snippet({ trig = "leq", name = "leq" }, "\\leq "),
        parse_snippet({ trig = "geq", name = "geq" }, "\\geq "),
        parse_snippet({ trig = "sim", name = "sim" }, "\\sim "),
        parse_snippet({ trig = "approx", name = "approx" }, "\\approx "),
        parse_snippet({ trig = "pm", name = "pm" }, "\\pm "),
        parse_snippet({ trig = "mp", name = "mp" }, "\\mp "),
        parse_snippet({ trig = ":=", name = "coloneq" }, "\\coloneqq"),
        parse_snippet({ trig = "=:", name = "eqcolon" }, "\\eqqcolon"),
        parse_snippet({ trig = "mid", name = "mid" }, "\\mid "),

        parse_snippet({ trig = "align", name = "align" }, "\\begin{align*}\n$1\n\\end{align*} $0"),
        parse_snippet({ trig = "cases", name = "cases" }, "\\begin{cases}\n$1\n\\end{cases} $0"),
        parse_snippet({ trig = "equation", name = "equation" }, "\\begin{equation}\n$1\n\\end{equation} $0"),
        parse_snippet({ trig = "underbrace", name = "underbrace" }, "\\underbrace{$1}_{$2}$0"),
        parse_snippet({ trig = "underset", name = "underbrace" }, "\\underset{$1}{$2}$0"),
        parse_snippet({ trig = "uargmin", name = "underargmin" }, "\\underset{$1}{\\arg\\min} \\ $0"),
        parse_snippet({ trig = "uargmax", name = "underargmax" }, "\\underset{$1}{\\arg\\max} \\ $0"),
        parse_snippet({ trig = "argmin", name = "argmin" }, "\\arg\\min \\ $0"),
        parse_snippet({ trig = "argmax", name = "argmax" }, "\\arg\\max \\ $0"),
    })

    -- Fraction snippets
    local frac_sd = ls.extend_decorator.apply(ls.snippet, {
        wordTrig = false,
        trigEngine = "pattern",
        condition = pipe({ is_math }),
    })

    table.insert(snippets, frac_sd({
        priority = 1000,
        trig = ".*%)/",
        name = "() frac",
        wordTrig = true,
    }, vim.deepcopy(frac_node)))

    for _, trig in pairs(frac_no_parens_triggers) do
        table.insert(snippets, frac_sd({
            name = "Fraction no ()",
            trig = trig,
        }, vim.deepcopy(frac_no_parens)))
    end

    -- Register for tex/markdown filetypes
    for _, ft in ipairs({ "plaintex", "tex", "markdown" }) do
        ls.add_snippets(ft, snippets, {
            type = "autosnippets",
            default_priority = 0,
        })
    end
end

return M
