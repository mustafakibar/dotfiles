return {
  {
    'navarasu/onedark.nvim',
    lazy = false,
    priority = 1000,       -- diğer her şeyden önce yüklensin
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
