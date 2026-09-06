# zsh

适用于 macOS 的轻量 Zsh 配置，集成命令补全、语法高亮、模糊搜索、目录跳转和 Starship 提示符。

## 依赖

需要 macOS、Git、[Homebrew](https://brew.sh/zh-cn/) 和 Zsh。建议终端使用 Nerd Font；默认编辑器为 Visual Studio Code 的 `code` 命令。

```zsh
brew install neovim eza bat fd fzf zoxide starship ripgrep yazi
```

## 安装

1. 克隆仓库：

   ```zsh
   mkdir -p "$HOME/.config"
   git clone https://github.com/yznn007/zsh.git "$HOME/.config/zsh"
   ```

2. 按需初始化本机开发环境：

   ```zsh
   cp "$HOME/.config/zsh/local.example.zsh" \
      "$HOME/.config/zsh/local.zsh"
   ```

   编辑 `local.zsh`，取消需要使用的环境配置注释。仅使用通用终端配置时可以跳过这一步。

3. 编辑 macOS 的系统级 Zsh 环境文件：

   ```zsh
   sudo nano /etc/zshenv
   ```

   添加以下内容：

   ```zsh
   if [[ -z "$XDG_CONFIG_HOME" ]]; then
       export XDG_CONFIG_HOME="$HOME/.config"
   fi

   if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
       export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
   fi
   ```

4. 重新打开终端，或启动新的登录 Shell：

   ```zsh
   exec /bin/zsh -l
   ```

Zsh 将直接读取仓库中的 `.zshenv`、`.zprofile` 和 `.zshrc`。首次启动时，插件会自动安装到 `~/.config/zsh/plugins/`。

如果已有 Zsh 配置，请在安装前备份并手动合并。机器专用设置写入 `~/.config/zsh/local.zsh`；该文件不会纳入 Git。

## 配置

| 文件                | 用途                                   |
| ------------------- | -------------------------------------- |
| `.zshenv`           | XDG 目录、仓库路径和 Starship 配置路径 |
| `.zprofile`         | Homebrew 登录环境                      |
| `.zshrc`            | 历史记录、补全系统和模块加载           |
| `aliases.zsh`       | 命令别名和辅助函数                     |
| `fzf.zsh`           | 模糊搜索和文件预览                     |
| `bindings.zsh`      | 交互式快捷键                           |
| `plugins.zsh`       | 插件管理                               |
| `prompt.zsh`        | Starship 初始化                        |
| `starship.toml`     | Starship 配置                          |
| `local.example.zsh` | 本机配置模板，纳入 Git                 |
| `local.zsh`         | 本机路径与开发环境，不纳入 Git         |

命令历史保存在 `~/.local/state/zsh/history`，补全缓存保存在 `~/.cache/zsh/`。

### 本机扩展

Cargo、JetBrains Toolbox、OrbStack、Bun、Conda 和 Proto 的注释示例保存在 `local.example.zsh`。复制模板后，取消当前机器需要使用的部分：

```zsh
cp "$HOME/.config/zsh/local.example.zsh" \
   "$HOME/.config/zsh/local.zsh"
```

`local.zsh` 由 `.gitignore` 排除，并在 `.zshrc` 的末尾加载。本机路径和私人配置会保留在当前电脑。

## 工具

| 工具     | 用途               | 接入方式                                 |
| -------- | ------------------ | ---------------------------------------- |
| Neovim   | 终端文本编辑       | 通过 `vim` 别名调用                      |
| eza      | 目录列表和树形视图 | 提供 `ls`、`ll`、`la` 和 `tree` 别名     |
| bat      | 文件查看和语法高亮 | 提供 `cat` 别名，并用于 man 页和文件预览 |
| ripgrep  | 文本搜索           | 提供 `grep` 别名                         |
| fd       | 文件查找           | 为模糊文件选择提供候选列表               |
| fzf      | 交互式模糊选择     | 用于历史记录、文件和目录选择             |
| zoxide   | 智能目录跳转       | 记录目录使用频率并生成跳转函数           |
| Yazi     | 终端文件管理       | 通过目录同步包装函数启动                 |
| Starship | Shell 提示符       | 由 `prompt.zsh` 初始化                   |

使用 `command <名称>` 可以绕过同名别名。

## 函数

| 函数                  | 用途                                             | 联动                                |
| --------------------- | ------------------------------------------------ | ----------------------------------- |
| `y [路径]`            | 启动 Yazi，并在退出后同步当前目录                | Yazi、`mktemp`、`cd`                |
| `z <关键词>`          | 按使用频率跳转到匹配目录                         | zoxide                              |
| `zi`                  | 交互式选择并跳转目录                             | zoxide、fzf                         |
| `ip`                  | 查询当前公网 IP                                  | curl、ipip.net、cip.cc              |
| `launch`              | 显示并打开 macOS 启动项目录                      | `open`、LaunchAgents、LaunchDaemons |
| `b1`                  | 更新 Homebrew 元数据并检查可升级软件             | `brew update`、`brew outdated`      |
| `b2`                  | 升级并清理 Homebrew 软件包                       | `brew upgrade`、`brew cleanup`      |
| `proxy_on [--quiet]`  | 为当前 Shell 设置 HTTP、HTTPS 和通用代理         | `127.0.0.1:7890`                    |
| `proxy_off [--quiet]` | 清除当前 Shell 的代理环境变量                    | Shell 环境变量                      |
| `proxy_status`        | 检查系统代理、TUN 路由、本地端口和 Shell 代理    | `scutil`、`route`、`nc`             |
| `starship_use <预设>` | 切换 `default`、`official` 或 `pills` 提示符预设 | Starship                            |

插件安装、代理检测和 fzf 按键组件使用内部辅助函数，由上述公共函数和启动流程自动调用。

## 插件

| 插件                                                                            | 用途           |
| ------------------------------------------------------------------------------- | -------------- |
| [zsh-completions](https://github.com/zsh-users/zsh-completions)                 | 扩展命令补全   |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)         | 行内命令建议   |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | 命令行语法高亮 |

## 快捷键

| 快捷键   | 用途                     |
| -------- | ------------------------ |
| `Ctrl+R` | 搜索命令历史             |
| `Ctrl+T` | 选择文件，包含隐藏文件   |
| `Ctrl+F` | 选择文件，不包含隐藏文件 |

当前使用 Emacs 键位模式。

## 更新

```zsh
git -C "$HOME/.config/zsh" pull --ff-only
zplugin-update
```

## 许可证

本项目采用 [MIT License](LICENSE)。

## 致谢

本配置参考了 [Radley Lewis 的 Zsh 配置](https://github.com/radleylewis/zsh)。
