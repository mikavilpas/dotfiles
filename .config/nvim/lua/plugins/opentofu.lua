-- The LazyVim terraform extra formats and validates with `terraform`, which
-- isn't installed. OpenTofu is (via mise), so use its tools instead.
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.terraform = { "tofu_fmt" }
      opts.formatters_by_ft.tf = { "tofu_fmt" }
      opts.formatters_by_ft["terraform-vars"] = { "tofu_fmt" }
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.terraform = { "tofu" }
      opts.linters_by_ft.tf = { "tofu" }
    end,
  },
}
