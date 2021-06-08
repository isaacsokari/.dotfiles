" :W sudo saves the file when the file is open in readonly mode
command W w !sudo tee % > /dev/null

""""""""""""""""""""""""""""""""""""
" Line
""""""""""""""""""""""""""""""""""""
" show line numbers
" set number
" show relative line numbers 
set rnu

"""""""""""""""""""""""""""""""""""""
" set scrolloff to auto scroll
set scrolloff=10

"""""""""""""""""""""""""""""""""""""
" Indents
""""""""""""""""""""""""""""""""""""
" replace tabs with spaces
set expandtab

" 1 tab = 2 spaces
set tabstop=2 shiftwidth=2

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
set hlsearch

" " highlight all pattern matches WHILE typing the pattern
set incsearch

"""""""""""""""""""""""""""""""""""""
" Mix
"""""""""""""""""""""""""""""""""""""
" show the mathing brackets

set showmatch

"
" highlight current line
set cursorline

" space open/closes folds
nnoremap <space> za

" fold based on indent level
set foldmethod=indent   

" enable modelines for file-specific settings
" 1 means it'll be at the bottom of the file
set modelines=1
