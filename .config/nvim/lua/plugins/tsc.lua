---@type LazySpec
return {
  -- provides the :TSC command to type check the current project
  "dmmulroy/tsc.nvim",
  cmd = "TSC",
  opts = {
    -- https://github.com/dmmulroy/tsc.nvim?tab=readme-ov-file#why-doesnt-tscnvim-typecheck-my-entire-monorepo
    -- Why doesn't tsc.nvim typecheck my entire monorepo?
    -- In a monorepo setup, tsc.nvim only typechecks the project associated
    -- with the nearest tsconfig.json by default. If you need to typecheck
    -- across all projects in the monorepo, you must change the flags
    -- configuration option in the setup function to include --build. The
    -- --build flag instructs TypeScript to typecheck all referenced projects,
    -- taking into account project references and incremental builds for better
    -- management of dependencies and build performance. Your adjusted setup
    -- function should look like this:
    flags = { build = true },
  },

  config = function()
    require("tsc").setup({})
  end,
}
