# 个人 Zsh 配置迁移 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 将当前 macOS Zsh 配置模块化写入 `/Users/Apple/.config/zsh`，并让实际 `~/.zshenv`、`~/.zshrc` 从仓库加载，同时把三个 Homebrew/系统插件改为 Git 源码安装。

**Architecture:** 仓库保存环境、入口、别名/函数、插件和提示符模块；用户目录只保留两个启动桥接文件。`~/.zprofile` 保持现状。`plugins.zsh` 将插件浅克隆到被 Git 忽略的 `$ZSH_CONFIG_DIR/plugins`，在 `compinit` 前加入补全目录并加载两个 Zsh 脚本插件。

**Tech Stack:** macOS Zsh 5.9、Git、Starship、Conda、Proto、Homebrew（仅保留现有登录环境和 `brew` 辅助函数依赖）。

---

### Task 1: 备份并建立实际配置桥接

**Files:**
- Backup: `/Users/Apple/.zshenv`
- Backup: `/Users/Apple/.zshrc`
- Modify: `/Users/Apple/.zshenv`
- Modify: `/Users/Apple/.zshrc`

- [ ] **Step 1: 创建带日期的备份目录并保存原文件**

```bash
backup_dir="/Users/Apple/.codex/backups/zsh-config-20260826"
mkdir -p "$backup_dir"
cp -p /Users/Apple/.zshenv "$backup_dir/.zshenv"
cp -p /Users/Apple/.zshrc "$backup_dir/.zshrc"
```

Expected: 两个原文件均存在于备份目录，权限和时间戳保留。

- [ ] **Step 2: 将 `~/.zshenv` 改为仓库环境模块桥接**

```zsh
export ZSH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
if [[ -r "$ZSH_CONFIG_DIR/.zshenv" ]]; then
    source "$ZSH_CONFIG_DIR/.zshenv"
fi
```

- [ ] **Step 3: 将 `~/.zshrc` 改为仓库入口桥接**

```zsh
export ZSH_CONFIG_DIR="${ZSH_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"
if [[ -r "$ZSH_CONFIG_DIR/.zshrc" ]]; then
    source "$ZSH_CONFIG_DIR/.zshrc"
else
    print -u2 -- "Zsh config not found: $ZSH_CONFIG_DIR/.zshrc"
fi
```

### Task 2: 填充仓库环境和模块入口

**Files:**
- Modify: `/Users/Apple/.config/zsh/.zshenv`
- Modify: `/Users/Apple/.config/zsh/.zshrc`
- Modify: `/Users/Apple/.config/zsh/bindings.zsh`
- Modify: `/Users/Apple/.config/zsh/fzf.zsh`

- [ ] **Step 1: 写入仓库 `.zshenv`**

写入 XDG 目录、`ZSH_CONFIG_DIR` 和原有 Cargo 初始化；不增加未确认的编辑器、GPG 或 Starship 模式行为。

- [ ] **Step 2: 写入模块化 `.zshrc`**

按以下顺序设置当前 PATH/LANG，加载别名、绑定、fzf 占位模块和 Git 插件模块，随后运行 `compinit`，最后保留当前的编辑器、Conda、Proto 和 Starship 配置入口。插件模块必须在 `compinit` 前执行，以便 `zsh-completions/src` 进入 `FPATH`。

- [ ] **Step 3: 保留空功能模块的边界**

`bindings.zsh` 和 `fzf.zsh` 只记录当前没有自定义绑定或 fzf 配置，不复制作者仓库中当前未使用的快捷键和行为。

### Task 3: 将现有别名、函数和代理配置拆入模块

**Files:**
- Modify: `/Users/Apple/.config/zsh/aliases.zsh`
- Modify: `/Users/Apple/.config/zsh/prompt.zsh`
- Modify: `/Users/Apple/.config/zsh/starship.toml`

- [ ] **Step 1: 将当前别名、颜色变量和辅助函数写入 `aliases.zsh`**

