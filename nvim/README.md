# nvim

Neovim config, built on [LazyVim](https://github.com/LazyVim/LazyVim).
The real customization is in `lua/plugins/` (colorscheme, formatting,
go/opencode setup, C overrides) and `lazyvim.json`'s extras list -- see
LazyVim's own docs for how the base layer works.

`lua/plugins/c.lua` opts clangd out of Mason (`mason = false`) since
it's expected to come from each project's devenv shell instead.
