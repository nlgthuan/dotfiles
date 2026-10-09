# Drop duplicate entries
typeset -U path fpath
# `brew shellenv` exports FPATH; keep it local so child shells (tmux panes, etc.)
# build the same fpath and do not invalidate the completion cache
typeset +x FPATH

# Homebrew (HOMEBREW_PREFIX is set by `brew shellenv` in .zprofile)
: ${HOMEBREW_PREFIX:=/opt/homebrew}

# PATH
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/go/bin:$PATH"

# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
ZSH_DISABLE_COMPFIX=true
zstyle ':omz:update' mode disabled  # update manually with `omz update`

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

# Load nvm on first use; node is put on PATH below without it
nvm() {
  unfunction nvm
  source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" --no-use
  nvm "$@"
}

# Put the default node on PATH without the slow `nvm use`
_nvm_default="$(<"$NVM_DIR/alias/default" 2>/dev/null)"
_nvm_default="$NVM_DIR/versions/node/v${_nvm_default#v}"
[[ -d "$_nvm_default/bin" ]] || _nvm_default=$(ls -d "$NVM_DIR"/versions/node/v* 2>/dev/null | tail -1)
[[ -d "$_nvm_default/bin" ]] && export PATH="$_nvm_default/bin:$PATH"
unset _nvm_default

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] &&
  source "$SDKMAN_DIR/bin/sdkman-init.sh"

# Local configuration
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
