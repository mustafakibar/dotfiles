-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',     -- main = tam yeniden yazım; Nvim 0.12+ gerektirir
    lazy = false,        -- main branch lazy-load'u DESTEKLEMİYOR
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup()

      local parsers = {
        'bash', 'css', 'diff', 'dockerfile', 'git_config', 'gitcommit',
        'gitignore', 'go', 'gomod', 'gosum', 'html', 'javascript', 'jsdoc',
        'json', 'lua', 'luadoc', 'markdown', 'markdown_inline',
        'python', 'query', 'regex', 'rust', 'scss', 'toml', 'tsx',
        'typescript', 'vim', 'vimdoc', 'yaml',
      }

      -- main branch'te ensure_installed yok; kurulum programatik.
      -- install() zaten kurulu olanları atlar, ama yine de farkı hesaplıyoruz
      -- ki her açılışta gereksiz iş yapılmasın.
      local to_install = parsers
      local ok, cfg = pcall(require, 'nvim-treesitter.config')
      if ok and type(cfg.get_installed) == 'function' then
        local installed = cfg.get_installed()
        to_install = vim.tbl_filter(function(p)
          return not vim.tbl_contains(installed, p)
        end, parsers)
      end
      if #to_install > 0 then
        -- main branch parser derlemek için HARİCİ tree-sitter CLI (>= 0.26.1)
        -- kullanır. Yoksa install() sessizce başarısız olur; gürültülü yapalım.
        if vim.fn.executable('tree-sitter') == 0 then
          vim.schedule(function()
            vim.notify(
              'nvim-treesitter: `tree-sitter` CLI bulunamadı, parser kurulamıyor.\n'
                .. 'Kurulum: cargo install tree-sitter-cli --locked',
              vim.log.levels.WARN
            )
          end)
        else
          local ok_install, err = pcall(function()
            require('nvim-treesitter').install(to_install)
          end)
          if not ok_install then
            vim.schedule(function()
              vim.notify('nvim-treesitter install() hatası: ' .. tostring(err), vim.log.levels.ERROR)
            end)
          end
        end
      end

      -- main branch highlight'ı KENDİ AÇMIYOR; vim.treesitter.start() gerekiyor.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('kb_treesitter', { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          if not lang then return end
          if not pcall(vim.treesitter.language.add, lang) then return end
          -- start() başarısız olursa (parser yok) indentexpr'i DEĞİŞTİRME;
          -- aksi halde 'indents' sorgusu olmayan dillerde gg=G satırları düzleştirir.
          if not pcall(vim.treesitter.start, ev.buf, lang) then return end
          if vim.treesitter.query.get(lang, 'indents') then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    'windwp/nvim-ts-autotag',
    ft = {
      'html', 'xml', 'markdown', 'javascript', 'javascriptreact',
      'typescript', 'typescriptreact', 'svelte', 'vue',
    },
    opts = {},
  },
}
