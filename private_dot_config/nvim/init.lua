-- ~/.config/nvim/init.lua

-- Leader lazy.nvim'den ÖNCE ayarlanmalı: plugin'lerin <leader> tuşları
-- yükleme anında çözülür.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require('config.options')
require('config.keymaps')
require('config.autocmds')

-- ── lazy.nvim bootstrap ──────────────────────────────────────────────
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'lazy.nvim klonlanamadı:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nBir tuşa bas...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = { { import = 'plugins' } },
  install = { colorscheme = { 'onedark', 'habamax' } },
  checker = { enabled = true, notify = false },   -- güncelleme kontrolü, sessiz
  change_detection = { notify = false },
  ui = { border = 'rounded' },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip', 'tarPlugin', 'zipPlugin', 'tohtml', 'tutor', 'rplugin',
      },
    },
  },
})

vim.keymap.set('n', '<leader>L', '<cmd>Lazy<CR>', { desc = 'Lazy paneli' })
