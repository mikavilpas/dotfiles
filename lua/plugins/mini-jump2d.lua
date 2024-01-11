return {
  {
    "echasnovski/mini.jump2d",
    config = function()
      require("mini.jump2d").setup({})
    end,
    keys = {
      {
        "<leader>y",
        function()
          local MiniJump2d = require("mini.jump2d")
          MiniJump2d.start({
            view = {
              dim = true,
              n_steps_ahead = 3,
            },
            spotter = MiniJump2d.gen_pattern_spotter("^%s*%S", "end"),
          })
        end,
      },
    },
  },
}
