# Machine-local development environment template
#
# Initialize your local configuration with:
#   cp "$HOME/.config/zsh/local.example.zsh" "$HOME/.config/zsh/local.zsh"
#
# Uncomment only the integrations used on this machine.

# ---------- Cargo ----------
# if [[ -r "$HOME/.cargo/env" ]]; then
#     source "$HOME/.cargo/env"
# fi

# ---------- JetBrains Toolbox ----------
# toolbox_scripts="$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
# if [[ -d "$toolbox_scripts" ]]; then
#     export PATH="$PATH:$toolbox_scripts"
# fi
# unset toolbox_scripts

# ---------- OrbStack ----------
# if [[ -r "$HOME/.orbstack/shell/init.zsh" ]]; then
#     source "$HOME/.orbstack/shell/init.zsh"
# fi

# ---------- Bun ----------
# if [[ -d "$HOME/.bun/bin" ]]; then
#     export PATH="$HOME/.bun/bin:$PATH"
# fi

# ---------- Conda ----------
# Let Starship render the active Conda environment.
export CONDA_CHANGEPS1=false
# if [[ -x "$HOME/miniconda3/bin/conda" ]]; then
#     __conda_setup="$("$HOME/miniconda3/bin/conda" shell.zsh hook 2> /dev/null)"
#     if [[ $? -eq 0 ]]; then
#         eval "$__conda_setup"
#     elif [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
#         source "$HOME/miniconda3/etc/profile.d/conda.sh"
#     else
#         export PATH="$HOME/miniconda3/bin:$PATH"
#     fi
#     unset __conda_setup
# fi

# ---------- Proto ----------
# if [[ -d "$HOME/.proto" ]]; then
#     export PROTO_HOME="$HOME/.proto"
#     export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"
# fi
