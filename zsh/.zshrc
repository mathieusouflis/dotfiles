export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
source <(kubectl completion zsh)

bindkey '^w' autosuggest-execute
bindkey '^e' autosuggest-accept
bindkey '^u' autosuggest-toggle
bindkey '^L' vi-forward-word
bindkey '^k' up-line-or-search
bindkey '^j' down-line-or-search
bindkey jj vi-cmd-mode

export LANG=en_US.UTF-8
export EDITOR=/opt/homebrew/bin/nvim

export PATH="$PATH:/Users/mathieusouflis/.local/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

export PATH="/Users/mathieusouflis/.codeium/windsurf/bin:$PATH"

# ATUIN
eval "$(atuin init zsh)"

# DIRENV
export DIRENV_LOG_FORMAT=""
eval "$(direnv hook zsh)"
[ -s "/Users/mathieusouflis/.jabba/jabba.sh" ] && source "/Users/mathieusouflis/.jabba/jabba.sh"

# pnpm
export PNPM_HOME="/Users/mathieusouflis/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

alias i3lock="pmset displaysleepnow"
alias gsw='git switch'
alias gswc='git switch -c'

# Dotfiles
alias restow="~/dotfiles/stow.sh"

# Git
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
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

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# Eza
alias ls='eza --icons --git'
alias ll='eza -l --icons --git'
alias la='eza -la --icons --git'
alias lt='eza --tree --level=2 --icons --git'

alias cl='clear'

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

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# .NET
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$HOME/.dotnet:$PATH"

# GOPLS
export PATH="$PATH:$HOME/go/bin"
export PATH="$HOME/Library/Application Support/Zed/extensions/work/luau/luau-lsp-binaries/luau-lsp-1.63.0/:$PATH"

eval $(thefuck --alias)

# bun
[ -s "/Users/mathieusouflis/.bun/_bun" ] && source "/Users/mathieusouflis/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

### FZF ###
[ -f "$(brew --prefix fzf)/shell/completion.zsh" ] && source "$(brew --prefix fzf)/shell/completion.zsh" 2>/dev/null
[ -f "$(brew --prefix fzf)/shell/key-bindings.zsh" ] && source "$(brew --prefix fzf)/shell/key-bindings.zsh" 2>/dev/null
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'

### RIPGREP ###
alias grep='rg'

# navigation
fcd() { cd "$(find . -type d -not -path '*/.*' | fzf)" && ls -la }
f() { echo "$(find . -type f -not -path '*/.*' | fzf)" | pbcopy }
fv() { nvim "$(find . -type f -not -path '*/.*' | fzf)" }

# Vite+
. "$HOME/.vite-plus/env"

eval "$(starship init zsh)"
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# opam
[[ ! -r '/Users/mathieusouflis/.opam/opam-init/init.zsh' ]] || source '/Users/mathieusouflis/.opam/opam-init/init.zsh' > /dev/null 2> /dev/null

# Nix
if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi
