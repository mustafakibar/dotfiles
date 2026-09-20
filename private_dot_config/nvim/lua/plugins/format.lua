-- ~/.config/nvim/lua/plugins/format.lua

-- Proje kökünde biome.json varsa biome, yoksa prettierd → prettier zinciri.
local function web_formatters(bufnr)
  local conform = require('conform')
  local has_biome_cfg = vim.fs.root(bufnr, { 'biome.json', 'biome.jsonc' }) ~= nil
  if has_biome_cfg and conform.get_formatter_info('biome', bufnr).available then
    return { 'biome' }
  end
  return { 'prettierd', 'prettier', stop_after_first = true }
end

return {
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = 'ConformInfo',
    keys = {
      {
        '<leader>f',
        function() require('conform').format({ async = true }) end,
        mode = { 'n', 'v' },
        desc = 'Biçimlendir',
      },
    },
    opts = {
      formatters_by_ft = {
        lua    = { 'stylua' },
        python = { 'ruff_format' },
        rust   = { 'rustfmt' },
        go     = { 'goimports', 'gofmt' },
        sh     = { 'shfmt' },
        javascript     = web_formatters,
        javascriptreact = web_formatters,
        typescript     = web_formatters,
        typescriptreact = web_formatters,
        json   = web_formatters,
        jsonc  = web_formatters,
        css    = web_formatters,
        scss   = web_formatters,
        html   = web_formatters,
        yaml   = web_formatters,
        markdown = web_formatters,
      },
      -- LSP fallback KAPALI: yalnızca yukarıda tanımlı biçimlendiriciler
      -- çalışır, böylece davranış öngörülebilir olur.
      default_format_opts = { lsp_format = 'never' },
      format_on_save = { timeout_ms = 2000, lsp_format = 'never' },
    },
  },

  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPost', 'BufWritePost' },
    config = function()
      local lint = require('lint')
      -- DİKKAT: eslint ve ruff zaten LSP sunucusu olarak çalışıyor (Task 7).
      -- Burada onları TEKRARLAMIYORUZ — tanılamalar iki kez görünürdü.
      -- nvim-lint yalnızca LSP'nin kapsamadığı alanlara bakıyor.
      lint.linters_by_ft = {
        markdown   = { 'markdownlint' },
        sh         = { 'shellcheck' },
        bash       = { 'shellcheck' },
        dockerfile = { 'hadolint' },
      }

      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
        group = vim.api.nvim_create_augroup('kb_lint', { clear = true }),
        callback = function()
          -- kurulu olmayan linter'lar sessizce atlanır
          require('lint').try_lint(nil, { ignore_errors = true })
        end,
      })
    end,
  },
}
