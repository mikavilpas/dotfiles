---@module "lazy"
---@type LazySpec
return {
  {
    -- ASD-STE100 is the Simplified Technical English standard from the
    -- aerospace industry. This skill applies its rules to text that a machine
    -- has to parse: tool descriptions, error messages, agent instructions.
    "https://github.com/danyuchn/asd-ste100-skill",
    name = "asd-ste100-skill",
    lazy = true,
    build = function(self)
      local skills_dir = vim.fn.expand("~/.claude/skills")
      vim.fn.mkdir(skills_dir, "p")

      -- SKILL.md is at the root of the repository
      require("yazi.plugin").symlink(self, vim.fs.joinpath(skills_dir, "asd-ste100"))
    end,
  },
}
