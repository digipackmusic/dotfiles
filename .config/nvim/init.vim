" NeoVim configuration file
" Luke English <luke@ljenglish.net>
"
" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Make sure you use single quotes 

" GTD
Plug 'phb1/gtd.vim'

" Airline
Plug 'vim-airline/vim-airline'

" NERDTree
Plug 'scrooloose/nerdtree'

" LustyExplorer
Plug 'sjbach/lusty'

" Ack.vim
Plug 'mileszs/ack.vim'

" Ctrl-P
Plug 'kien/ctrlp.vim'

" Syntastic
Plug 'vim-syntastic/syntastic'

" Vimtex 
Plug 'lervag/vimtex' 

" Neosnippet (needs deoplete) 
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
let g:deoplete#enable_at_startup = 1

Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neosnippet-snippets'

call plug#end()

"" Airline settings
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_powerline_fonts = 1
let g:airline_symbols.linenr = ''
let g:airline_symbols.maxlinenr = ''
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#whitespace#enabled = 0 " turn off the whitespace extension
set noshowmode

"" Syntax enable!
syntax enable

"" Tab functionality
filetype plugin indent on
set tabstop=4
set shiftwidth=4
set expandtab

"" Display
set title
set number
set ruler
set wrap
set scrolloff=3

"" Search
set ignorecase
set smartcase   " searches case sensitive when uppercase is present in term
set incsearch
set hlsearch
" Unset the last search pattern register 
nnoremap <CR> :noh<CR><CR>

"" Backspace behaviour
set backspace=indent,eol,start

"" Remap <Esc>
inoremap jk <Esc>

"" Leader
let mapleader = ','
let maplocalleader = ',' " I don't have enough plugins for this to matter yet.

"" Lusty Explorer
set hidden

"" Ack.vim
let g:ackprg='ack -H --nocolor --nogroup --column'
" Add mark and search
nmap <Leader>j mA:Ack<space>
" Add mark and search at point
nmap <Leader>ja mA:Ack "<C-r>=expand("<cword>")<cr>"
nmap <Leader>jA mA:Ack "<C-r>=expand("<cWORD>")<cr>"

"" GTD.vim
let g:gtd#default_context = 'uni'
let g:gtd#default_action = 'inbox'
let g:gtd#dir = '~/gtd'

"" Deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_smart_case = 1

"" Neosnippet
" Plugin key-mappings.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)
smap <C-k>     <Plug>(neosnippet_expand_or_jump)
xmap <C-k>     <Plug>(neosnippet_expand_target)

" SuperTab like snippets behavior.
" Note: It must be "imap" and "smap".  It uses <Plug> mappings.
"imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

"" Syntastic
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_tex_checkers=['chktex']
