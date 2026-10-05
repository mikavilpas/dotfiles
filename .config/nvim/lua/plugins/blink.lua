-- until blink is published https://www.lazyvim.org/extras/coding/blink#options
-- vim.g.lazyvim_blink_main = true

---@diagnostic disable: missing-fields
---@module "lazy"
---@type LazySpec
return {
  -- ../../../../../.local/share/nvim/lazy/blink.cmp/lua/blink/cmp/init.lua
  -- ../../../../../.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/coding/blink.lua
  "saghen/blink.cmp",
  -- version = false,
  version = "*",
  -- dir = "~/git/blink.cmp/",
  -- build = "cargo build --release",
  dependencies = {
    "rafamadriz/friendly-snippets",
    {
      -- ~/.local/share/nvim/lazy/blink-ripgrep.nvim/lua/blink-ripgrep/init.lua
      "mikavilpas/blink-ripgrep.nvim",
      version = "*",
      -- dir = "~/git/blink-ripgrep.nvim/",
    },
    -- completes github issues/PRs (#), mentions (@) and commits (:) via `gh`
    "Kaiser-Yang/blink-cmp-git",
  },

  config = function(_, opts)
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    local my_opts = {
      keymap = {
        ["<C-f>"] = {
          function(cmp)
            return cmp.select_next({ jump_by = "source_id" })
          end,
          "select_next",
        },
        ["<C-b>"] = {
          function(cmp)
            return cmp.select_prev({ jump_by = "source_id" })
          end,
          "select_prev",
        },
      },
      signature = {
        enabled = true,
      },
      snippets = {
        preset = "luasnip",
      },
      sources = {
        default = {
          "lsp",
          "path",
          "snippets",
          "buffer",
          "ripgrep",
          "git",
        },
        -- cmdline = {
        --   -- disable cmdline completion for now
        -- },
        providers = {
          path = {
            score_offset = 9,
            ---@type blink.cmp.PathOpts
            opts = {
              show_hidden_files_by_default = true,
            },
          },
          snippets = {
            score_offset = -100,
          },
          lsp = {
            score_offset = 8,
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                if item.client_name == "typescript-tools" then
                  -- when the completion adds an import, show the source
                  -- https://github.com/Saghen/blink.cmp/issues/1870#issuecomment-2956622232
                  local source = vim.tbl_get(item, "data", "entryNames", 1, "source")
                  if source then
                    item.labelDetails = item.labelDetails or {}
                    item.labelDetails.description = source
                  end
                end
              end

              return items
            end,
          },
          buffer = { score_offset = 5 },
          git = {
            module = "blink-cmp-git",
            name = "Git",
            enabled = function()
              return vim.tbl_contains({ "gitcommit", "markdown" }, vim.bo.filetype)
            end,
            opts = (function()
              local utils = require("blink-cmp-git.utils")
              local github = require("blink-cmp-git.default.github")

              -- e.g. github.com or foo.ghe.com
              ---@async
              local function git_host()
                return utils.get_repo_remote_url():gsub("^%a+://", ""):gsub("^[^/@]+@", ""):match("^[^:/]+") or ""
              end

              -- the default only enables github.com, also enable GitHub Enterprise
              ---@async
              local function enable()
                local host = git_host()
                return host == "github.com" or host:find("%.ghe%.com$") ~= nil
              end

              -- `gh api` queries github.com unless told otherwise, so pass the
              -- repo's host. Also fetch more than the default 30 items.
              local function get_command_args(default)
                ---@async
                return function(command, token)
                  local args = default(command, token)
                  if command == "gh" then
                    args[#args] = args[#args] .. "?per_page=100"
                    vim.list_extend(args, { "--hostname", git_host() })
                  end
                  return args
                end
              end

              -- insert the full url instead of `#123`
              local function get_insert_text(item)
                return item.html_url
              end

              ---@type blink-cmp-git.Options
              return {
                commit = {
                  -- short dates so the AuthorDate can be used in the insert text
                  get_command_args = function(command, token)
                    local args = require("blink-cmp-git.default.commit").get_command_args(command, token)
                    if command == "git" then
                      table.insert(args, "--date=short")
                    end
                    return args
                  end,
                  -- `abc123de (feat(x): subject, 2026-10-05)`, like
                  -- `git show --no-patch --pretty=reference`
                  get_insert_text = function(item)
                    local sha, subject, date
                    if type(item) == "table" then
                      sha, subject = item.sha, item.commit.message:match("[^\n]*")
                      date = item.commit.author.date:sub(1, 10)
                    else
                      sha, subject = item:match("^commit (%x+)"), item:match("\n\n%s*([^\n]*)")
                      date = item:match("\nAuthorDate:%s*(%S+)")
                    end
                    return ("%s (%s, %s)"):format(sha:sub(1, 8), subject or "", date or "")
                  end,
                },
                git_centers = {
                  github = {
                    issue = {
                      enable = enable,
                      get_command_args = get_command_args(github.issue.get_command_args),
                      get_insert_text = get_insert_text,
                    },
                    pull_request = {
                      enable = enable,
                      get_command_args = get_command_args(github.pull_request.get_command_args),
                      get_insert_text = get_insert_text,
                    },
                  },
                },
              }
            end)(),
          },
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            score_offset = -8,
            ---@module "blink-ripgrep"
            ---@type blink-ripgrep.Options
            opts = {
              toggles = {
                on_off = "<leader>tg",
                debug = "<leader>td",
              },
              backend = {
                use = "gitgrep-or-ripgrep",
              },
            },
            transform_items = function(_, items)
              for _, item in ipairs(items) do
                item.labelDetails = {
                  description = "(rg)",
                }
              end
              return items
            end,
          },
        },
      },
      fuzzy = {
        implementation = "rust",
        sorts = {
          "exact",
          "score",
          "sort_text",
        },
        prebuilt_binaries = {
          download = true,
        },
      },
      completion = {
        documentation = {
          window = {
            desired_min_height = 30,
            max_width = 120,
            max_height = 999,
            border = "rounded",
          },
          auto_show = true,
        },
        menu = {
          draw = {
            treesitter = { "lsp" },
          },
          max_height = 30,
        },
      },
    }
    opts = vim.tbl_deep_extend("force", opts, my_opts)

    -- workaround LazyVim not supporting the latest schema yet
    opts.sources.compat = nil
    require("blink.cmp").setup(opts)
  end,
}
