# ~/.zprofile only loads for login shells, so brew goes on PATH here too.
# thefuck and fzf below both depend on it.
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

### OPTIONS ###
# keep this explicit: without it zsh reads $EDITOR, sees nvim, and starts in vi mode
bindkey -e
setopt auto_cd interactive_comments prompt_subst

### HISTORY ###
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history hist_expire_dups_first hist_ignore_dups
setopt hist_ignore_space hist_verify share_history

### COLORS ###
# eza (the ls/l aliases below, in ALIASES) reads $LS_COLORS, so it's set
# by hand here rather than left to a default.
#
# su/sg/tw/ow are badges: dark text on a bright block. They used to spell that
# as 30 (ANSI slot 0) over 4x, which only worked while slot 0 held a background
# colour -- now that it is a real text colour those badges would drop to
# 2.4-4.3:1, and in a light theme they would be worse still. 7 (reverse video)
# says the same thing without naming a colour: the terminal's own background
# becomes the foreground, so the badge stays legible in every variant.
autoload -U colors && colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=31;7:sg=36;7:tw=32;7:ow=33;7"

### COMPLETION ###
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# rebuild the dump once a day, otherwise -C reuses it and skips the slow audit
autoload -Uz compinit
zmodload -F zsh/stat b:zstat
zmodload zsh/datetime
_zcompdump="$HOME/.zcompdump"
if [[ -f "$_zcompdump" ]] && (( EPOCHSECONDS - $(zstat +mtime "$_zcompdump") < 86400 )); then
  compinit -C -d "$_zcompdump"
else
  compinit -d "$_zcompdump"
fi
unset _zcompdump
autoload -U +X bashcompinit && bashcompinit
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion zsh)
fi
if command -v terraform >/dev/null 2>&1; then
  complete -o nospace -C "$(command -v terraform)" terraform
fi

### KEYBINDS ###
# autosuggestions first: it defines the autosuggest-* widgets bound below
for plugin in \
  "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" \
  /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  if [ -r "$plugin" ]; then
    source "$plugin"
    break
  fi
done
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
bindkey jj vi-cmd-mode

### ENV ###
export LANG=en_US.UTF-8
export EDITOR="${EDITOR:-$(command -v hx || command -v nvim || command -v vim)}"
export DIRENV_LOG_FORMAT=""
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

export PATH="$PATH:$HOME/.local/bin"
if [ -d /opt/homebrew/opt/libpq/bin ]; then
  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
fi

# Go
export PATH="$PATH:$HOME/go/bin"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# jabba
[ -s "$HOME/.jabba/jabba.sh" ] && source "$HOME/.jabba/jabba.sh"

### ALIASES ###
alias cl='clear'
alias cls='clear'
alias grep='rg'
alias i3lock="pmset displaysleepnow"
alias restow="~/dotfiles/stow.sh"

# Eza
alias ls='eza --icons --git'
alias l='eza -la --icons --git'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons --git'

# Git
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpf="git push -f"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gsw='git switch'
alias gswc='git switch -c'
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'

# Docker
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

# K8S
alias k="kubectl"
alias ka="kubectl apply -f"
alias kg="kubectl get"
alias kd="kubectl describe"
alias kdel="kubectl delete"
alias kgpo="kubectl get pod"
alias kgd="kubectl get deployments"
alias kl="kubectl logs -f"
alias ke="kubectl exec -it"
alias kcns='kubectl config set-context --current --namespace'

# Mole (mac cleanup/uninstall/monitoring, https://github.com/tw93/mole)
alias mc="mo clean"
alias mu="mo uninstall"
alias mopt="mo optimize"
alias ma="mo analyze"
alias mst="mo status"

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

### FZF ###
if command -v brew >/dev/null 2>&1; then
  fzf_prefix="$(brew --prefix fzf 2>/dev/null || true)"
  [ -f "$fzf_prefix/shell/completion.zsh" ] && source "$fzf_prefix/shell/completion.zsh" 2>/dev/null
  [ -f "$fzf_prefix/shell/key-bindings.zsh" ] && source "$fzf_prefix/shell/key-bindings.zsh" 2>/dev/null
fi

### NAVIGATION ###
cx() { cd "$@" && l }
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && l }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

### NIX ###
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

### INIT ###
if command -v thefuck >/dev/null 2>&1; then
  eval "$(thefuck --alias)"
fi
export STARSHIP_CONFIG=~/.config/starship.toml
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
if command -v devenv >/dev/null 2>&1; then
  eval "$(devenv hook zsh)"
fi

# must stay last: it only highlights what's already defined above it
for plugin in \
  "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" \
  /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  if [ -r "$plugin" ]; then
    source "$plugin"
    break
  fi
done

# comment defaults to fg=black,bold, i.e. ANSI slot 0 -- and Ghostty leaves
# bold-color unset, so bold black stays on slot 0 instead of brightening to 8.
# Slot 0 is the theme's dimmest text step; slot 8 is the one meant for
# secondary text, so point comments there explicitly rather than inherit.
# Set after the source above: the plugin declares the array and only fills
# in its own default when the key is still empty.
ZSH_HIGHLIGHT_STYLES[comment]='fg=8'

# pnpm
export PNPM_HOME="/Users/mathieusouflis/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
