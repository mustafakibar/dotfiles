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
      -- Nvim 0.11+ yerel API'si. require('lspconfig').X.setup{} kullanımdan
      -- kalktı: nvim-lspconfig dokümanı "Calls to require('lspconfig') will
      -- show a warning, which will later become an error" diyor. Plugin artık
      -- yalnızca sunucu TANIMLARINI sağlıyor; etkinleştirme Neovim'in işi.

      -- Tüm sunucular için ortak capabilities
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

      -- mason-lspconfig v2 kurulu sunucuları otomatik vim.lsp.enable() eder
      require('mason-lspconfig').setup({
        ensure_installed = {
          'vtsls', 'eslint', 'tailwindcss',
          'lua_ls', 'rust_analyzer', 'ruff', 'basedpyright', 'gopls',
        },
        automatic_enable = true,
      })

      -- Eski config her sunucuya ayrı on_attach veriyordu. Tek autocmd yeterli.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kb_lsp_attach', { clear = true }),
        callback = function(ev)
          local function m(keys, fn, desc)
            vim.keymap.set('n', keys, fn, { buffer = ev.buf, desc = 'LSP: ' .. desc })
          end

          -- 'gd' BİLEREK burada yok: Task 10 onu fzf-lua'nın lsp_definitions
          -- sürümüyle global olarak tanımlıyor. Burada buffer-yerel tanımlarsak
          -- buffer-yerel eşleme global olanı gölgeler ve picker hiç açılmaz.
          m('gD', vim.lsp.buf.declaration,     'Bildirime git')
          m('gi', vim.lsp.buf.implementation,  'Uygulamaya git')
          m('gy', vim.lsp.buf.type_definition, 'Tip tanımına git')
          m('gr', vim.lsp.buf.rename,          'Yeniden adlandır')
          m('ga', vim.lsp.buf.code_action,     'Kod eylemi')
          m('K',  function() vim.lsp.buf.hover({ border = 'rounded' }) end, 'Bilgi')

          vim.keymap.set('i', '<C-k>', function()
            vim.lsp.buf.signature_help({ border = 'rounded' })
          end, { buffer = ev.buf, desc = 'LSP: imza yardımı' })

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method('textDocument/inlayHint') then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
          end
        end,
      })
    end,
  },
}
