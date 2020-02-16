if &compatible
  set nocompatible
endif

set backspace=indent,eol,start
set ruler
set suffixes+=.aux,.bbl,.blg,.brf,.cb,.dvi,.idx,.ilg,.ind,.inx,.jpg,.log,.out,.png,.toc
set suffixes-=.h
set suffixes-=.obj

" Helps force plug-ins to load correctly when it is turned back on below.
filetype off

" Turn on syntax highlighting.
syntax on

" Default indentation settings
set tabstop=4
set shiftwidth=4
set softtabstop=0
set noexpandtab
set noshiftround

set noro " prevent vimdiff to be read-only
set number

set encoding=utf-8

set hlsearch
filetype plugin indent on

let mapleader = ','

" colorscheme
highlight DiffAdd    cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffDelete cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffChange cterm=bold ctermfg=10 ctermbg=17 gui=none guifg=bg guibg=Red
highlight DiffText   cterm=bold ctermfg=10 ctermbg=88 gui=none guifg=bg guibg=Red
highlight QuickFixLine cterm=None ctermfg=White ctermbg=DarkBlue guifg=White guibg=DarkBlue
highlight Search cterm=None ctermfg=White ctermbg=DarkBlue guifg=White guibg=DarkBlue
set background=dark
set t_Co=256


" plug
call plug#begin()
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
Plug 'ctrlpvim/ctrlp.vim'
Plug 'scrooloose/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
Plug 'ajh17/VimCompletesMe'
call plug#end()


" vim-go
autocmd BufNewFile,BufRead *.go setlocal noexpandtab tabstop=4 shiftwidth=4 

let g:go_fmt_command = "goimports"
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_metalinter_autosave = 1
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

function! s:build_go_files()
	let l:file = expand('%')
	if l:file =~# '^\f\+_test\.go$'
		call go#test#Test(0, 1)
	elseif l:file =~# '^\f\+\.go$'
		call go#cmd#Build(0)
	endif
endfunction

autocmd FileType go nmap <leader>b :<C-u>call <SID>build_go_files()<CR>

" nerdtree
nmap <leader>t :NERDTreeToggle<CR>

" lightline.vim
set laststatus=2
let g:lightline = {
	\ 'colorscheme': 'seoul256',
	\ 'active': {
	\   'left': [ [ 'mode', 'paste' ],
	\             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
	\ },
	\ 'component_function': {
	\   'gitbranch': 'fugitive#head'
	\ },
	\ }

" vim-gitgutter
set updatetime=100

" yaml (no plugin)
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" LSP
nnoremap <F5> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>

let g:LanguageClient_serverCommands = {
  \ 'cpp': ['clangd'],
  \ 'c': ['clangd'],
  \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
  \ 'python': ['~/.local/bin/pyls'],
  \ }
