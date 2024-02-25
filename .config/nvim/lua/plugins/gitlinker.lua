---@type LazySpec
return {
  "linrongbin16/gitlinker.nvim",
  cmd = "GitLink",
  config = function()
    require("gitlinker").setup({
      router = {
        browse = {
          -- gitlab.baronatechnologies.fi
          ["^gitlab%.baronatechnologies%.fi"] = require("gitlinker.routers").gitlab_browse,
        },

        blame = {
          -- gitlab.baronatechnologies.fi
          ["^gitlab%.baronatechnologies%.fi"] = require("gitlinker.routers").gitlab_blame,
        },
      },
    })
  end,
}
