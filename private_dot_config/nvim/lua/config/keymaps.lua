-- ~/.config/nvim/lua/config/keymaps.lua
-- Replaces the old lua/maps.lua. The leader is set in init.lua.
local map = vim.keymap.set
local o = { noremap = true, silent = true }

-- increment / decrement
map('n', '+', '<C-a>', o)
map('n', '-', '<C-x>', o)

-- select all
map('n', '<C-a>', 'gg<S-v>G', o)

-- window splits
map('n', 'ss', '<cmd>split<CR><C-w>w', o)
map('n', 'sv', '<cmd>vsplit<CR><C-w>w', o)

-- move between windows
map('n', 'sh', '<C-w>h', o)
map('n', 'sj', '<C-w>j', o)
map('n', 'sk', '<C-w>k', o)
map('n', 'sl', '<C-w>l', o)

-- resize windows
map('n', '<C-w><Left>',  '<C-w><', o)
map('n', '<C-w><Right>', '<C-w>>', o)
map('n', '<C-w><Up>',    '<C-w>+', o)
map('n', '<C-w><Down>',  '<C-w>-', o)

-- arama vurgusu
map('n', '<A-s>', '<cmd>set hlsearch!<CR>', o)

-- write / quit / reload
map('n', '<leader>r', '<cmd>source %<CR>', { desc = 'Source current file' })
map('n', '<leader>s', '<cmd>w<CR>',        { desc = 'Kaydet' })
map('n', '<leader>q', '<cmd>qa!<CR>',      { desc = 'Hepsini kapat' })

-- geri al / yinele
map('n', '<C-z>', 'u', o)
map('i', '<C-z>', '<C-o>u', o)
map('v', '<C-z>', '<Esc>u', o)
map('i', '<C-r>', '<C-o><C-r>', o)

-- sekmeler
map('n', '<leader>n', '<cmd>tabnew<CR>', { desc = 'New tab' })
map('n', '<Tab>',   '<cmd>tabnext<CR>', o)
map('n', '<S-Tab>', '<cmd>tabprevious<CR>', o)
for i = 1, 9 do
  -- The old config used '1gt<CR>'; the trailing <CR> sent a stray Enter.
  map('n', '<leader>' .. i, i .. 'gt', o)
end
map('n', '<leader><Tab>', 'g<Tab>', o)

-- quick Esc, and move the cursor on
map('i', 'jk', '<Esc>', o)
map('i', 'kj', '<Right>', o)

-- girinti modunda kal
map('v', '<', '<gv', o)
map('v', '>', '>gv', o)

-- buffer gezinme
map('n', '<S-l>', '<cmd>bnext<CR>', o)
map('n', '<S-h>', '<cmd>bprevious<CR>', o)

-- move lines
map('n', '<A-j>', '<cmd>m .+1<CR>==', o)
map('n', '<A-k>', '<cmd>m .-2<CR>==', o)
map('v', '<A-j>', ":m '>+1<CR>gv=gv", o)
map('v', '<A-k>', ":m '<-2<CR>gv=gv", o)

-- keep the yank when pasting over a visual selection
map('v', 'p', '"_dP', o)

-- terminal
map('t', '<Esc>', [[<C-\><C-n>]], o)

-- diagnostics: built-in instead of lspsaga, using the Nvim 0.11+ API
map('n', '<C-j>',   function() vim.diagnostic.jump({ count =  1, float = true }) end,
  { desc = 'Next diagnostic' })
map('n', '<C-S-j>', function() vim.diagnostic.jump({ count = -1, float = true }) end,
  { desc = 'Previous diagnostic' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic' })
