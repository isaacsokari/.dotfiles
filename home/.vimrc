" :W sudo saves the file when the file is open in readonly mode
command W w !sudo tee % > /dev/null

" Use system clipboard
set clipboard+=unnamed

""""""""""""""""""""""""""""""""""""
" Set leader key
""""""""""""""""""""""""""""""""""""
let mapleader = " "
let maplocalleader = " "

""""""""""""""""""""""""""""""""""""
" Line
""""""""""""""""""""""""""""""""""""
" show line numbers on current line instead of 0
set nu
" show relative line numbers 
set rnu

"""""""""""""""""""""""""""""""""""""
" set scrolloff to auto scroll
set scrolloff=10

"""""""""""""""""""""""""""""""""""""
" Indents
""""""""""""""""""""""""""""""""""""
" replace tabs with spaces
" set expandtab

" 1 tab = 2 spaces
set tabstop=2 softtabstop=2
set shiftwidth=2

set smartindent

" when deleting whitespace at the beginning of a line, delete 
" 1 tab worth of spaces (for us this is 2 spaces)
set smarttab

" when creating a new line, copy the indentation from the line above
set autoindent

"""""""""""""""""""""""""""""""""""""
" Search
"""""""""""""""""""""""""""""""""""""
" Ignore case when searching

set ignorecase
set smartcase

" " highlight search results (after pressing Enter)
set nohlsearch

" " highlight all pattern matches WHILE typing the pattern
set incsearch

"""""""""""""""""""""""""""""""""""""
" Mix
"""""""""""""""""""""""""""""""""""""
" show the mathing brackets

set showmatch

set showmode
set showcmd

" use visual bell instead of beeping
set visualbell

"
" highlight current line
set cursorline

"
" set insertmode cursor
set guicursor=n-v-c:block-Cursor
set guicursor+=i-ci:ver30-iCursor


" " space open/closes folds
" nnoremap <space> za

" fold based on indent level
set foldmethod=indent

" enable modelines for file-specific settings
" 1 means it'll be at the bottom of the file
set modelines=1

" set path
set path+=**

" Nice menu when typing `:find *.py`
set wildmode=longest,list,full
set wildmenu
" Ignore files
set wildignore+=*.pyc
set wildignore+=*_build/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/android/*
set wildignore+=**/ios/*
set wildignore+=**/.git/*


"""""""""""""""""""""""""""""""""""""
" Key Mappings
"""""""""""""""""""""""""""""""""""""

" Buffer navigation
nnoremap L :bnext<CR>
nnoremap H :bprev<CR>

" Easy window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <C-k> <C-w>k
nnoremap <C-j> <C-w>j


" Easy visual indentation
vnoremap < <gv
vnoremap > >gv
