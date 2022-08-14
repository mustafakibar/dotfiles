call plug#begin()
	Plug 'ryanoasis/vim-devicons'
	Plug 'morhetz/gruvbox'
	Plug 'junegunn/vim-emoji'
	Plug 'mg979/vim-visual-multi', {'branch': 'master'}
	Plug 'sheerun/vim-polyglot'
  Plug 'windwp/nvim-autopairs'	
	Plug 'ap/vim-css-color'
	Plug 'preservim/nerdtree'
	Plug 'kien/ctrlp.vim'
	Plug 'tpope/vim-surround'
	Plug 'neoclide/coc.nvim', {'branch': 'release'}
	Plug 'plasticboy/vim-markdown'
	Plug 'airblade/vim-gitgutter'
	Plug 'nvim-lualine/lualine.nvim'
	Plug 'kyazdani42/nvim-web-devicons'
	Plug 'neovim/nvim-lspconfig'
  Plug 'jose-elias-alvarez/null-ls.nvim'
  Plug 'MunifTanjim/prettier.nvim'
	Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
	Plug 'nvim-treesitter/nvim-treesitter'
	Plug 'windwp/nvim-ts-autotag'
	Plug 'norcalli/nvim-colorizer.lua'
	Plug 'akinsho/bufferline.nvim'
call plug#end()

filetype plugin indent on
syntax on

set termguicolors
set background=dark
set clipboard=unnamedplus
set completeopt=noinsert,menuone,noselect
set cursorline
set hidden
set inccommand=split
set mouse=a
set number
set relativenumber
set splitbelow splitright
set title
set ttimeoutlen=0
set wildmenu
set hlsearch!

set expandtab
set shiftwidth=2
set tabstop=2

lua << EOF
require'nvim-treesitter.configs'.setup{}

require'colorizer'.setup()

require('nvim-ts-autotag').setup()

require("nvim-autopairs").setup {}

require('lualine').setup{
  options = {
    icons_enabled = true,
    theme = 'gruvbox',
		section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    disabled_filetypes = {},
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = { {
      'filename',
      file_status = true, -- displays file status (readonly status, modified status)
      path = 0 -- 0 = just filename, 1 = relative path, 2 = absolute path
    } },
    lualine_x = {
      { 'diagnostics', sources = { "nvim_diagnostic" }, symbols = { error = ' ', warn = ' ', info = ' ',
        hint = ' ' } },
      'encoding',
      'filetype'
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { {
      'filename',
      file_status = true, -- displays file status (readonly status, modified status)
      path = 1 -- 0 = just filename, 1 = relative path, 2 = absolute path
    } },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = { 'fugitive' }
}
EOF

let term_program = $TERM_PROGRAM
if term_program !=? 'Apple_Terminal'
	set termguicolors
else
	if $TERM !=? 'xterm-256color'
		set termguicolors
	endif
endif

colorscheme gruvbox

let &t_ZH = "\e[3m"
let &t_ZR = "\e[23m"
let NERDTreeShowHidden = 1

let g:vim_markdown_conceal = 0
let g:vim_markdown_fenced_languages = ['tsx=typescriptreact']
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_frontmatter = 1

let g:tex_conceal = ''
let g:vim_markdown_math = 1

let g:python3_host_prog = '/usr/bin/python'
command! -nargs=0 Prettier :call CocAction('runCommand', 'prettier.formatFile')

let mapleader = ','
nnoremap <C-q> :q!<CR>
nnoremap <F3> :set hlsearch!<CR>
nnoremap <F4> :bd<CR>
nnoremap <F5> :NERDTreeToggle<CR>
nnoremap <F6> :sp<CR>:terminal<CR>
nnoremap <F10> :CocCommand tsserver.organizeImports<CR>
noremap <c-s-up> :call feedkeys( line('.')==1 ? '' : 'ddkP' )<CR>
noremap <c-s-down> ddp
nnoremap n nzz
nnoremap N Nzz
nnoremap Y y$
nnoremap Q <nop>
nnoremap ; :
nnoremap <C-s> :w<CR>    
inoremap <C-u> <ESC>ui
vnoremap <C-p> "+p
nnoremap <a-right> gt
nnoremap <a-left>  gT
inoremap <> <><Left>
inoremap () ()<Left>
inoremap {} {}<Left>
inoremap [] []<Left>
inoremap "" ""<Left>
inoremap '' ''<Left>
inoremap `` ``<Left>
imap <Up>    <Nop>
imap <Down>  <Nop>
imap <Left>  <Nop>
imap <Right> <Nop>
inoremap <C-k> <Up>
inoremap <C-j> <Down>
inoremap <C-h> <Left>
inoremap <C-l> <Right>
nmap <Up>    <Nop>
nmap <Down>  <Nop>
nmap <Left>  <Nop>
nmap <Right> <Nop>
nnoremap <S-Tab> gT
nnoremap <silent> <S-t> :tabnew<CR>

inoremap <silent><expr> <C-n> coc#pum#visible() ? coc#pum#next(1) : "\<C-n>"
inoremap <silent><expr> <C-p> coc#pum#visible() ? coc#pum#prev(1) : "\<C-p>"
inoremap <silent><expr> <down> coc#pum#visible() ? coc#pum#next(0) : "\<down>"
inoremap <silent><expr> <up> coc#pum#visible() ? coc#pum#prev(0) : "\<up>"
inoremap <silent><expr> <PageDown> coc#pum#visible() ? coc#pum#scroll(1) : "\<PageDown>"
inoremap <silent><expr> <PageUp> coc#pum#visible() ? coc#pum#scroll(0) : "\<PageUp>"
inoremap <silent><expr> <C-e> coc#pum#visible() ? coc#pum#cancel() : "\<C-e>"
inoremap <silent><expr> <Tab> coc#pum#visible() ? coc#pum#confirm() : "\<C-y>"
