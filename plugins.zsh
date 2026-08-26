# Git-installed plugins

ZPLUGINDIR="${ZSH_CONFIG_DIR:-${ZDOTDIR:-$HOME/.config/zsh}}/plugins"

_zplugin_install() {
    local owner="$1"
    local repo="$2"
    local plugin_path="$ZPLUGINDIR/$2"

    if [[ -d "$plugin_path/.git" ]]; then
        print -r -- "$plugin_path"
        return 0
    fi

    if [[ -e "$plugin_path" ]]; then
        print -u2 -- "ERROR: plugin path exists but is not a Git repository: $plugin_path"
        return 1
    fi

    if ! command -v git >/dev/null 2>&1; then
        print -u2 -- "ERROR: git is required to install $repo"
        return 1
    fi

    mkdir -p "$ZPLUGINDIR"
    print -u2 -- "Installing $repo..."
    if ! git clone --depth=1 "https://github.com/${owner}/${repo}.git" "$plugin_path" >&2; then
        print -u2 -- "ERROR: failed to install $repo"
        return 1
    fi

    print -r -- "$plugin_path"
}

_zplugin_fpath() {
    local plugin_path
    plugin_path="$(_zplugin_install "$1" "$2")" || return 1

    if [[ -d "$plugin_path/src" ]]; then
        FPATH="$plugin_path/src${FPATH:+:$FPATH}"
    else
        FPATH="$plugin_path${FPATH:+:$FPATH}"
    fi
}

_zplugin_load() {
    local plugin_path
    local plugin_file="${3:-$2.plugin.zsh}"
    plugin_path="$(_zplugin_install "$1" "$2")" || return 1

    if [[ -r "$plugin_path/$plugin_file" ]]; then
        source "$plugin_path/$plugin_file"
    else
        print -u2 -- "ERROR: plugin entry file not found: $plugin_path/$plugin_file"
        return 1
    fi
}

zplugin-update() {
    local dir

    if [[ ! -d "$ZPLUGINDIR" ]]; then
        print -r -- "No installed plugins: $ZPLUGINDIR"
        return 0
    fi

    for dir in "$ZPLUGINDIR"/*(/N); do
        [[ -d "$dir/.git" ]] || continue
        print -r -- "Updating ${dir:t}..."
        git -C "$dir" pull --ff-only || print -u2 -- "ERROR: failed to update ${dir:t}"
    done
}

# Remove legacy Homebrew completion paths inherited by an existing shell.
fpath=(${fpath:#*/zsh-completions})

# zsh-completions must be installed before compinit.
_zplugin_fpath zsh-users zsh-completions

# Keep syntax highlighting last among the loaded script plugins.
_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-syntax-highlighting
