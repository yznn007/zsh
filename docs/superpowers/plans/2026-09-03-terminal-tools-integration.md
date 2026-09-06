# 终端工具接入实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 接入用户指定的终端工具，保留 VS Code 默认编辑器，使用 Yazi 而非 lf，不安装 mpv。

**Architecture:** 在用户已确认的实际配置目录原位实施并提前备份。沿用现有模块，插件补全路径先加载、交互插件后加载；主代理负责安装与端到端验收，一个实施代理负责相互依赖的配置和回归测试。

**Tech Stack:** macOS、Zsh 5.9、Homebrew、Neovim、eza、bat、ripgrep、fd、fzf、zoxide、Yazi。

## Global Constraints

- 保留 `EDITOR='code --wait'` 和 `VISUAL='code --wait'`。
- 不安装或配置 mpv、lf，不添加摄像头 stream 别名，不访问摄像头。
- 保留现有 Starship、Git 别名状态、Zsh 插件和 Emacs 按键模式。
- 保留 Homebrew、Conda、Proto、Cargo、Bun、OrbStack、代理和个人辅助函数。
- 不提交、推送、部署，不升级无关软件，不强制重载用户已经打开的终端。
- 备份位置：`/Users/Apple/.codex/backups/zsh-tools-20260903.4ZRurG`。
- 根目录：`/Users/Apple/.config/zsh`；基线 HEAD：`3a38dc18f972e117cfed135faf8b80f1fc366d7f`。

## Task 1: 配置、回归测试与使用说明

**Files:**
- Modify: `/Users/Apple/.config/zsh/aliases.zsh`
- Modify: `/Users/Apple/.config/zsh/fzf.zsh`
- Modify: `/Users/Apple/.config/zsh/bindings.zsh`
- Modify: `/Users/Apple/.config/zsh/.zshrc`
- Modify: `/Users/Apple/.config/zsh/plugins.zsh`
- Modify: `/Users/Apple/.config/zsh/README.md`
- Create: `/Users/Apple/.config/zsh/tests/terminal-tools.zsh`

- [ ] **Step 1: 添加回归测试并记录未实施时的预期失败。**

测试用新交互 Zsh 加载真实配置，检查以下实际状态（脚本必须明确失败并返回非零，不得只打印结果）：

```zsh
[[ $EDITOR == 'code --wait' && $VISUAL == 'code --wait' ]]
[[ ${aliases[vim]} == nvim ]]
[[ ${aliases[ls]} == 'eza --icons' ]]
[[ ${aliases[cat]} == bat ]]
[[ ${aliases[grep]} == 'rg --color=auto' ]]
[[ $MANPAGER == 'bat -l man -p' ]]
(( $+functions[z] && $+functions[y] ))
(( $+functions[fzf-file-widget] && $+functions[fzf-history-widget] ))
[[ $(bindkey '^R') == *fzf-history-widget* ]]
[[ $(bindkey '^T') == *fzf-file-widget* ]]
[[ $(bindkey '^F') == *_fzf_file_no_hidden* ]]
[[ $(bindkey -lL main) == 'bindkey -A emacs main' ]]
(( $+functions[_zsh_autosuggest_start] && $+functions[_zsh_highlight] ))
[[ $PROMPT == *starship* ]]
```

样例文件必须在独立临时目录，用实际 fd/fzf 非交互过滤检查含隐藏文件与排除隐藏文件两种路径；使用 fzf mock 或 ZLE 测试夹具时明确只证明包装逻辑。针对 Yazi 包装函数，通过临时可执行文件写入 cwd-file，覆盖空输出、空格路径、不存在目录、取消及非零退出；确认只清理自己创建的临时文件。真实 Yazi TUI 由主代理另外验收。

运行：`TERM=xterm-256color /bin/zsh /Users/Apple/.config/zsh/tests/terminal-tools.zsh`。实施前应报告缺少上述配置；实施后所有断言通过。测试不得写用户历史、改变用户数据库或改动业务文件；用临时位置隔离测试数据，不重定义 HOME。

- [ ] **Step 2: aliases.zsh 增加工具别名及目录跟随。**

在已有别名后插入以下块，保留后续所有个人函数：

```zsh
if command -v nvim >/dev/null 2>&1; then
    alias vim='nvim'
fi
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons'
    alias ll='eza -lh --icons --git'
    alias la='eza -lah --icons --git'
    alias tree='eza --tree --icons'
    (( $+functions[compdef] )) && compdef eza=ls
fi
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
fi
if command -v rg >/dev/null 2>&1; then
    alias grep='rg --color=auto'
fi
if command -v yazi >/dev/null 2>&1; then
    y() {
        local tmp cwd yazi_result=0
        tmp=$(command mktemp -t yazi-cwd.XXXXXX) || return 1
        {
            command yazi "$@" --cwd-file="$tmp" || yazi_result=$?
            if (( yazi_result == 0 )); then
                IFS= read -r -d '' cwd < "$tmp" || true
                if [[ -n $cwd && $cwd != $PWD && -d $cwd ]]; then
                    builtin cd -- "$cwd" || yazi_result=$?
                fi
            fi
        } always {
            command rm -f -- "$tmp"
        }
        return $yazi_result
    }
fi
```

