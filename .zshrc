# Personal zsh configuration

export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}}"
export LANG="zh_CN.UTF-8"

# ---------- History ----------
mkdir -p "$XDG_STATE_HOME/zsh"
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS

# # oh-my-zsh (disabled — using Starship)
# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="cleanly"
# plugins=(git brew python pip sublime web-search encode64 extract macos history z)
# source "$ZSH/oh-my-zsh.sh"

# ---------- Modules and completion ----------
# This must run before compinit so zsh-completions can extend FPATH.
if [[ -r "$ZSH_CONFIG_DIR/plugins.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/plugins.zsh"
fi

# ---------- Completion ----------
autoload -Uz compinit
mkdir -p "$XDG_CACHE_HOME/zsh"
compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump"

if [[ -r "$ZSH_CONFIG_DIR/aliases.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/aliases.zsh"
fi

if [[ -r "$ZSH_CONFIG_DIR/fzf.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/fzf.zsh"
fi

if [[ -r "$ZSH_CONFIG_DIR/bindings.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/bindings.zsh"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
if command -v bat >/dev/null 2>&1; then
    export MANPAGER='bat -l man -p'
fi

# Use Visual Studio Code as the default terminal editor.
export EDITOR='code --wait'
export VISUAL='code --wait'

# Keep syntax highlighting last among loaded script plugins, before the prompt.
if (( $+functions[_zplugin_load] )); then
    _zplugin_load zsh-users zsh-autosuggestions
    _zplugin_load zsh-users zsh-syntax-highlighting
fi

# ---------- Prompt ----------
if [[ -r "$ZSH_CONFIG_DIR/prompt.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/prompt.zsh"
fi

# ---------- Machine-local overrides ----------
if [[ -r "$ZSH_CONFIG_DIR/local.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/local.zsh"
fi
