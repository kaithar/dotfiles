syntax on
color slate
nmap <silent> <C-N> :silent noh<LF>
set clipboard=autoselect,exclude:cons\|linux\|screen\|xterm
set formatoptions+=cql
set showbreak=@
set sw=4 ts=4 sta si ai noet
filetype plugin indent on
autocmd FileType python set ts=4 sw=4 tw=80 formatoptions-=t
let python_highlight_space_errors = 1
set modeline

" Make ctrl-arrow keys work with more terms
" urxvt
map <esc>Od b
map <esc>Oc w
imap <esc>Od <C-O>b
imap <esc>Oc <C-O>w

set expandtab

set tags+=./tags;/