可根据测试发现的问题做最小修正，记录原因。不要把 `cat` 用于此函数的数据读取，不用通用 rm 清理目录。

- [ ] **Step 3: fzf.zsh 使用当前 fzf 官方初始化接口并设置上游选项。**

```zsh
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
    eval "$(fzf --zsh)"

    _fzf_file_no_hidden() {
        local FZF_CTRL_T_COMMAND='fd --type f --strip-cwd-prefix'
        local FZF_CTRL_T_OPTS="$FZF_CTRL_T_OPTS +m"
        fzf-file-widget
    }
    zle -N _fzf_file_no_hidden
fi
```

Ctrl+F 复用官方文件选择 widget 的路径转义和取消处理；禁用额外 Alt+C，避免新增未请求的快捷键。不要加入 zsh-vi-mode 的绑定钩子。

- [ ] **Step 4: bindings.zsh 增加 Ctrl+F；其他绑定沿用 fzf。**

```zsh
if (( $+functions[_fzf_file_no_hidden] )); then
    bindkey -M emacs '^F' _fzf_file_no_hidden
fi
```

- [ ] **Step 5: 调整启动顺序并接入 zoxide、MANPAGER。**

`plugins.zsh` 保留 `_zplugin_fpath zsh-users zsh-completions`，移除文件末尾立即加载两个交互插件的调用。在 `.zshrc` 最后、Starship 初始化前重新放置同样调用：

```zsh
if (( $+functions[_zplugin_load] )); then
    _zplugin_load zsh-users zsh-autosuggestions
    _zplugin_load zsh-users zsh-syntax-highlighting
fi
```

`.zshrc` 模块顺序：plugins 定义及 FPATH → compinit → aliases → fzf → bindings → zoxide / MANPAGER → 现有默认编辑器与语言环境 → 交互插件 → Starship。

```zsh
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi
if command -v bat >/dev/null 2>&1; then
    export MANPAGER='bat -l man -p'
fi
```

不修改 `.zshenv`、入口桥接、Starship 配置或已安装插件源码。

- [ ] **Step 6: 更新 README，运行测试与语法检查。**

使用说明必须覆盖 `vim` 与默认编辑器的区别、ls/ll/la/tree/cat/grep、Ctrl+R/T/F 的新旧行为、`z`、`y` 的 q/Q 行为、无 mpv/lf、可选预览依赖未新增、`command` 绕过别名、新开终端生效、备份恢复路径和不自动卸载软件。

```zsh
TERM=xterm-256color /bin/zsh /Users/Apple/.config/zsh/tests/terminal-tools.zsh
for config_file in /Users/Apple/.config/zsh/{.zshrc,.zshenv,aliases.zsh,fzf.zsh,bindings.zsh,plugins.zsh,prompt.zsh}; do
    /bin/zsh -n "$config_file" || exit 1
done
git -C /Users/Apple/.config/zsh diff --check
```

## 主代理安装、审查与最终验收

- [x] 备份实际配置和入口文件，基线语法检查通过。
- [x] 安装 eza、Yazi 及必要依赖；设置 Homebrew 不自动更新、清理或检查无关依赖方；不修改第三方 tap 信任。
- [x] Task 1 实施、独立规格审查通过；质量审查指出的 fzf 配置回归缺口已用 RED/GREEN 修复。
- [x] 验证实际交互式 fzf 历史/文件选择和 Yazi 启动、q 跟随、Q 不跟随；使用临时样例目录，不操作用户文件。
- [x] 核对默认编辑器、Starship 和插件未改变，确认工具版本和 Homebrew 变更范围。
- [x] 最终只读审查、检查工作区差异、交付结果和恢复路径。

## 进度记录

- 2026-09-03：设计获批，基线语法通过，备份已创建；eza/Yazi 安装已启动。
- 2026-09-03：eza 0.23.5、Yazi 26.8.15 安装完成，未升级现有依赖；真实 PTY 测试 7/7 通过。非 TTY fzf 初始化的 zle 警告已由最小例子定位，正在补充边界处理和回归。
- 2026-09-04：独立审查确认规格符合，补强测试以实际 `FZF_CTRL_T_COMMAND` 验证隐藏文件行为；错误配置 RED 退出 1，恢复后 GREEN 退出 0，输出干净。
- 2026-09-04：PTY 夹具改为每次自行创建和清理；最终隔离回归、PTY 7/7、语法、运行时断言、保留项比较、插件源码、diff 和依赖范围全部验证通过。
