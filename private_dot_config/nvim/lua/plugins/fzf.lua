-- ~/.config/nvim/lua/plugins/fzf.lua

-- ── git worktree: a thin wrapper on top of fzf-lua ───────────────────
-- The old config used telescope's git-worktree extension. fzf-lua has no
-- such extension, and that plugin was itself a thin wrapper around git
-- commands, so git is called directly here.
local function worktree_list()
  local lines = vim.fn.systemlist({ 'git', 'worktree', 'list' })
  if vim.v.shell_error ~= 0 then
    vim.notify('Not inside a git repository', vim.log.levels.WARN)
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
  vim.ui.input({ prompt = 'Branch name for the new worktree: ' }, function(branch)
    if not branch or branch == '' then return end
    local parent = vim.fn.fnamemodify(vim.fn.getcwd(), ':h')
    local path = parent .. '/' .. branch
    local out = vim.fn.system({ 'git', 'worktree', 'add', path, '-b', branch })
    if vim.v.shell_error ~= 0 then
      vim.notify(out, vim.log.levels.ERROR)
      return
    end
    vim.cmd.tcd(path)
    vim.notify('Worktree created: ' .. path)
  end)
end

return {
  {
    'ibhagwan/fzf-lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    cmd = 'FzfLua',
    keys = {
      -- the old telescope keymaps are kept as they were
      { 'ff', function() require('fzf-lua').files() end,            desc = 'Find files' },
      { 'fb', function() require('fzf-lua').buffers() end,          desc = 'Buffer bul' },
      { 'fg', function() require('fzf-lua').live_grep() end,        desc = 'Metin ara' },
      { 'fh', function() require('fzf-lua').helptags() end,         desc = 'Search help' },
      { 'fd', function() require('fzf-lua').diagnostics_document() end, desc = 'Diagnostics' },
      { 'fw', worktree_list,   desc = 'Pick worktree' },
      { 'fc', worktree_create, desc = 'Create worktree' },
      -- LSP: queries with many results read better in a picker
      { 'gd', function() require('fzf-lua').lsp_definitions({ jump1 = true }) end, desc = 'LSP: go to definition' },
      { 'gR', function() require('fzf-lua').lsp_references({ jump1 = true }) end,  desc = 'LSP: referanslar' },
      { 'gs', function() require('fzf-lua').lsp_document_symbols() end,           desc = 'LSP: semboller' },
    },
    opts = {
      -- The 'telescope' profile is fzf-lua's closest preset to telescope's
      -- layout and keymaps, chosen so muscle memory still works.
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
