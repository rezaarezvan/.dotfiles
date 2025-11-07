local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node

local M = {}

M.decorator = {}

local postfix_trig = function(match)
    return string.format("(%s)", match)
end

local postfix_node = f(function(_, snip)
    return string.format("\\%s", snip.captures[1])
end, {})

local build_snippet = function(trig, node, match, priority, name)
    return s({
        name = name and name(match) or match,
        trig = trig(match),
        priority = priority,
    }, vim.deepcopy(node))
end

local build_with_priority = function(trig, node, priority, name)
    return function(match)
        return build_snippet(trig, node, match, priority, name)
    end
end

local vargreek_postfix_completions = function()
    local re = "varepsilon|varphi|varrho|vartheta"

    local build = build_with_priority(postfix_trig, postfix_node, 200)
    return vim.tbl_map(build, vim.split(re, "|"))
end

local greek_postfix_completions = function()
    local re =
    "[aA]lpha|[bB]eta|[cC]hi|[dD]elta|[eE]psilon|[gG]amma|[iI]ota|[kK]appa|[lL]ambda|[mM]u|[nN]u|[oO]mega|[pP]hi|[pP]i|[pP]si|[rR]ho|[sS]igma|[tT]au|[tT]heta|[zZ]eta|[eE]ta"

    local build = build_with_priority(postfix_trig, postfix_node, 200)
    return vim.tbl_map(build, vim.split(re, "|"))
end

local postfix_completions = function()
    local re = "sin|cos|tan|csc|sec|cot|ln|log|exp|star"

    local build = build_with_priority(postfix_trig, postfix_node)
    return vim.tbl_map(build, vim.split(re, "|"))
end

local snippets = {}

function M.retrieve(is_math)
    local utils = require("rezvan.snippets.util.utils")
    local pipe, no_backslash = utils.pipe, utils.no_backslash

    local parse_snippet = ls.extend_decorator.apply(ls.parser.parse_snippet, {
        wordTrig = false,
        condition = pipe({ is_math, no_backslash }),
    }) --[[@as function]]

    local with_priority = ls.extend_decorator.apply(parse_snippet, {
        priority = 10,
    }) --[[@as function]]

    M.decorator = {
        wordTrig = true,
        trigEngine = "pattern",
        condition = pipe({ is_math, no_backslash }),
    }

    s = ls.extend_decorator.apply(ls.snippet, M.decorator) --[[@as function]]

    vim.list_extend(snippets, vargreek_postfix_completions())
    vim.list_extend(snippets, greek_postfix_completions())
    vim.list_extend(snippets, postfix_completions())
    vim.list_extend(snippets, { build_snippet(postfix_trig, postfix_node, "q?quad", 200) })

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
        with_priority({ trig = "asec", name = "asec" }, "\\arcsec ")
        ,
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
        parse_snippet({ trig = "mathcal", name = "mathcal" }, "\\mathcal{$1}$0"),
        parse_snippet({ trig = "mathbb", name = "mathbb" }, "\\mathbb{$1}$0"),
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

        parse_snippet({ trig = "align", name = "align" }, "\\begin{align*}\n$1\n\\end{align*} $0"),
        parse_snippet({ trig = "cases", name = "cases" }, "\\begin{cases}\n$1\n\\end{cases} $0"),
        parse_snippet({ trig = "equation", name = "equation" }, "\\begin{equation}\n$1\n\\end{equation} $0"),
        parse_snippet({ trig = "underbrace", name = "underbrace" },
            "\\underbrace{$1}_{$2}$0"
        ),
        parse_snippet({ trig = "underset", name = "underbrace" },
            "\\underset{$1}{$2}$0"
        ),
        parse_snippet({ trig = "uargmin", name = "underargmin" },
            "\\underset{$1}{\\arg\\min} \\ $0"
        ),
        parse_snippet({ trig = "uargmax", name = "underargmax" },
            "\\underset{$1}{\\arg\\max} \\ $0"
        ),
        parse_snippet({ trig = "argmin", name = "argmin" }, "\\arg\\min \\ $0"),
    })


    return snippets
end

return M
