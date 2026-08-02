# dotfiles

my mac config, managed with stow.

## layout

each folder is a package, one dotfile per folder, flat, no nesting.

	ghostty/config       >  ~/.config/ghostty/config
	git/config           >  ~/.config/git/config
	git/ignore           >  ~/.config/git/ignore
	nvim/...             >  ~/.config/nvim/...
	atuin/config.toml    >  ~/.config/atuin/config.toml
	gh-dash/config.yml   >  ~/.config/gh-dash/config.yml
	starship/starship.toml  >  ~/.config/starship.toml
	zsh/.zshrc           >  ~/.zshrc
	vim/.vimrc           >  ~/.vimrc

each package needs its own target, since they don't all land in the same
place. ghostty, git, nvim, atuin, and gh-dash each get their own folder
under ~/.config. starship's file sits right in ~/.config with no
subfolder. zsh and vim have no XDG spot at all, so they target $HOME
directly.

atuin also needs `eval "$(atuin init zsh)"` in .zshrc (already there) to
actually hook into the shell — the config.toml alone doesn't do that.

gh-dash is a `gh` CLI extension, not a standalone install — it needs
`gh extension install dlvhdr/gh-dash` once, separate from stow.

vim-plug (the plugin manager .vimrc bootstraps) and the plugins it
installs live at ~/.vim/autoload and ~/.vim/plugged — real downloaded
code, not dotfiles, so they stay out of git same as tmux's plugins did.

## deploy

	brew install stow
	./deploy.sh

that runs stow once per package with the right target. to do it by hand,
or to deploy just one package:

	stow -t ~/.config/ghostty ghostty
	stow -t ~/.config/git git
	stow -t ~/.config/nvim nvim
	stow -t ~/.config/atuin atuin
	stow -t ~/.config/gh-dash gh-dash
	stow -t ~/.config starship
	stow -t ~ zsh
	stow -t ~ vim

add `-n -v` to any of those to preview what it would do first.

## adding a package

make a folder named after the tool, put its file(s) in flat with no extra
nesting, then add a line to deploy.sh with the right target (the folder
that would directly contain those files once deployed).
