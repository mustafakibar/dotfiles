-- ~/.config/nvim/lua/plugins/ui.lua
return {
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = 'onedark',
        globalstatus = true,           -- matches laststatus=3
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
    'akinsho/bufferline.nvim',       -- formerly named 'nvim-bufferline.lua'
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
    'nvim-tree/nvim-tree.lua',       -- formerly under the 'kyazdani42' org
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = { 'NvimTreeToggle', 'NvimTreeFindFile' },
    keys = {
      { '<leader>t', '<cmd>NvimTreeToggle<CR>', desc = 'File tree' },
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
    'catgoose/nvim-colorizer.lua',   -- norcalli/* is archived
    event = 'BufReadPre',
    opts = {
      filetypes = { 'css', 'scss', 'html', 'javascript', 'typescript',
                    'javascriptreact', 'typescriptreact', 'lua' },
      user_default_options = { tailwind = true, css = true, mode = 'background' },
    },
  },
}