保留 `sha1`、`sha256`、`py`、`clang++`、`ip`、`launch`、`b1`、`b2`，以及代理环境变量、检测函数、`proxy_on`、`proxy_off`、`proxy_status` 和 `PROXY_AUTO_MODE=auto` 启动逻辑。

- [ ] **Step 2: 将 Starship 初始化和 `starship_use` 写入 `prompt.zsh`**

保留当前普通主题与 `pills` 预设的命令行为；不把备用 `starship_pills.toml` 强行加入仓库，也不在本次迁移中改变其路径。

- [ ] **Step 3: 将当前 `/Users/Apple/.config/starship.toml` 内容复制到仓库 `starship.toml`**

保留 schema、`$all` 格式、用户名显示和 Git 状态格式，不替换成作者的 Starship 主题。

### Task 4: 用 Git 源码方式安装并加载插件

**Files:**
- Modify: `/Users/Apple/.config/zsh/plugins.zsh`
- Modify: `/Users/Apple/.config/zsh/.gitignore`
- Modify: `/Users/Apple/.config/zsh/README.md`

- [ ] **Step 1: 实现插件安装辅助函数**

`plugins.zsh` 使用 `ZPLUGINDIR="${ZSH_CONFIG_DIR:-${ZDOTDIR:-$HOME/.config/zsh}}/plugins"`，首次安装执行 `git clone --depth=1 "https://github.com/$owner/$repo.git" "$plugin_path"`，已存在的 Git 目录直接复用，路径冲突和缺少 Git 时输出错误并返回失败。

- [ ] **Step 2: 为补全插件加入 `src/`，并加载两个脚本插件**

调用顺序固定为：`zsh-completions` 加入 `FPATH`，加载 `zsh-autosuggestions`，最后加载 `zsh-syntax-highlighting`。

- [ ] **Step 3: 实现 `zplugin-update`**

只对 `$ZPLUGINDIR` 下带 `.git` 的目录执行 `git pull --ff-only`；不存在插件目录时返回成功并说明无插件可更新。

- [ ] **Step 4: 忽略第三方源码和 Zsh 缓存**

`.gitignore` 至少包含 `plugins/`、`.zcompdump*`、`*.zwc`、`.DS_Store` 和 `starship.toml.bak`。

- [ ] **Step 5: 更新 README**

说明仓库参考 [radleylewis/zsh](https://github.com/radleylewis/zsh)，列出当前配置依赖、首次启动自动克隆插件、`zplugin-update` 更新命令和实际启动桥接方式。

### Task 5: 安装、语法检查和行为验证

**Files:**
- Verify: `/Users/Apple/.config/zsh/*.zsh`
- Verify: `/Users/Apple/.zshenv`
- Verify: `/Users/Apple/.zshrc`
- Verify: `/Users/Apple/.config/zsh/plugins/`

- [ ] **Step 1: 对所有 Zsh 文件做语法检查**

```bash
for file in /Users/Apple/.config/zsh/*.zsh /Users/Apple/.zshenv /Users/Apple/.zshrc; do
    /bin/zsh -n "$file" || exit 1
done
```

Expected: 所有文件退出码为 0。

- [ ] **Step 2: 启动新的交互 Shell 触发插件安装**

```bash
env PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" /bin/zsh -lic 'type _zsh_autosuggest_start 2>/dev/null; type zplugin-update 2>/dev/null; print -r -- "$ZPLUGINDIR"'
```

Expected: 首次运行克隆三个仓库；插件函数和 `zplugin-update` 可见；无 `/opt/homebrew/share/zsh-autosuggestions` 或 `/opt/homebrew/share/zsh-syntax-highlighting` 的加载错误。

- [ ] **Step 3: 检查 Git 和远端同步**

```bash
git diff --check
git status --short --branch
git add -- .
git commit -m "refactor: 模块化个人 Zsh 配置"
git push origin main
git rev-parse HEAD
git rev-parse origin/main
git ls-remote origin refs/heads/main
```

Expected: 工作树干净；本地 HEAD、`origin/main` 和远端 `main` SHA 相同。
