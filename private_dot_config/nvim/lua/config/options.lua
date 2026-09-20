-- ~/.config/nvim/lua/config/options.lua
local opt = vim.opt

-- nvim-tree is in use, so netrw is disabled as its documentation requires.
-- This has to happen before the plugin loads, hence its place here.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- ── appearance ──────────────────────────────────────────────────────────
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.title = true
opt.scrolloff = 10
opt.sidescrolloff = 8
opt.signcolumn = 'yes'          -- keep text from jumping as the gutter appears
opt.laststatus = 3              -- tek global statusline
opt.showmode = false            -- lualine already shows it
opt.cmdheight = 1
opt.termguicolors = true
opt.pumheight = 12
opt.pumblend = 5
opt.winblend = 0
opt.wildoptions = 'pum'
opt.fillchars = { eob = ' ' }   -- hide the ~ markers past the end of file

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
opt.inccommand = 'split'        -- live preview for :s

-- ── files / undo ─────────────────────────────────────────────────────
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true             -- persistent undo instead of swap files
opt.undolevels = 10000
opt.fileencoding = 'utf-8'
opt.backupskip = { '/tmp/*', '/private/tmp/*' }
opt.autoread = true

-- ── pencere ──────────────────────────────────────────────────────────
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = 'screen'        -- keep content from jumping when splitting

-- ── zamanlama ────────────────────────────────────────────────────────
opt.updatetime = 200            -- CursorHold and gitsigns responsiveness
opt.timeoutlen = 400
opt.ttimeoutlen = 0

-- ── miscellaneous ──────────────────────────────────────────────────────────
opt.completeopt = { 'menu', 'menuone', 'noselect' }
opt.backspace = { 'start', 'eol', 'indent' }
opt.clipboard:append('unnamedplus')
opt.mouse = 'a'
opt.path:append('**')
opt.wildignore:append({ '*/node_modules/*', '*/.git/*', '*/dist/*' })
opt.formatoptions:append('r')   -- continue comments on <CR>
opt.shortmess:append('c')
opt.shell = vim.fn.executable('zsh') == 1 and 'zsh' or vim.o.shell

-- ── diagnostics ─────────────────────────────────────────────────────────
-- The correct replacement for the vim.lsp.with(...) call in the old
-- plugin/lspconfig.lua. That call was removed in Nvim 0.11, which is why the
-- config crashed on startup. The old config also set update_in_insert to true
-- in one place and false in another; false wins, so diagnostics do not flicker
-- while typing.
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
