---@module "lazy"
---@type LazySpec
return {
  {
    -- added by
    -- https://github.com/LazyVim/LazyVim/blob/13a4a84e3485a36e64055365665a45dc82b6bf71/lua/lazyvim/plugins/extras/lang/git.lua
    "petertriho/cmp-git",
    enabled = false,
  },
  {
    "hrsh7th/nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      local cmp = require("cmp")

      ---@type cmp.ConfigSchema
      local new_options = {
        ---@diagnostic disable-next-line: missing-fields
        performance = {
          debounce = 0,
          throttle = 0,
        },
        ---@diagnostic disable-next-line: missing-fields
        confirmation = {
          default_behavior = "replace",
        },
        window = {
          completion = cmp.config.window.bordered({
            -- use all available space
            max_height = 0,
            winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
          }),
          documentation = cmp.config.window.bordered({
            -- use all available space
            max_height = 0,
            winhighlight = "Normal:Normal,FloatBorder:BorderBG,CursorLine:PmenuSel,Search:None",
          }),
        },
      }
      local final_options = vim.tbl_deep_extend("keep", new_options, opts)
      return final_options
    end,
  },

  {
    "amarakon/nvim-cmp-buffer-lines",
    keys = {
      {
        -- complete with lines from the current buffer - allows narrowing down
        -- the completion list by typing more
        "<c-l>", -- mnemonic: "line"
        mode = { "i" },
        function()
          require("cmp").complete({
            config = {
              sources = { { name = "buffer-lines" } },
            },
          })
        end,
      },
    },
  },

  {
    -- https://github.com/hrsh7th/cmp-cmdline
    "hrsh7th/cmp-cmdline",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
    },
    event = { "InsertEnter", "CmdlineEnter" },
    config = function()
      -- https://github.com/hrsh7th/cmp-cmdline
      local cmp = require("cmp")
      -- `/` and '?' cmdline setup.
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        -- this fixes a bug
        -- https://github.com/hrsh7th/cmp-cmdline/issues/96#issuecomment-1705873476
        completion = { completeopt = "menu,menuone,noselect" },
        sources = {
          { name = "buffer" },
        },
      })

      -- `:` cmdline setup.
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        -- this fixes this bug
        --
        -- first result auto-selected, but it doesn't search for the text in
        -- that result until I move selection down and back up again #96
        -- https://github.com/hrsh7th/cmp-cmdline/issues/96#issuecomment-1705873476
        completion = { completeopt = "menu,menuone,noselect" },
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        }),
      })
    end,
  },
  -- TODO this seems to disable lsp completion completely when enabled
  -- {
  --   "hrsh7th/cmp-buffer",
  --   config = function()
  --     local cmp = require("cmp")
  --     cmp.setup.buffer({
  --       sources = {
  --         {
  --           name = "buffer",
  --           ---@type cmp_buffer.Options
  --           ---@diagnostic disable-next-line: missing-fields
  --           option = {
  --             keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\%(\w\|á\|Á\|é\|É\|í\|Í\|ó\|Ó\|ú\|Ú\|ä\|ö\|Ä\|Ö\)*\%(-\%(\w\|á\|Á\|é\|É\|í\|Í\|ó\|Ó\|ú\|Ú\|ä\|ö\|Ä\|Ö\)*\)*\)]],
  --           },
  --         },
  --       },
  --     })
  --   end,
  -- },

  {
    -- https://github.com/lukas-reineke/cmp-rg
    "lukas-reineke/cmp-rg",
    keys = {
      {
        -- https://github.com/lukas-reineke/cmp-rg/issues/46#issuecomment-1345672195
        "<c-a>",
        mode = { "i" },
        function()
          require("cmp").complete({
            config = {
              sources = {
                {
                  name = "rg",
                  option = {
                    cwd = require("my-nvim-micro-plugins.main").find_project_root(),
                    additional_arguments = "--ignore-case",
                  },
                },
              },
            },
          })
        end,
        desc = "Complete with word in project",
      },
    },
  },
}
