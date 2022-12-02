local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.g.mapleader = ' '

-- increment/decrement
map('n', '+', '<C-a>')
map('n', '-', '<C-x>')

-- select all
map('n', '<C-a>', 'gg<S-v>G')

-- split window
map('n', 'ss', ':split<Return><C-w>w')
map('n', 'sv', ':vsplit<Return><C-w>w')

-- move window
map('n', 'sh', '<C-w>h')
map('n', 'sk', '<C-w>k')
map('n', 'sj', '<C-w>j')
map('n', 'sl', '<C-w>l')

-- sesize window
map('n', '<C-w><left>', '<C-w><')
map('n', '<C-w><right>', '<C-w>>')
map('n', '<C-w><up>', '<C-w>+')
map('n', '<C-w><down>', '<C-w>-')

-- clear search
map('n', '<A-s>', ':set hlsearch!<CR>')

-- save, quit and reload
map('n', '<leader>r', ':so %<CR>') -- Reload configuration without restart nvim
map('n', '<leader>s', ':w<CR>')
map('n', '<leader>q', ':qa!<CR>')

-- tree
map('n', '<leader>t', ':NvimTreeToggle<cr>')

-- undo
map('n', '<C-z>', 'u')
map('i', '<C-z>', '<C-o>u')
map('v', '<C-z>', '<esc>u')

-- redo
map('i', '<C-r>', "<C-o><C-r>")

-- tab 
map('n', '<leader>n', ':tabnew<CR>')
map('n', "<Tab>", ":tabn<CR>")
map('n', "<S-Tab>", ":tabp<CR>")
map('n', "<leader>1", "1gt<CR>")
map('n', "<leader>2", "2gt<CR>")
map('n', "<leader>3", "3gt<CR>")
map('n', "<leader>4", "4gt<CR>")
map('n', "<leader>5", "5gt<CR>")
map('n', "<leader>6", "6gt<CR>")
map('n', "<leader>7", "7gt<CR>")
map('n', "<leader>8", "8gt<CR>")
map('n', "<leader>9", "9gt<CR>")
map('n', "<leader><Tab>", "g<tab><CR>")

-- telescope
map('n', 'ff', "<cmd>lua require('telescope.builtin').find_files({no_ignore = false,  hidden = true})<cr>")
map('n', "fb", "<cmd>lua require('telescope.builtin').buffers(require('telescope.themes').get_dropdown{previewer = false})<cr>")
map('n', 'fg', "<cmd>lua require'telescope.builtin'.live_grep()<cr>")
map('n', 'fh', "<cmd>lua require'telescope.builtin'.help_tags()<cr>")
map('n', 'fd', "<cmd>lua require'telescope.builtin'.diagnostics()<cr>")
map('n', 'fw', "<cmd>lua require('telescope').extensions.git_worktree.git_worktrees()<CR>")
map('n', 'fc', "<cmd>lua require('telescope').extensions.git_worktree.create_git_worktree()<CR>")


-- zen mode
map('n', '<C-w>o', '<cmd>ZenMode<cr>')

-- press jk fast to enter
map('i', "jk", "<ESC>")

-- to move cursor ahead of brackets and quotes
map('i', "kj", "<right>")

-- stay in indent mode
map('v', "<", "<gv")
map('v', ">", ">gv")

-- navigate buffers
map('n', "<S-l>", ":bnext<CR>")
map('n', "<S-h>", ":bprevious<CR>")

-- move line up and down
map('n', "<A-j>", ":m .+1<CR>==") -- move line up(n)
map('n', "<A-k>", ":m .-2<CR>==") -- move line down(n)
map('v', "<A-j>", ":m '>+1<CR>gv=gv") -- move line up(v)
map('v', "<A-k>", ":m '<-2<CR>gv=gv") -- move line down(v)

map('v', "p", '"_dP') -- keep the yanked when pasting in visual mode
map('t', "<Esc>", [[<C-\><C-n>]]) -- esc exit terminal
