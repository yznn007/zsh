# ---------- Aliases ----------
alias sha1='shasum -a 1'
alias sha256='shasum -a 256'
alias py='python3'
alias clang++='clang++ -std=c++20'

# ---------- Colors ----------
HEI=$'\e[1;30m'
HONG=$'\e[1;31m'
LV=$'\e[1;32m'
HUANG=$'\e[1;33m'
LAN=$'\e[1;34m'
FEN=$'\e[1;35m'
QING=$'\e[1;36m'
BAI=$'\e[1;37m'
RES=$'\e[0m'

# ---------- Helpers ----------
ip() {
    echo -e "${LV}ipip.net${RES}"
    curl myip.ipip.net
    echo -e "\n${LV}cip.cc${RES}"
    curl cip.cc
}

launch() {
    local p1="$HOME/Library/LaunchAgents"
    local p2="/Library/LaunchDaemons"
    local p3="/Library/LaunchAgents"
    local p4="/System/Library/LaunchDaemons"
    local p5="/System/Library/LaunchAgents"

    echo -e "${LV}${p1}：用户自定义的启动项${RES}"
    open "$p1"
    echo -e "${LAN}${p2}：系统启动时运行，用户不登录也会运行${RES}"
    open "$p2"
    echo -e "${LAN}${p3}：系统启动后，用户登录后运行${RES}"
    open "$p3"
    echo -e "${HUANG}${p4}：系统组件，系统装载时以root用户启动${RES}"
    open "$p4"
    echo -e "${HUANG}${p5}：系统组件，任一用户登录后以当前用户运行${RES}"
    open "$p5"

    case "$1" in
        u) echo "${LV}打开文件夹...${RES}"; open "$p1" "$p2" "$p3" ;;
        a) echo "${LV}打开文件夹...${RES}"; open "$p1" "$p2" "$p3" "$p4" "$p5" ;;
    esac
}

b1() {
    echo -e "${LV}更新Homebrew：${RES}"
    brew update
    echo -e "${HUANG}检查旧包：${RES}"
    brew outdated
}

b2() {
    echo -e "${HONG}升级包：${RES}"
    brew upgrade
    echo -e "${LAN}清理包：${RES}"
    brew cleanup
}

# ---------- Network proxy ----------
PROXY_SCHEME="http"
PROXY_HOST="127.0.0.1"
PROXY_PORT="7890"
PROXY_URL="${PROXY_SCHEME}://${PROXY_HOST}:${PROXY_PORT}"
PROXY_AUTO_MODE="auto"

proxy_port_available() {
    nc -z -w1 "$PROXY_HOST" "$PROXY_PORT" >/dev/null 2>&1
}

proxy_system_enabled() {
    local proxy_config
    proxy_config="$(scutil --proxy 2>/dev/null)" || return 1
    echo "$proxy_config" | awk '
        /HTTPEnable[[:space:]]*:[[:space:]]*1/ { http=1 }
        /HTTPSEnable[[:space:]]*:[[:space:]]*1/ { https=1 }
        /SOCKSEnable[[:space:]]*:[[:space:]]*1/ { socks=1 }
        /ProxyAutoConfigEnable[[:space:]]*:[[:space:]]*1/ { pac=1 }
        END { exit !(http || https || socks || pac) }
    '
}

proxy_tun_enabled() {
    local iface
    iface="$(route -n get 1.1.1.1 2>/dev/null | awk '/interface:/ { print $2; exit }')"
    [[ "$iface" == utun* || "$iface" == tun* ]] && return 0

    iface="$(route -n get 8.8.8.8 2>/dev/null | awk '/interface:/ { print $2; exit }')"
    [[ "$iface" == utun* || "$iface" == tun* ]]
}

proxy_network_enabled() {
    proxy_system_enabled || proxy_tun_enabled
}

proxy_on() {
    export http_proxy="$PROXY_URL"
    export https_proxy="$PROXY_URL"
    export HTTP_PROXY="$PROXY_URL"
    export HTTPS_PROXY="$PROXY_URL"
    export all_proxy="$PROXY_URL"
    export ALL_PROXY="$PROXY_URL"

    if [[ "$1" != "--quiet" ]]; then
        echo "Proxy enabled"
        echo "Proxy URL: $PROXY_URL"
    fi
}

proxy_off() {
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY all_proxy ALL_PROXY
    if [[ "$1" != "--quiet" ]]; then
        echo "Proxy disabled"
    fi
}

proxy_status() {
    if proxy_system_enabled; then
        echo "System Proxy: ON"
    else
        echo "System Proxy: OFF"
    fi

    if proxy_tun_enabled; then
        echo "TUN Route   : ON"
    else
        echo "TUN Route   : OFF"
    fi

    if proxy_port_available; then
        echo "Proxy Port  : ON (${PROXY_HOST}:${PROXY_PORT})"
    else
        echo "Proxy Port  : OFF (${PROXY_HOST}:${PROXY_PORT})"
    fi

    if [[ -n "$http_proxy" ]]; then
        echo "Shell Proxy : ON"
        echo "HTTP Proxy : $http_proxy"
        echo "HTTPS Proxy: $https_proxy"
    else
        echo "Shell Proxy : OFF"
    fi
}

case "$PROXY_AUTO_MODE" in
    auto)
        if proxy_network_enabled; then
            if proxy_port_available; then
                proxy_on --quiet
            else
                proxy_off --quiet
                echo "Proxy network is on, but local proxy port is unavailable: ${PROXY_HOST}:${PROXY_PORT}"
            fi
        else
            proxy_off --quiet
            echo "Proxy network is off"
        fi
        ;;
    system)
        if proxy_system_enabled; then
            proxy_on --quiet
        else
            proxy_off --quiet
            echo "System proxy is off"
        fi
        ;;
    tun)
        if proxy_tun_enabled; then
            if proxy_port_available; then
                proxy_on --quiet
            else
                proxy_off --quiet
                echo "TUN route is on, but local proxy port is unavailable: ${PROXY_HOST}:${PROXY_PORT}"
            fi
        else
            proxy_off --quiet
            echo "TUN route is off"
        fi
        ;;
    port)
        if proxy_port_available; then
            proxy_on --quiet
        else
            proxy_off --quiet
            echo "Proxy unavailable: ${PROXY_HOST}:${PROXY_PORT}"
        fi
        ;;
    off)
        ;;
    *)
        echo "Unknown PROXY_AUTO_MODE: $PROXY_AUTO_MODE"
        ;;
esac
