# dotfiles

my mac config, managed with stow.

## layout

each folder is a stow package. target is ~/.config (see .stowrc).

	ghostty/ghostty/config  >  ~/.config/ghostty/config

it's nested one level deeper than you'd expect. that's because stow mirrors
the target path, and the target here is ~/.config, not $HOME.

## deploy

	brew install stow
	stow ghostty

or deploy everything at once with `stow */`. run `stow -n -v <package>` first
if you want to see what it would do before it actually does it.

## adding a package

make a folder named after the tool, nest the config so it lands where it
should under ~/.config, then stow it.
