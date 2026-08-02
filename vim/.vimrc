" Netrw: show hidden/dot files by default
let g:netrw_hide = 0

" Use ripgrep for :grep
if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
  set grepformat=%f:%l:%c:%m
endif

set autoindent
set autoread
set hlsearch
set incsearch
set ignorecase
set number
set relativenumber
set showmatch
set smartcase
set smartindent
set smarttab
set cc=80
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
set termguicolors
syntax on
set regexpengine=1
set lazyredraw
set synmaxcol=200

" Indentation (tab_size: 2, hard_tabs: false)
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2

" Font for GUI Vim (buffer_font_family: Geist Mono, size 15)
set guifont=Geist\ Mono:h15

" Diff (diff_view_style: unified)
set diffopt+=horizontal

" Cursor (cursor_shape: hollow block, cursor_blink: true)
set guicursor=n-v-c:block-blinkwait700-blinkon400-blinkoff250,i-ci-ve:ver25-blinkwait700-blinkon400-blinkoff250,r-cr:hor20-blinkwait700-blinkon400-blinkoff250
let &t_SI = "\e[5 q"
let &t_EI = "\e[1 q"
let &t_SR = "\e[3 q"


augroup vimrc_filetype
  autocmd!
  autocmd FileType make setlocal noexpandtab
  autocmd FileType vim setlocal foldmethod=marker
  autocmd FileType c,cpp set comments=sl:/**,mb:\ *,ex:\ */
  autocmd FileType python nnoremap <F5> :w<bar>!python %<CR>
  autocmd FileType cpp nnoremap <F5> :w<bar>term ++shell g++ %:p -o %:p:r -g -fsanitize=address; %:p:r<CR>
  autocmd FileType rust nnoremap <F5> :w<bar>!cargo run<CR>
  autocmd FileType rust nnoremap <F6> :w<bar>!cargo check<CR>
augroup END



" Bootstrap vim-plug si pas installé
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Plugins
call plug#begin('~/.vim/plugged')
  Plug 'rose-pine/vim', { 'as': 'rose-pine' }
  Plug 'leafgarland/typescript-vim'
  Plug 'peitalin/vim-jsx-typescript'
call plug#end()

" Appliquer le thème
colorscheme rosepine
