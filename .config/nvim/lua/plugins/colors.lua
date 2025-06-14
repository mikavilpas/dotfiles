---@module "catppuccin"

---@module "lazy"
---@type LazySpec
return {
  {
    "LazyVim/LazyVim",
    dependencies = {
      -- { "catppuccin/nvim" },
      -- { "savq/melange-nvim" },
      -- { "phha/zenburn.nvim" },
    },
    opts = {
      -- colorscheme = "zenburn",
      -- colorscheme = "melange",
      -- colorscheme = "solarized-osaka",
      -- colorscheme = "catppuccin-latte",
      -- colorscheme = "catppuccin-frappe",
      colorscheme = "catppuccin",
      -- colorscheme = "catppuccin-mocha",
    },
  },

  {
    "catppuccin/nvim",
    name = "catppuccin",

    ---@type CatppuccinOptions
    opts = {
      -- https://github.com/catppuccin/nvim?tab=readme-ov-file#configuration
      flavour = "macchiato",

      dim_inactive = { enabled = true, percentage = 0.13 },

      integrations = {
        hop = true,
        mason = true,
        grug_far = true,
        cmp = true,
        blink_cmp = true,
        noice = true,
        gitsigns = true,
        treesitter_context = true,
      },
      default_integrations = true,

      highlight_overrides = {
        macchiato = function(colors)
          -- https://catppuccin.com/palette
          -- macchiato colors:
          -- rosewater = "#f4dbd6",
          -- flamingo = "#f0c6c6",
          -- pink = "#f5bde6",
          -- mauve = "#c6a0f6",
          -- red = "#ed8796",
          -- maroon = "#ee99a0",
          -- peach = "#f5a97f",
          -- yellow = "#eed49f",
          -- green = "#a6da95",
          -- teal = "#8bd5ca",
          -- sky = "#91d7e3",
          -- sapphire = "#7dc4e4",
          -- blue = "#8aadf4",
          -- lavender = "#b7bdf8",
          -- text = "#cad3f5",
          -- subtext1 = "#b8c0e0",
          -- subtext0 = "#a5adcb",
          -- overlay2 = "#939ab7",
          -- overlay1 = "#8087a2",
          -- overlay0 = "#6e738d",
          -- surface2 = "#5b6078",
          -- surface1 = "#494d64",
          -- surface0 = "#363a4f",
          -- base = "#24273a",
          -- mantle = "#1e2030",
          -- crust = "#181926",
          return {
            TelescopePreviewLine = { fg = colors.base, bg = colors.mauve, style = { "bold" } },
            HopNextKey = { fg = colors.peach, bg = colors.none, style = { "bold" } },
            -- Swap these two for the default macchiato colors
            --
            -- Justification: the brighter color grabs the attention as the
            -- "priority", and should come first
            --
            -- HopNextKey1 = { bg = colors.none, fg = colors.blue, style = { "bold" } },
            -- HopNextKey2 = { bg = colors.none, fg = colors.teal, style = { "bold", "italic" } },
            SnacksIndent = { fg = colors.mantle, bg = colors.none },
            HopNextKey1 = { bg = colors.none, fg = colors.teal, style = { "bold" } },
            HopNextKey2 = { bg = colors.none, fg = colors.subtext0, style = { "italic" } },
            CopilotSuggestion = { fg = colors.surface2, bg = colors.none },
            SnacksPickerPickWin = { bg = colors.peach, fg = "#000000" },
            BlinkCmpGhostText = { fg = colors.rosewater, bg = colors.none },
          }
        end,
      },
    },
  },
}
