-- ~/.config/nvim/lua/plugins/editor.lua
return {
  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add          = { text = '┃' },
        change       = { text = '┃' },
        delete       = { text = '▁' },
        topdelete    = { text = '▔' },
        changedelete = { text = '~' },
      },
      current_line_blame = false,
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function m(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = 'Git: ' .. desc })
        end
        m('n', ']c', function() gs.nav_hunk('next') end, 'Sonraki değişiklik')
        m('n', '[c', function() gs.nav_hunk('prev') end, 'Önceki değişiklik')
        m('n', '<leader>gp', gs.preview_hunk,      'Değişikliği önizle')
        m('n', '<leader>gb', gs.blame_line,        'Satır blame')
        m('n', '<leader>gr', gs.reset_hunk,        'Değişikliği geri al')
        m('n', '<leader>gd', gs.diffthis,          'Diff')
      end,
    },
  },

  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = { check_ts = true },
    config = function(_, opts)
      require('nvim-autopairs').setup(opts)
      -- nvim-cmp ile entegrasyon: fonksiyon seçilince parantez eklensin
      local ok, cmp = pcall(require, 'cmp')
      if ok then
        cmp.event:on('confirm_done',
          require('nvim-autopairs.completion.cmp').on_confirm_done())
      end
    end,
  },

  {
    'folke/zen-mode.nvim',
    cmd = 'ZenMode',
    keys = { { '<C-w>o', '<cmd>ZenMode<CR>', desc = 'Zen modu' } },
    opts = { window = { width = 120 } },
  },

  {
    'lambdalisue/vim-suda',
    cmd = { 'SudaRead', 'SudaWrite' },
  },

  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
    ft = 'markdown',
    build = function() vim.fn['mkdp#util#install']() end,
  },
}
