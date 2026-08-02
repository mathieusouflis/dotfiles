# dotfiles

my mac config, managed with stow.

## layout

each folder is a package, one dotfile per folder, flat, no nesting.

	ghostty/config       >  ~/.config/ghostty/config
	git/config           >  ~/.config/git/config
	git/ignore           >  ~/.config/git/ignore
	nvim/...             >  ~/.config/nvim/...
	tmux/tmux.conf       >  ~/.config/tmux/tmux.conf
	tmux/tmux.reset.conf >  ~/.config/tmux/tmux.reset.conf
	starship/starship.toml  >  ~/.config/starship.toml
	zsh/.zshrc           >  ~/.zshrc

each package needs its own target, since they don't all land in the same
place. ghostty, git, nvim, and tmux each get their own folder under
~/.config. starship's file sits right in ~/.config with no subfolder. zsh
has no XDG spot at all, so it targets $HOME directly.

tmux plugins are managed separately by TPM, not stow — see below.

## deploy

	brew install stow
	./deploy.sh

that runs stow once per package with the right target. to do it by hand,
or to deploy just one package:

	stow -t ~/.config/ghostty ghostty
	stow -t ~/.config/git git
	stow -t ~/.config/nvim nvim
	stow -t ~/.config/tmux tmux
	stow -t ~/.config starship
	stow -t ~ zsh

add `-n -v` to any of those to preview what it would do first.

## tmux plugins

one-time setup, not handled by stow:

	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	~/.tmux/plugins/tpm/bin/install_plugins

TPM notices the config lives under ~/.config/tmux and installs the actual
plugins there too (~/.config/tmux/plugins/), not under ~/.tmux/plugins/.
that's TPM's own doing, not something this repo manages — it's real
downloaded plugin code, not dotfiles, so it stays out of git.

## adding a package

make a folder named after the tool, put its file(s) in flat with no extra
nesting, then add a line to deploy.sh with the right target (the folder
that would directly contain those files once deployed).
