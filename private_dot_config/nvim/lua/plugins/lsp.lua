-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'mason-org/mason.nvim', opts = { ui = { border = 'rounded' } } },
      'mason-org/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Native Nvim 0.11+ API. require('lspconfig').X.setup{} is deprecated:
      -- nvim-lspconfig's own docs say "Calls to require('lspconfig') will
      -- show a warning, which will later become an error". The plugin now
      -- only supplies server DEFINITIONS; enabling them is Neovim's job.

      -- capabilities shared by every server
      vim.lsp.config('*', {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            runtime = { version = 'LuaJIT' },
            diagnostics = { globals = { 'vim' } },
            workspace = {
              library = vim.api.nvim_get_runtime_file('', true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      vim.lsp.config('vtsls', {
        settings = {
          typescript = {
            inlayHints = {
              parameterNames = { enabled = 'literals' },
              functionLikeReturnTypes = { enabled = true },
            },
          },
        },
      })

      vim.lsp.config('basedpyright', {
        settings = {
          basedpyright = { analysis = { typeCheckingMode = 'standard' } },
        },
      })

      -- mason-lspconfig v2 calls vim.lsp.enable() for installed servers
      require('mason-lspconfig').setup({
        ensure_installed = {
          'vtsls', 'eslint', 'tailwindcss',
          -- gopls is DELIBERATELY absent: mason cannot build it on a machine
          -- without a Go toolchain. Once Go is installed, `:MasonInstall gopls`
          -- is enough; the vim.lsp configuration is already in place.
          'lua_ls', 'rust_analyzer', 'ruff', 'basedpyright',
        },
        automatic_enable = true,
      })

      -- The old config gave every server its own on_attach; one autocmd does.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kb_lsp_attach', { clear = true }),
        callback = function(ev)
          local function m(keys, fn, desc)
            vim.keymap.set('n', keys, fn, { buffer = ev.buf, desc = 'LSP: ' .. desc })
          end

          -- 'gd' is DELIBERATELY absent: it is mapped globally to fzf-lua's
          -- lsp_definitions. A buffer-local mapping here would shadow the
          -- global one and the picker would never open.
          m('gD', vim.lsp.buf.declaration,     'Bildirime git')
          m('gi', vim.lsp.buf.implementation,  'Uygulamaya git')
          m('gy', vim.lsp.buf.type_definition, 'Go to type definition')
          m('gr', vim.lsp.buf.rename,          'Rename symbol')
          m('ga', vim.lsp.buf.code_action,     'Kod eylemi')
          m('K',  function() vim.lsp.buf.hover({ border = 'rounded' }) end, 'Bilgi')

          vim.keymap.set('i', '<C-k>', function()
            vim.lsp.buf.signature_help({ border = 'rounded' })
          end, { buffer = ev.buf, desc = 'LSP: signature help' })

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end
        end,
      })
    end,
  },
}
