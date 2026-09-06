if command -v fzf >/dev/null 2>&1 && command -v fd >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_DEFAULT_OPTS='
      --height=60%
      --layout=reverse
      --border=rounded
      --prompt="  "
      --pointer="  "
      --preview-window=right:65%:wrap:border-left
    '
    export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
    export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"
    FZF_ALT_C_COMMAND=''
    # `zsh -ic` without a TTY has no usable ZLE; keep fzf initialization quiet
    # there while preserving ZLE and all bindings in real terminals.
    if [[ ! -t 0 ]]; then
        unsetopt zle
    fi
    eval "$(fzf --zsh)"

    _fzf_file_no_hidden() {
        local FZF_CTRL_T_COMMAND='fd --type f --strip-cwd-prefix'
        local FZF_CTRL_T_OPTS="$FZF_CTRL_T_OPTS +m"
        fzf-file-widget
    }
    zle -N _fzf_file_no_hidden
fi
