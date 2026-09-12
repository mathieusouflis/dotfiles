" Netrw: show hidden/dot files by default
let g:netrw_hide = 0

if executable('rg')
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden
  set grepformat=%f:%l:%c:%m
endif

set mouse=a
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

" 2-space soft tabs, same as everywhere else in the toolchain
set expandtab
set tabstop=2
set shiftwidth=2
set softtabstop=2

" GUI vim only (Geist Mono, matching every other tool's font), no effect in terminal vim
set guifont=Geist\ Mono:h17

" Horizontal (not vertical) splits when diffing
set diffopt+=horizontal

" Block cursor in normal/visual, bar in insert, underline in replace, all blinking
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


" LSP (yegappan/lsp, plugged below)
let g:lspServers = [
    \ {
    \   'name': 'clangd',
    \   'filetype': ['c', 'cpp'],
    \   'path': 'clangd',
    \   'args': ['--background-index', '--clang-tidy', '--header-insertion=iwyu', '--completion-style=detailed', '--function-arg-placeholders']
    \ },
    \ {
    \   'name': 'csharp-ls',
    \   'filetype': ['cs'],
    \   'path': 'csharp-ls',
    \   'args': []
    \ },
    \ {
    \   'name': 'lua_ls',
    \   'filetype': ['lua'],
    \   'path': 'lua-language-server',
    \   'args': []
    \ },
    \ {
    \   'name': 'marksman',
    \   'filetype': ['markdown'],
    \   'path': 'marksman',
    \   'args': ['server']
    \ },
    \ {
    \   'name': 'typescript-language-server',
    \   'filetype': ['javascript', 'javascriptreact', 'typescript', 'typescriptreact'],
    \   'path': 'typescript-language-server',
    \   'args': ['--stdio']
    \ },
    \ {
    \   'name': 'gopls',
    \   'filetype': ['go', 'gomod', 'gowork', 'gotmpl'],
    \   'path': 'gopls',
    \   'args': []
    \ },
    \ {
    \   'name': 'rust-analyzer',
    \   'filetype': ['rust'],
    \   'path': 'rust-analyzer',
    \   'args': []
    \ },
    \ {
    \   'name': 'terraform-ls',
    \   'filetype': ['terraform', 'hcl'],
    \   'path': 'terraform-ls',
    \   'args': ['serve']
    \ },
    \ {
    \   'name': 'docker-langserver',
    \   'filetype': ['dockerfile'],
    \   'path': 'docker-langserver',
    \   'args': ['--stdio']
    \ },
    \ {
    \   'name': 'yaml-language-server',
    \   'filetype': ['yaml'],
    \   'path': 'yaml-language-server',
    \   'args': ['--stdio']
    \ },
    \ {
    \   'name': 'ansible-language-server',
    \   'filetype': ['yaml.ansible'],
    \   'path': 'ansible-language-server',
    \   'args': ['--stdio']
    \ },
    \ {
    \   'name': 'helm_ls',
    \   'filetype': ['helm'],
    \   'path': 'helm_ls',
    \   'args': ['serve']
    \ },
    \ {
    \   'name': 'ocamllsp',
    \   'filetype': ['ocaml', 'ocaml.interface', 'ocaml.menhir', 'dune'],
    \   'path': 'ocamllsp',
    \   'args': []
    \ }
    \ ]

autocmd User LspSetup call g:LspAddServer(g:lspServers)

" Bootstrap vim-plug if not installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Plugins
call plug#begin('~/.vim/plugged')
  Plug 'version14/vim-theme', { 'as': 'version14' }
  Plug 'leafgarland/typescript-vim'
  Plug 'peitalin/vim-jsx-typescript'
  Plug 'yegappan/lsp'
  Plug 'sgur/vim-editorconfig'
  Plug 'rust-lang/rust.vim'
  Plug 'fatih/vim-go'
  Plug 'pearofducks/ansible-vim'
  Plug 'towolf/vim-helm'
  Plug 'hashivim/vim-terraform'
  Plug 'rgrinberg/vim-ocaml'
call plug#end()

" vim-go: syntax/indent only -- LSP is handled uniformly above via gopls
let g:go_gopls_enabled = 0
let g:go_fmt_autosave = 0

" Apply the theme (pinned to dark -- without this, the colorscheme falls
" back to &background's auto-detected value, which isn't reliably dark)
let g:version14_style = 'dark'
colorscheme version14
