return {
  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 1000,       -- load before everything else
    opts = {
      style = 'dark',
      transparent = false,
      lualine = { transparent = false },
    },
    config = function(_, opts)
      require('onedark').setup(opts)
      require('onedark').load()
    end,
  },
}
