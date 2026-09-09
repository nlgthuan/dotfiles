# Homebrew
export HOMEBREW_PREFIX="$(brew --prefix)"

# PATH
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/go/bin:$PATH"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
  git
  fzf-tab
  zsh-autosuggestions
  fast-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# z
source "$HOME/.z.sh"

# fzf
source <(fzf --zsh)

# PostgreSQL
export PATH="$HOMEBREW_PREFIX/opt/libpq/bin:$PATH"

# GHCup
[[ -f "$HOME/.ghcup/env" ]] && source "$HOME/.ghcup/env"

# NVM
export NVM_DIR="$HOME/.nvm"
[[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]] &&
  source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"

[[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]] &&
  source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] &&
  source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Local configuration
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
