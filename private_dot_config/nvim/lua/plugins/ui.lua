-- ~/.config/nvim/lua/plugins/ui.lua
return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'onedark',
        globalstatus = true,           -- laststatus=3 ile uyumlu
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
      sections = {
        lualine_c = { { 'filename', path = 1 } },
        lualine_x = { 'diagnostics', 'filetype' },
      },
    },
  },

  {
    'akinsho/bufferline.nvim',       -- eski ad 'nvim-bufferline.lua' idi
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        diagnostics = 'nvim_lsp',
        separator_style = 'slant',
        offsets = {
          { filetype = 'NvimTree', text = 'Dosyalar', highlight = 'Directory' },
        },
      },
    },
  },

  {
    'nvim-tree/nvim-tree.lua',       -- eski org 'kyazdani42' idi
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
    keys = {
      { '<leader>t', '<cmd>NvimTreeToggle<CR>', desc = 'Dosya ağacı' },
    },
    opts = {
      hijack_cursor = true,
      view = { width = 32 },
      renderer = { group_empty = true, highlight_git = true },
      filters = { dotfiles = false, custom = { '^%.git$' } },
      git = { enable = true },
      actions = { open_file = { quit_on_open = false } },
    },
  },

  {
    'catgoose/nvim-colorizer.lua',   -- norcalli/* arşivlendi
    event = 'BufReadPre',
    opts = {
      filetypes = { 'css', 'scss', 'html', 'javascript', 'typescript',
                    'javascriptreact', 'typescriptreact', 'lua' },
      user_default_options = { tailwind = true, css = true, mode = 'background' },
    },
  },
}
