-- ~/.config/nvim/lua/plugins/treesitter.lua
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',     -- main is a full rewrite and needs Nvim 0.12+
    lazy = false,        -- the main branch does NOT support lazy-loading
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

      -- The main branch has no ensure_installed; installation is programmatic.
      -- install() skips what is already present, but the difference is still
      -- computed so no needless work happens on every startup.
      local to_install = parsers
      local ok, cfg = pcall(require, 'nvim-treesitter.config')
      if ok and type(cfg.get_installed) == 'function' then
        local installed = cfg.get_installed()
        to_install = vim.tbl_filter(function(p)
          return not vim.tbl_contains(installed, p)
        end, parsers)
      end
      if #to_install > 0 then
        -- The main branch builds parsers with the EXTERNAL tree-sitter CLI
        -- (>= 0.26.1). Without it install() fails silently, so make it loud.
        if vim.fn.executable('tree-sitter') == 0 then
          vim.schedule(function()
            vim.notify(
              'nvim-treesitter: `tree-sitter` CLI not found, cannot install parsers.\n'
                .. 'Install it with: cargo install tree-sitter-cli --locked',
              vim.log.levels.WARN
            )
          end)
        else
          local ok_install, err = pcall(function()
            require('nvim-treesitter').install(to_install)
          end)
          if not ok_install then
            vim.schedule(function()
              vim.notify('nvim-treesitter install() failed: ' .. tostring(err), vim.log.levels.ERROR)
            end)
          end
        end
      end

      -- The main branch does NOT enable highlighting itself; vim.treesitter.start() does.
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('kb_treesitter', { clear = true }),
        callback = function(ev)
          local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
          if not lang then return end
          if not pcall(vim.treesitter.language.add, lang) then return end
          -- If start() fails there is no parser, so leave indentexpr alone;
          -- otherwise gg=G flattens files whose language has no 'indents' query.
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
