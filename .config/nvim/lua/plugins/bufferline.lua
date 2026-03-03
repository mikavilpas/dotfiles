---@type LazySpec
return {
  {
    "akinsho/bufferline.nvim",
    after = "catppuccin",
    opts = function(_, opts)
      local colors = require("catppuccin.palettes").get_palette("macchiato")

      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        max_name_length = 80,
        -- disable built-in icon (it renders between path and filename),
        -- we prepend it to the filename in name_formatter instead
        show_buffer_icons = false,
        -- we already show the full path via numbers, so the built-in
        -- duplicate prefix is redundant
        show_duplicate_prefix = false,
        -- show the icon + filename as the buffer name
        name_formatter = function(buf)
          local filename = vim.fn.fnamemodify(buf.path, ":t")
          local icon, _ =
            require("nvim-web-devicons").get_icon(filename, vim.fn.fnamemodify(buf.path, ":e"), { default = true })
          return icon .. " " .. filename
        end,
        -- show the directory path as the "number" (rendered before the name),
        -- which gets its own highlight group for separate coloring
        numbers = function(number_opts)
          local path = vim.fn.bufname(number_opts.id)
          local dir = vim.fn.fnamemodify(path, ":.:h")
          if dir == "." then
            return ""
          end
          return dir .. "/"
        end,
      })

      -- color customization goals:
      -- - the selected buffer stands out
      -- - unselected filenames are dim but not as dim as directory paths
      -- - directory paths are dimmer than filenames, so that they don't
      --   compete for attention but are still visible
      local current_file = colors.peach
      local other_file = colors.overlay2
      local directory = colors.surface1

      opts.highlights = require("catppuccin.special.bufferline").get_theme({
        custom = {
          macchiato = {
            buffer_selected = { fg = current_file },
            error_selected = { fg = current_file },
            warning_selected = { fg = current_file },
            hint_selected = { fg = current_file },
            info_selected = { fg = current_file },

            background = { fg = other_file },
            buffer_visible = { fg = other_file },
            error = { fg = other_file },
            error_visible = { fg = other_file },
            warning = { fg = other_file },
            warning_visible = { fg = other_file },
            hint = { fg = other_file },
            hint_visible = { fg = other_file },
            info = { fg = other_file },
            info_visible = { fg = other_file },

            numbers = { fg = directory },
            numbers_visible = { fg = directory },
            numbers_selected = { fg = directory },
          },
        },
      })

      return opts
    end,
  },
}
