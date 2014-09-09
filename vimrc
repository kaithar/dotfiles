" Only needed if you are aren't putting this file at ~/.vimrc
set nocompatible
set encoding=utf-8

"" Basic Config
set number                      " line numbers (number|nonumber)
set ruler                       " show the cursor position all the time
set cursorline                  " highlight the line of the cursor
set showcmd                     " display incomplete commands
set showmode                    " show current mode down the bottom ??

set history=200                 " remember more Ex commands
set scrolloff=3                 " have some context around the current line always on screen

set autoread                    " reload files changed outside vim

" Allow backgrounding buffers without writing them, and remember marks/undo
" " for backgrounded buffers
set hidden

" List chars ??
set list                        " Show invisible characters
set listchars=""                " Reset the listchars
set listchars=tab:\ \           " a tab should display as "  ", trailing whitespace as "."
set listchars+=trail:.          " show trailing spaces as dots
set listchars+=extends:>        " The character to show in the last column when wrap is
                                " off and the line continues beyond the right of the screen
set listchars+=precedes:<       " The character to show in the first column when wrap is
                                " off and the line continues beyond the left of the screen

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

if has("autocmd")
  " In Makefiles, use real tabs, not tabs expanded to spaces
  au FileType make set noexpandtab

  " Make sure all markdown files have the correct filetype set and setup wrapping
  au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn,txt} setf markdown | call s:setupWrapping()

  " Treat JSON files like JavaScript
  au BufNewFile,BufRead *.json set ft=javascript

  " Remember last location in file, but not for commit messages.
  " see :help last-position-jump
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"" | endif

  " mark Jekyll YAML frontmatter as comment
  au BufNewFile,BufRead *.{md,markdown,html,xml} sy match Comment /\%^---\_.\{-}---$/

  " Start with NerdTree if opened with a directory
  au vimenter * if !argc() | NERDTree | endif

  " Close vim if last buffer is NerdTree
  au bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif
endif

nmap ,n :NERDTreeClose<CR>:NERDTreeToggle<CR>
let NERDTreeIgnore=[ '\.pyc$', '\.pyo$', '\.py\$class$', '\.obj$',
            \ '\.o$', '\.so$', '\.egg$', '^\.git$', '\.os$', '\.dylib$', '\.a$',
            \ '\.DS_Store$', '\.bundle$', '\.gitkeep$']
let NERDTreeShowFiles=1           " Show hidden files, too
let NERDTreeShowHidden=1

" ignore Rubinius, Sass cache files
set wildignore+=tmp/**,*.rbc,.rbx,*.scssc,*.sassc

" find merge conflict markers
nmap <silent> <leader>cf <ESC>/\v^[<=>]{7}( .*\|$)<CR>

command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>

" easier navigation between split windows
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l

set backupdir=~/.vim/backup     " where to put backup files.
set directory=~/.vim/tmp        " where to put swap files.
set undodir=~/.vim/undos        " where to put undo files
set undofile

if has("statusline") && !&cp
  set laststatus=2  " always show the status bar

  " Start the status line
  set statusline=%f\ %m\ %r

  " Add fugitive
  "set statusline+=%{fugitive#statusline()}

  " Finish the statusline
  set statusline+=Line:%l/%L\ [%p%%]
  set statusline+=\ Col:%v
  set statusline+=\ Buf:#%n
  set statusline+=\ [%b][0x%B]
endif


syntax on
color slate
nmap <silent> <C-N> :silent noh<LF>
set clipboard=autoselect,exclude:cons\|linux\|screen\|xterm
set formatoptions+=cql
set showbreak=@
set sw=4 ts=4 sta si ai noet
filetype plugin indent on
autocmd FileType java set tw=80 cindent ts=4 sw=4
autocmd FileType python set ts=4 sw=4 tw=80 formatoptions-=t
autocmd FileType c set ts=4 sw=4 formatoptions+=t formatoptions-=l
autocmd FileType cpp set ts=4 sw=4 formatoptions+=t formatoptions-=l
let python_highlight_space_errors = 1
set modeline

" Make ctrl-arrow keys work with more terms
" urxvt
map <esc>Od b
map <esc>Oc w
imap <esc>Od <C-O>b
imap <esc>Oc <C-O>w
" xterm
map <esc>[1;5D b
map <esc>[1;5C w
imap <esc>[1;5D <C-O>b
imap <esc>[1;5C <C-O>w
" gnome-terminal
map <esc>O5D b
map <esc>O5C w
imap <esc>O5D <C-O>b
imap <esc>O5C <C-O>w
" iterm
map <esc>[5D b
map <esc>[5C w
imap <esc>[5D <C-O>b
imap <esc>[5C <C-O>w

set expandtab

set tags+=./tags;/
" vim: set ft=vim noet tw=78 ai :
