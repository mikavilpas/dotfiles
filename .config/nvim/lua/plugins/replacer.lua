---@module "lazy"

---@type LazySpec
return {
  {
    -- https://github.com/tpope/vim-abolish
    -- e.g. :%Subvert/old/new/g
    -- e.g. :%Subvert/facilit{y,ies}/building{,s}/g
    "tpope/vim-abolish",
    cmd = { "Subvert" },
  },
}
