# Personal zsh configuration

export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
export PATH="$HOME/.bun/bin:$PATH"
export LANG="zh_CN.UTF-8"

# # oh-my-zsh (disabled — using Starship)
# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="cleanly"
# plugins=(git brew python pip sublime web-search encode64 extract macos history z)
# source "$ZSH/oh-my-zsh.sh"

# ---------- Modular configuration ----------
if [[ -r "$ZSH_CONFIG_DIR/aliases.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/aliases.zsh"
fi

if [[ -r "$ZSH_CONFIG_DIR/bindings.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/bindings.zsh"
fi

if [[ -r "$ZSH_CONFIG_DIR/fzf.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/fzf.zsh"
fi

# This must run before compinit so zsh-completions can extend FPATH.
if [[ -r "$ZSH_CONFIG_DIR/plugins.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/plugins.zsh"
fi

# ---------- Completion ----------
autoload -Uz compinit
mkdir -p "$XDG_CACHE_HOME/zsh"
compinit -C -d "$XDG_CACHE_HOME/zsh/zcompdump"

# Use Visual Studio Code as the default terminal editor.
export EDITOR='code --wait'
export VISUAL='code --wait'

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if [[ -x "$HOME/miniconda3/bin/conda" ]]; then
    __conda_setup="$("$HOME/miniconda3/bin/conda" shell.zsh hook 2> /dev/null)"
    if [[ $? -eq 0 ]]; then
        eval "$__conda_setup"
    else
        if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
            source "$HOME/miniconda3/etc/profile.d/conda.sh"
        else
            export PATH="$HOME/miniconda3/bin:$PATH"
        fi
    fi
    unset __conda_setup
fi
# <<< conda initialize <<<

# ---------- Proto ----------
export PROTO_HOME="$HOME/.proto"
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"

# ---------- Prompt ----------
if [[ -r "$ZSH_CONFIG_DIR/prompt.zsh" ]]; then
    source "$ZSH_CONFIG_DIR/prompt.zsh"
fi
