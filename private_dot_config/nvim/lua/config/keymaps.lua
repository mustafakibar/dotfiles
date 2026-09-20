-- ~/.config/nvim/lua/config/keymaps.lua
-- Eski lua/maps.lua'nın karşılığı. Leader init.lua'da ayarlanır.
local map = vim.keymap.set
local o = { noremap = true, silent = true }

-- artır / azalt
map('n', '+', '<C-a>', o)
map('n', '-', '<C-x>', o)

-- tümünü seç
map('n', '<C-a>', 'gg<S-v>G', o)

-- pencere bölme
map('n', 'ss', '<cmd>split<CR><C-w>w', o)
map('n', 'sv', '<cmd>vsplit<CR><C-w>w', o)

-- pencereler arası geçiş
map('n', 'sh', '<C-w>h', o)
map('n', 'sj', '<C-w>j', o)
map('n', 'sk', '<C-w>k', o)
map('n', 'sl', '<C-w>l', o)

-- pencere boyutlandırma
map('n', '<C-w><Left>',  '<C-w><', o)
map('n', '<C-w><Right>', '<C-w>>', o)
map('n', '<C-w><Up>',    '<C-w>+', o)
map('n', '<C-w><Down>',  '<C-w>-', o)

-- arama vurgusu
map('n', '<A-s>', '<cmd>set hlsearch!<CR>', o)

-- kaydet / çık / yeniden yükle
map('n', '<leader>r', '<cmd>source %<CR>', { desc = 'Dosyayı kaynak olarak yükle' })
map('n', '<leader>s', '<cmd>w<CR>',        { desc = 'Kaydet' })
map('n', '<leader>q', '<cmd>qa!<CR>',      { desc = 'Hepsini kapat' })

-- geri al / yinele
map('n', '<C-z>', 'u', o)
map('i', '<C-z>', '<C-o>u', o)
map('v', '<C-z>', '<Esc>u', o)
map('i', '<C-r>', '<C-o><C-r>', o)

-- sekmeler
map('n', '<leader>n', '<cmd>tabnew<CR>', { desc = 'Yeni sekme' })
map('n', '<Tab>',   '<cmd>tabnext<CR>', o)
map('n', '<S-Tab>', '<cmd>tabprevious<CR>', o)
for i = 1, 9 do
  -- Eski config '1gt<CR>' yazıyordu; sondaki <CR> hatalıydı (fazladan Enter).
  map('n', '<leader>' .. i, i .. 'gt', o)
end
map('n', '<leader><Tab>', 'g<Tab>', o)

-- hızlı Esc / imleci ilerlet
map('i', 'jk', '<Esc>', o)
map('i', 'kj', '<Right>', o)

-- girinti modunda kal
map('v', '<', '<gv', o)
map('v', '>', '>gv', o)

-- buffer gezinme
map('n', '<S-l>', '<cmd>bnext<CR>', o)
map('n', '<S-h>', '<cmd>bprevious<CR>', o)

-- satır taşıma
map('n', '<A-j>', '<cmd>m .+1<CR>==', o)
map('n', '<A-k>', '<cmd>m .-2<CR>==', o)
map('v', '<A-j>', ":m '>+1<CR>gv=gv", o)
map('v', '<A-k>', ":m '<-2<CR>gv=gv", o)

-- görsel modda yapıştırırken yank'i koru
map('v', 'p', '"_dP', o)

-- terminal
map('t', '<Esc>', [[<C-\><C-n>]], o)

-- tanılama (lspsaga yerine yerleşik — Nvim 0.11+ API'si)
map('n', '<C-j>',   function() vim.diagnostic.jump({ count =  1, float = true }) end,
  { desc = 'Sonraki tanılama' })
map('n', '<C-S-j>', function() vim.diagnostic.jump({ count = -1, float = true }) end,
  { desc = 'Önceki tanılama' })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Tanılamayı göster' })
