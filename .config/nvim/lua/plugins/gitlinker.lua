---@module "lazy"

local lines = "#L{_A.LSTART}{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}"

---@param host string
---@param action "blob"|"blame"
local gitlab = function(host, action)
  return "https://" .. host .. "/{_A.ORG}/{_A.REPO}/-/" .. action .. "/{_A.REV}/{_A.FILE}" .. lines
end

---@param host string
---@param action "blob"|"blame"
local github = function(host, action)
  return "https://" .. host .. "/{_A.ORG}/{_A.REPO}/" .. action .. "/{_A.REV}/{_A.FILE}?plain=1" .. lines
end

-- The examples below are the ones from the upstream defaults (public hosts; our
-- hosts use the same url shapes):
-- https://github.com/linrongbin16/gitlinker.nvim/blob/035eda905cc462d03d59fbd21270ffe05074df81/lua/gitlinker/configs.lua
---@type LazySpec
return {
  "linrongbin16/gitlinker.nvim",
  cmd = "GitLink",
  opts = {
    router = {
      browse = {
        -- https://gitlab.com/linrongbin16/test/blob/e1c498a4bae9af6e61a2f37e7ae622b2cc629319/test.lua#L3-L5
        ["^gitlab%.baronatechnologies%.fi"] = gitlab("gitlab.baronatechnologies.fi", "blob"),
        -- https://github.com/linrongbin16/gitlinker.nvim/blob/9679445c7a24783d27063cd65f525f02def5f128/lua/gitlinker.lua#L3-L4
        ["^barona%.ghe%.com"] = github("barona.ghe.com", "blob"),
      },
      blame = {
        -- https://gitlab.com/linrongbin16/test/blame/e1c498a4bae9af6e61a2f37e7ae622b2cc629319/test.lua#L4-8
        ["^gitlab%.baronatechnologies%.fi"] = gitlab("gitlab.baronatechnologies.fi", "blame"),
        -- https://github.com/linrongbin16/gitlinker.nvim/blame/9679445c7a24783d27063cd65f525f02def5f128/lua/gitlinker.lua#L3-L7
        ["^barona%.ghe%.com"] = github("barona.ghe.com", "blame"),
      },
    },
  },
}
