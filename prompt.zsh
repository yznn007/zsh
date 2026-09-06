# ---------- Starship prompt ----------
if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# 快速切换 Starship 预设
starship_use() {
    local name="$1"
    local file="$HOME/.config/starship_${name}.toml"
    local config="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"

    case "$name" in
        default|official)
            if [[ -f "$config" ]]; then
                mv "$config" "$config.bak"
            fi
            echo "Switched to Starship official default"
            exec zsh
            ;;
        pills)
            if [[ -f "$file" ]]; then
                cp "$file" "$config"
                echo "Switched to Starship preset: pills"
                exec zsh
            else
                echo "Preset not found: pills"
                return 1
            fi
            ;;
        *)
            echo "Preset not found: $name (available: default, pills)"
            return 1
            ;;
    esac
}
