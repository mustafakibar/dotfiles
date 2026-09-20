-- ~/.config/nvim/lua/plugins/fzf.lua

-- ── git worktree: fzf-lua üzerine ince sarmalayıcı ───────────────────
-- Eski config telescope'un git-worktree eklentisini kullanıyordu; fzf-lua'da
-- böyle bir eklenti yok ve plugin'in kendisi zaten git komutlarının ince bir
-- sarmalayıcısı. Doğrudan git'i çağırıyoruz.
local function worktree_list()
  local lines = vim.fn.systemlist({ 'git', 'worktree', 'list' })
  if vim.v.shell_error ~= 0 then
    vim.notify('Bir git deposunda değilsin', vim.log.levels.WARN)
    return
  end
  require('fzf-lua').fzf_exec(lines, {
    prompt = 'Worktree❯ ',
    actions = {
      ['default'] = function(selected)
        local path = selected and selected[1] and selected[1]:match('^(%S+)')
        if path then
          vim.cmd.tcd(path)
          vim.notify('Worktree: ' .. path)
        end
      end,
    },
  })
end

local function worktree_create()
  vim.ui.input({ prompt = 'Yeni worktree için dal adı: ' }, function(branch)
    if not branch or branch == '' then return end
    local parent = vim.fn.fnamemodify(vim.fn.getcwd(), ':h')
    local path = parent .. '/' .. branch
    local out = vim.fn.system({ 'git', 'worktree', 'add', path, '-b', branch })
    if vim.v.shell_error ~= 0 then
      vim.notify(out, vim.log.levels.ERROR)
      return
    end
    vim.cmd.tcd(path)
    vim.notify('Worktree oluşturuldu: ' .. path)
  end)
end

return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'FzfLua',
    keys = {
      -- eski telescope tuşları birebir korundu
      { 'ff', function() require('fzf-lua').files() end,            desc = 'Dosya bul' },
      { 'fb', function() require('fzf-lua').buffers() end,          desc = 'Buffer bul' },
      { 'fg', function() require('fzf-lua').live_grep() end,        desc = 'Metin ara' },
      { 'fh', function() require('fzf-lua').helptags() end,         desc = 'Yardım ara' },
      { 'fd', function() require('fzf-lua').diagnostics_document() end, desc = 'Tanılamalar' },
      { 'fw', worktree_list,   desc = 'Worktree seç' },
      { 'fc', worktree_create, desc = 'Worktree oluştur' },
      -- LSP: çok sonuçlu olanlar picker'dan daha iyi okunuyor
      { 'gd', function() require('fzf-lua').lsp_definitions({ jump1 = true }) end, desc = 'LSP: tanıma git' },
      { 'gR', function() require('fzf-lua').lsp_references({ jump1 = true }) end,  desc = 'LSP: referanslar' },
      { 'gs', function() require('fzf-lua').lsp_document_symbols() end,           desc = 'LSP: semboller' },
    },
    opts = {
      -- 'telescope' profili: fzf-lua'nın telescope görünüm ve tuşlarına en yakın
      -- hazır ayarı. Kas hafızası korunsun diye seçildi.
      'telescope',
      winopts = {
        height = 0.85,
        width = 0.85,
        preview = { layout = 'flex', scrollbar = 'float' },
      },
      files = {
        cmd = 'fd --type=file --hidden --follow --exclude=.git',
        git_icons = true,
      },
      grep = {
        rg_opts = '--column --line-number --no-heading --color=always '
               .. '--smart-case --hidden --glob=!.git/',
      },
    },
  },
}
