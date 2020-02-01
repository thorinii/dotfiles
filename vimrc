set nocompatible
set runtimepath+=/usr/share/lilypond/2.18.2/vim/

call plug#begin('~/.vim/plugged')
" plugins

" system
Plug 'w0rp/ale'

" languages
Plug 'digitaltoad/vim-pug'
Plug 'pangloss/vim-javascript'
Plug 'matze/vim-lilypond'

" UI
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-commentary'
Plug 'kien/ctrlp.vim'
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/goyo.vim'
Plug 'whatyouhide/vim-lengthmatters'
Plug 'tpope/vim-surround'

if !has('nvim')
  Plug 'tpope/vim-sensible'
endif

" themes
Plug 'glortho/feral-vim'
Plug 'NLKNguyen/papercolor-theme'


" end plugins
call plug#end()


set t_Co=256
syntax on
set background=dark


"
" Core
"

" Backspace is managed by vim-sensible, but I need it here too because some
" plugins depend on it during start up.
set backspace=indent,eol,start
" Enable line numbers.
set number

" Enable invisible characters.
set list
" More natural splitting.
set splitbelow
set splitright
" Set a default indent, but vim-sleuth should adjust it.
set tabstop=2
set shiftwidth=2
set expandtab
" Disable swap files.
set noswapfile
" Write files as they are, don't mess with line endings etc.
set binary
" Disable the completion preview window.
set completeopt-=preview
" Make session files minimal.
set sessionoptions=blank,curdir,folds,help,tabpages,winsize
" Hide buffers instead of closing them
set hidden

inoremap jk <esc>
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk

let mapleader = "\<Space>"

nnoremap <Leader>o :CtrlP<CR>
nnoremap <Leader>w :w<CR>

vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P

nnoremap <F5> :Goyo<CR>

nnoremap <Leader>/ :Commentary<CR>
vnoremap <Leader>/ :Commentary<CR>

nnoremap <Leader>e :b#<CR>
nnoremap <Leader>. :nohlsearch<CR>

" splitting lines (inverse of J)
nnoremap K i<CR><Esc>l


" Trim the trailing white space from the file.
function! s:trim_trailing_whitespace()
  %s/\s\+$//e
endfunction

nnoremap <silent> <leader>cw :call <SID>trim_trailing_whitespace()<CR>


set wildignore+=*/node_modules/*

"
" Highlighting
"

" Highlight searches.
set hlsearch

" Highlight the current line.
set cursorline

function! s:after_colorscheme()
  " Make spelling problems easier to read.
  highlight clear SpellBad
  highlight clear SpellCap
  highlight clear SpellLocal
  highlight clear SpellRare

  highlight SpellBad cterm=underline
  highlight SpellCap cterm=underline
  highlight SpellLocal cterm=underline
  highlight SpellRare cterm=underline

  " Stop the cross hair ruining highlighting.
  " highlight CursorLine cterm=NONE ctermbg=235 ctermfg=NONE guibg=#3a3a3a guifg=NONE
  " highlight CursorColumn cterm=NONE ctermbg=235 ctermfg=NONE guibg=#3a3a3a guifg=NONE

  " Make conceal look better.
  highlight Conceal cterm=bold ctermbg=NONE ctermfg=67
endfunction

augroup after_colorscheme
  autocmd!
  autocmd ColorScheme * call s:after_colorscheme()
augroup END

" Make search case insensitive, but become sensitive if an upper case
" character is used.
set ignorecase
set smartcase


"
" Vim Javascript config
"

set conceallevel=1
set concealcursor=nc

let g:javascript_conceal_function = "λ"
" let g:javascript_conceal_arrow_function = "⇒"
let g:javascript_conceal_null = "ø"
let g:javascript_conceal_undefined = "¿"

let g:syntastic_javascript_checkers = ['standard']


"
" Perf
"

" Send more characters to the terminal at once.
" Makes things smoother, will probably be enabled by my terminal anyway.
set ttyfast

" Stops macros rendering every step.
set lazyredraw


"
" Undo
"

" Enable persistent undo.
set undofile
set undodir=~/.vim/undo
set undolevels=1000
set undoreload=10000


"
" Random
"

let g:syntastic_check_on_open=1
let delimitMate_expand_cr=1
imap <C-c> <CR><Esc>O


let g:ctrlp_lazy_update = 100
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_max_files = 0

if executable("ag")
  let g:ctrlp_user_command = 'ag %s -i --nocolor --nogroup --ignore ''.git'' --ignore ''.DS_Store'' --ignore ''node_modules'' --hidden -g ""'
endif


" List all possible buffers with "gb" and accept a new buffer argument
nnoremap <Leader>b :ls<CR>:b


set expandtab


set mouse=a


"
" Vim Fugitive
"

nnoremap <silent> <leader>gs :<C-u>Gstatus<CR>
nnoremap <silent> <leader>gw :<C-u>Gwrite<CR>
nnoremap <silent> <leader>gc :<C-u>Gcommit<CR>
nnoremap <silent> <leader>gb :<C-u>Gblame<CR>
nnoremap <silent> <leader>gd :<C-u>Gdiff<CR>
nnoremap <silent> <leader>gj :<C-u>Gpull<CR>
nnoremap <silent> <leader>gk :<C-u>Gpush<CR>
nnoremap <silent> <leader>gf :<C-u>Gfetch<CR>


colorscheme PaperColor


autocmd Filetype gitcommit set textwidth=73
autocmd Filetype markdown set wrap linebreak nolist

if !has('nvim')
  set ttymouse=sgr
endif


" Command to wrap selected lines of code in braces
vmap <leader>{ >gvc{<CR><ESC>pkddk

set backupcopy=yes


" ALE linters to run
let g:ale_linters = {
\  'javascript': ['eslint'],
\}
let g:ale_fixers = {
\   'javascript': ['eslint'],
\}


let g:gitgutter_grep=''
set updatetime=300
