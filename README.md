# dotfiles

my mac config, managed with stow.

## layout

each folder is a stow package. target is ~/.config (see .stowrc), except zsh
which targets $HOME directly (there's no XDG spot for .zshrc without extra
setup, so it just gets a target override at deploy time).

	ghostty/ghostty/config    >  ~/.config/ghostty/config
	git/git/config            >  ~/.config/git/config
	git/git/ignore            >  ~/.config/git/ignore
	nvim/nvim/...             >  ~/.config/nvim/...
	starship/starship.toml    >  ~/.config/starship.toml
	zsh/.zshrc                >  ~/.zshrc  (target override, see below)

nesting depth follows where the live file actually sits. a tool with its own
subfolder under ~/.config (ghostty, git, nvim) gets double nested, package
name repeated once. a tool whose file sits right in ~/.config with no
subfolder (starship) does not.

## deploy

	brew install stow
	stow ghostty git nvim starship
	stow -t ~ zsh

or dry run first with `stow -n -v <package>` to see what it would do before
it does it.

## adding a package

make a folder named after the tool, nest the config so it lands where it
should under ~/.config, then stow it. if the tool's config doesn't live
under ~/.config, give it a target override like zsh has.
