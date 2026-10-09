# Drop duplicate entries
typeset -U path fpath
# `brew shellenv` exports FPATH; keep it local so child shells (tmux panes, etc.)
# build the same fpath
typeset +x FPATH

# Homebrew (HOMEBREW_PREFIX is set in .zprofile)
: ${HOMEBREW_PREFIX:=/opt/homebrew}

# PATH
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/go/bin:$PATH"

# Plugins are plain git clones; update with `git -C <dir> pull`
ZSH_PLUGINS="$HOME/.local/share/zsh/plugins"
ZSH_CACHE_DIR="$HOME/.cache/zsh"

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=10000
setopt extended_history hist_expire_dups_first hist_ignore_dups hist_ignore_space
setopt hist_verify share_history

# Directories
setopt auto_cd auto_pushd pushd_ignore_dups pushdminus

# Misc
setopt multios long_list_jobs interactivecomments prompt_subst
export PAGER="${PAGER:-less}" LESS="${LESS:--R}"
autoload -Uz bracketed-paste-magic url-quote-magic
zle -N bracketed-paste bracketed-paste-magic
zle -N self-insert url-quote-magic

# Completion
WORDCHARS=''
unsetopt menu_complete flowcontrol
setopt auto_menu complete_in_word always_to_end
zmodload -i zsh/complist
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle '*' single-ignored show

fpath+=("$ZSH_PLUGINS/fast-syntax-highlighting")

# Trust the completion dump and only re-check fpath for new completions once a day
autoload -Uz compinit
_zcompdump="$ZSH_CACHE_DIR/zcompdump-$ZSH_VERSION"
_zcompfresh=("$_zcompdump.checked"(N.mh-24))
if [[ -f "$_zcompdump" ]] && (( $#_zcompfresh )); then
  compinit -C -d "$_zcompdump"
else
  compinit -u -d "$_zcompdump"
  : >| "$_zcompdump.checked"
fi
[[ "$_zcompdump.zwc" -nt "$_zcompdump" ]] || zcompile "$_zcompdump"
unset _zcompdump _zcompfresh

# Colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
diff() { command diff --color "$@" }

# Aliases
alias ls='ls -G'
alias l='ls -lah' ll='ls -lh' la='ls -lAh' lsa='ls -lah'
alias grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox,.venv,venv}'
alias md='mkdir -p' rd=rmdir
alias -- -='cd -'
alias -g ...='../..' ....='../../..' .....='../../../..'
alias gco='git checkout'
alias history='fc -l 1'

# Key bindings (emacs mode)
bindkey -e
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
zle -N edit-command-line
bindkey '^[[A' up-line-or-beginning-search '^[OA' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search '^[OB' down-line-or-beginning-search
bindkey '^[[H' beginning-of-line '^[OH' beginning-of-line
bindkey '^[[F' end-of-line '^[OF' end-of-line
bindkey '^[[5~' up-line-or-history '^[[6~' down-line-or-history
bindkey '^[[Z' reverse-menu-complete
bindkey '^?' backward-delete-char '^[[3~' delete-char '^[[3;5~' kill-word
bindkey '^[[1;5C' forward-word '^[[1;5D' backward-word
bindkey '\ew' kill-region
bindkey ' ' magic-space
bindkey '^X^E' edit-command-line
bindkey '^[m' copy-prev-shell-word

# Plugins (fzf-tab must load after compinit and before widget-wrapping plugins)
source "$ZSH_PLUGINS/fzf-tab/fzf-tab.plugin.zsh"
source "$ZSH_PLUGINS/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
FAST_WORK_DIR="$HOME/.cache/fsh"  # existing dir, so the plugin skips `mkdir -p`
source "$ZSH_PLUGINS/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

# Prompt (robbyrussell look). Git info is fetched in the background, like
# oh-my-zsh's async prompt, so slow `git status` in big repos never blocks.
PROMPT='%B%(?.%F{green}.%F{red})➜  %F{cyan}%c%f ${_git_info}%b'
_git_info=
_git_root=
_git_fd=

# Find the repo root without launching git
_git_find_root() {
  local d=$PWD
  while true; do
    [[ -e $d/.git ]] && { REPLY=$d; return 0 }
    [[ $d == / ]] && return 1
    d=${d:h}
  done
}

# Prints "<branch> <dirty 0|1>"; runs in the background
_git_prompt_status() {
  local l head oid dirty=0
  for l in "${(@f)$(command git status --porcelain=v2 --branch --untracked-files=normal --ignore-submodules=dirty 2>/dev/null)}"; do
    case $l in
      ('# branch.head '*) head=${l#\# branch.head } ;;
      ('# branch.oid '*) oid=${l#\# branch.oid } ;;
      ('#'*) ;;
      (?*) dirty=1; break ;;
    esac
  done
  [[ $head == '(detached)' ]] && head=${oid[1,7]}
  [[ -n $head ]] && print -r -- "$head $dirty"
}

_git_prompt_cancel() {
  [[ -n $_git_fd ]] || return
  zle -F $_git_fd 2>/dev/null
  exec {_git_fd}<&-
  _git_fd=
}

_git_prompt_precmd() {
  local REPLY
  _git_prompt_cancel
  if ! _git_find_root; then
    _git_info= _git_root=
    return
  fi
  # Keep the old info while refreshing the same repo, so the prompt does not flicker
  [[ $REPLY == $_git_root ]] || _git_info=
  _git_root=$REPLY
  exec {_git_fd}< <(_git_prompt_status)
  zle -F -w $_git_fd _git_prompt_done
}

_git_prompt_done() {
  local fd=$1 line info=
  read -r -u $fd line
  zle -F $fd
  exec {fd}<&-
  _git_fd=
  local -a f=(${=line})
  if [[ -n ${f[1]} ]]; then
    local b=${f[1]//\%/%%}
    if [[ ${f[2]} == 1 ]]; then
      info="%F{blue}git:(%F{red}$b%F{blue}) %F{yellow}✗%f "
    else
      info="%F{blue}git:(%F{red}$b%F{blue})%f "
    fi
  fi
  if [[ $info != $_git_info ]]; then
    _git_info=$info
    zle .reset-prompt
  fi
}
zle -N _git_prompt_done
ZSH_AUTOSUGGEST_IGNORE_WIDGETS+=(_git_prompt_done)
autoload -Uz add-zsh-hook
add-zsh-hook precmd _git_prompt_precmd

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
