-- checkhealth implementation

return {
  check = function()
    vim.health.start("my-telescope-searches")

    if vim.fn.executable("fd") ~= 1 then
      vim.health.warn("fd not found on PATH")
    end

    if vim.fn.executable("rg") ~= 1 then
      vim.health.warn("rg not found on PATH")
    end

    if vim.fn.executable("grealpath") ~= 1 then
      vim.health.warn("grealpath not found on PATH")
    end

    vim.health.ok("my-telescope-searches")
  end,
}
