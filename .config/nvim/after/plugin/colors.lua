function ColorDeez(color)
    vim.opt.background = "dark"
    color = color or "oxocarbon"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalSB", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalSBFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalSBNC", { bg = "none" })
end

ColorDeez()
