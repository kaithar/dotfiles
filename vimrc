" Only needed if you are aren't putting this file at ~/.vimrc
set nocompatible

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
