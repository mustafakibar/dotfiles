-- ~/.config/nvim/lua/config/autocmds.lua
--
-- Eski kibar.lua ilk satırında 'vim.cmd("autocmd!")' çağırıyordu: bu, plugin'lerin
-- kendi autocmd'lerini de silen bir tuzaktır. Artık her grup kendi augroup'unda.

local function augroup(name)
  return vim.api.nvim_create_augroup('kb_' .. name, { clear = true })
end

-- yank'i kısaca vurgula
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup('highlight_yank'),
  callback = function()
    (vim.hl or vim.highlight).on_yank({ timeout = 150 })
  end,
})

-- dosyayı en son bırakılan satırda aç
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

-- kaydederken satır sonu boşluklarını temizle
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup('trim_whitespace'),
  callback = function()
    -- markdown'da satır sonundaki iki boşluk anlamlıdır
    if vim.bo.filetype == 'markdown' then return end
    local view = vim.fn.winsaveview()
    vim.cmd([[keeppatterns %s/\s\+$//e]])
    vim.fn.winrestview(view)
  end,
})

-- eksik dizinleri kaydederken oluştur
vim.api.nvim_create_autocmd('BufWritePre', {
  group = augroup('auto_mkdir'),
  callback = function(ev)
    if ev.match:match('^%w%w+://') then return end
    local file = (vim.uv or vim.loop).fs_realpath(ev.match) or ev.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- insert modundan çıkarken paste'i kapat (eski davranış korundu)
vim.api.nvim_create_autocmd('InsertLeave', {
  group = augroup('no_paste'),
  callback = function() vim.opt.paste = false end,
})

-- yardımcı pencereleri q ile kapat
vim.api.nvim_create_autocmd('FileType', {
  group = augroup('close_with_q'),
  pattern = { 'help', 'qf', 'man', 'checkhealth', 'lspinfo', 'lazy', 'mason' },
  callback = function(ev)
    vim.bo[ev.buf].buflisted = false
    vim.keymap.set('n', 'q', '<cmd>close<CR>', { buffer = ev.buf, silent = true })
  end,
})

-- terminal buffer'larında numara ve signcolumn kapalı
vim.api.nvim_create_autocmd('TermOpen', {
  group = augroup('term'),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})
