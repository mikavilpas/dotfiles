-- checkhealth implementation for all the cli tools that I depend on

return {
  check = function()
    vim.health.start("my-cli-tools")

    local function check(application_name)
      if vim.fn.executable(application_name) ~= 1 then
        vim.health.warn(application_name .. " not found on PATH")
      end
    end

    check("fd")
    check("ffmpegthumbnailer")
    check("fzf")
    check("grealpath")
    check("jq")
    check("lazygit")
    check("lf")
    check("poppler")
    check("presenterm")
    check("rg")
    check("unar")
    check("zoxide")

    vim.health.ok("my-cli-tools")
  end,
}
