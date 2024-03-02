---@type LazySpec
return {
  {
    -- https://github.com/ckolkey/ts-node-action
    -- Neovim Plugin for running functions on nodes.
    "ckolkey/ts-node-action",
    event = "BufRead",
    dependencies = { "nvim-treesitter" },
    config = function()
      local helpers = require("ts-node-action.helpers")

      local opts = {
        html = {
          self_closing_tag = {
            {
              --- @param node TSNode
              function(node)
                local content_nodes = helpers.destructure_node(node)
                local tag_name = content_nodes["tag_name"]

                local node_text = helpers.node_text(node)

                if type(node_text) == "table" then
                  local last_line = node_text[#node_text]
                  last_line = last_line:gsub("%s*/>$", "></" .. tag_name .. ">")
                  node_text[#node_text] = last_line

                  return node_text, { format = true }
                end

                -- single line
                ---@diagnostic disable-next-line: need-check-nil
                local text = node_text:gsub("%s*/>$", "></" .. tag_name .. ">")
                return text, { format = true }
              end,
              name = "Expand tag",
            },
          },

          start_tag = {
            {
              ---@param node TSNode
              function(node)
                -- if the tag has contents, we can't collapse it
                local parent_tag = node:parent()

                if not parent_tag or parent_tag:child_count() > 2 then
                  return
                end

                local text = helpers.node_text(node)

                if type(text) == "table" then
                  local last_line = text[#text]
                  last_line = last_line:gsub(">$", " />")
                  text[#text] = last_line

                  return text, { format = true, target = parent_tag }
                end

                -- single line
                ---@diagnostic disable-next-line: need-check-nil
                text = text:gsub(">$", " />")
                return text, { format = true, target = parent_tag }
              end,
              name = "Collapse empty tag",
            },
          },
        },
      }

      require("ts-node-action").setup(opts)
    end,
    keys = {
      {
        "<leader><enter>",
        function()
          require("ts-node-action").node_action()
        end,
      },
    },
  },
  {
    -- https://github.com/Wansmer/treesj
    -- Neovim plugin for splitting/joining blocks of code

    "Wansmer/treesj",
    event = "BufRead",
    keys = {
      {
        "<enter>",
        function()
          require("treesj").toggle()
        end,
      },
    },
    opts = {
      use_default_keymaps = false,
    },
    cmd = {
      "TSJToggle",
      "TSJSplit",
      "TSJJoin",
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
}
