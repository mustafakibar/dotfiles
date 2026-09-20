-- ~/.config/nvim/lua/config/autocmds.lua
--
-- The old config called vim.cmd('autocmd!') on its first line, which also
-- wiped the autocmds registered by plugins. Every group now owns its augroup.

local function augroup(name)
  return vim.api.nvim_create_augroup('kb_' .. name, { clear = true })
end

-- briefly highlight the yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup('highlight_yank'),
  callback = function()
    (vim.hl or vim.highlight).on_yank({ timeout = 150 })
  end,
})

-- reopen the file on the last edited line
vim.api.nvim_create_autocmd('BufReadPost', {
  group = augroup('last_loc'),
  callback = function(ev)
    if vim.tbl_contains({ 'gitcommit', 'gitrebase' }, vim.bo[ev.buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- strip trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup('trim_whitespace'),
  callback = function()
    -- two trailing spaces are meaningful in markdown
    if vim.bo.filetype == 'markdown' then return end
    -- :s throws E21 on a readonly or nomodifiable buffer, e.g. one opened with suda
    if not vim.bo.modifiable then return end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- create missing directories on save
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup('auto_mkdir'),
  callback = function(ev)
    if ev.match:match('^%w%w+://') then return end
    local file = (vim.uv or vim.loop).fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- leave paste mode when leaving insert, matching the previous behaviour
vim.api.nvim_create_autocmd('InsertLeave', {
  group = augroup('no_paste'),
  callback = function() vim.opt.paste = false end,
})

-- close helper windows with q
vim.api.nvim_create_autocmd('FileType', {
  group = augroup('close_with_q'),
  pattern = { 'help', 'qf', 'man', 'checkhealth', 'lspinfo', 'lazy', 'mason' },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = ev.buf, silent = true })
  end,
})

-- no line numbers or signcolumn in terminal buffers
vim.api.nvim_create_autocmd('TermOpen', {
  group = augroup('term'),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})
