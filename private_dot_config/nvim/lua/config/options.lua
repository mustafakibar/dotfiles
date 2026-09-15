-- ~/.config/nvim/lua/config/options.lua
local opt = vim.opt

-- nvim-tree kullanıyoruz; netrw devre dışı (nvim-tree dokümanının gereği).
-- Plugin yüklenmeden önce ayarlanmalı, bu yüzden burada.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ── görünüm ──────────────────────────────────────────────────────────
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.title = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.signcolumn = 'yes'          -- gutter gelip gidince metin zıplamasın
opt.laststatus = 3              -- tek global statusline
opt.showmode = false            -- lualine zaten gösteriyor
opt.cmdheight = 1
opt.termguicolors = true
opt.pumheight = 12
opt.pumblend = 5
opt.winblend = 0
opt.wildoptions = 'pum'
opt.fillchars = { eob = ' ' }   -- dosya sonundaki ~ işaretlerini gizle

-- ── girinti ──────────────────────────────────────────────────────────
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true
opt.autoindent = true
opt.smarttab = true
opt.breakindent = true
opt.linebreak = true
opt.wrap = true

-- ── arama ────────────────────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true
opt.inccommand = 'split'        -- :s için canlı önizleme

-- ── dosya / undo ─────────────────────────────────────────────────────
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true             -- swap yerine kalıcı undo
opt.undolevels = 10000
opt.fileencoding = 'utf-8'
opt.backupskip = { '/tmp/*', '/private/tmp/*' }
opt.autoread = true

-- ── pencere ──────────────────────────────────────────────────────────
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = 'screen'        -- bölerken içerik zıplamasın

-- ── zamanlama ────────────────────────────────────────────────────────
opt.updatetime = 200            -- CursorHold ve gitsigns tepkisi
opt.timeoutlen = 400
opt.ttimeoutlen = 0

-- ── çeşitli ──────────────────────────────────────────────────────────
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.backspace = { 'start', 'eol', 'indent' }
opt.clipboard:append('unnamedplus')
opt.mouse = 'a'
opt.path:append('**')
opt.wildignore:append({ '*/node_modules/*', '*/.git/*', '*/dist/*' })
opt.formatoptions:append('r')   -- <CR> ile yorum devam etsin
opt.shortmess:append('c')
opt.shell = vim.fn.executable('zsh') == 1 and 'zsh' or vim.o.shell

-- ── tanılama ─────────────────────────────────────────────────────────
-- Eski plugin/lspconfig.lua'daki vim.lsp.with(...) çağrısının doğru karşılığı.
-- O çağrı Nvim 0.11'de kaldırıldığı için config açılışta çöküyordu (spec B1).
-- Ayrıca eski config update_in_insert'ü bir yerde true, bir yerde false
-- yapıyordu; false seçildi (yazarken tanılama titremesin).
vim.diagnostic.config({
  virtual_text = { spacing = 4, prefix = '●' },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = ' ',
      [vim.diagnostic.severity.WARN]  = ' ',
      [vim.diagnostic.severity.HINT]  = ' ',
      [vim.diagnostic.severity.INFO]  = ' ',
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = 'rounded', source = true },
})
