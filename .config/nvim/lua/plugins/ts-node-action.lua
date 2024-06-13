---@type LazySpec
return {
  {
    -- https://github.com/ckolkey/ts-node-action
    -- Neovim Plugin for running functions on nodes.
    "ckolkey/ts-node-action",
    dependencies = { "nvim-treesitter" },
    keys = {
      {
        "<leader><enter>",
        function()
          require("ts-node-action").node_action()
        end,
      },
    },
    config = function()
      local helpers = require("ts-node-action.helpers")

      ---@param element_name string the name of the content node that contains the tag's name
      local function expand_tag(element_name)
        --- @param node TSNode
        return function(node)
          local content_nodes = helpers.destructure_node(node)
          -- tsx calls this name, html calls it tag_name
          local tag_name = content_nodes[element_name]

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
        end
      end

      local function collapse_tag()
        ---@param node TSNode
        return function(node)
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
        end
      end

      local opts = {
        javascript = {
          jsx_self_closing_element = { { expand_tag("name"), name = "Expand tag" } },
          jsx_opening_element = { { collapse_tag(), name = "Collapse empty tag" } },
        },
        tsx = {
          jsx_self_closing_element = { { expand_tag("name"), name = "Expand tag" } },
          jsx_opening_element = { { collapse_tag(), name = "Collapse empty tag" } },
        },
        html = {
          self_closing_tag = { { expand_tag("tag_name"), name = "Expand tag" } },
          start_tag = { { collapse_tag(), name = "Collapse empty tag" } },
        },
        xml = {
          EmptyElemTag = { { expand_tag("Name"), name = "Expand tag" } },
          STag = { { collapse_tag(), name = "Collapse empty tag" } },
        },
      }

      require("ts-node-action").setup(opts)
    end,
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
          local is_writeable = vim.api.nvim_buf_get_option(0, "modifiable")

          -- work around some issues with the quickfix window
          if is_writeable then
            require("treesj").toggle()
          else
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<cr>", true, true, true), "n", true)
          end
        end,
        { noremap = true, silent = true },
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
