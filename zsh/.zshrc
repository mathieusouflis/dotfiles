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
autoload -U colors && colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

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
source <(kubectl completion zsh)
complete -o nospace -C /opt/homebrew/bin/terraform terraform

### KEYBINDS ###
# autosuggestions first: it defines the autosuggest-* widgets bound below
source /run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh
bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
bindkey jj vi-cmd-mode

### ENV ###
export LANG=en_US.UTF-8
export EDITOR=/opt/homebrew/bin/nvim
export DIRENV_LOG_FORMAT=""
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

export PATH="$PATH:$HOME/.local/bin"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

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

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

### FZF ###
[ -f "$(brew --prefix fzf)/shell/completion.zsh" ] && source "$(brew --prefix fzf)/shell/completion.zsh" 2>/dev/null
[ -f "$(brew --prefix fzf)/shell/key-bindings.zsh" ] && source "$(brew --prefix fzf)/shell/key-bindings.zsh" 2>/dev/null

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
eval $(thefuck --alias)
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(atuin init zsh)"
eval "$(direnv hook zsh)"

# must stay last: it only highlights what's already defined above it
source /run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
