# vim

A plain, from-scratch `.vimrc` (vim-plug, not LazyVim) for when nvim
isn't the tool at hand -- its own Version 14 theme and per-language
LSP via [yegappan/lsp](https://github.com/yegappan/lsp) (`g:lspServers`
in `.vimrc`). Each language server binary (clangd, gopls,
rust-analyzer, etc.) has to be on `$PATH` some other way -- there's no
Mason-equivalent here, so install them via devenv/Homebrew/npm as
needed per project.
