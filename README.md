# yznn007/zsh

个人 macOS Zsh 配置，目录组织参考 [radleylewis/zsh](https://github.com/radleylewis/zsh)，并保留 MIT License。

## 结构

- `.zshenv`：XDG 目录、配置目录和 Cargo 环境
- `.zshrc`：启动入口、补全、Conda、Proto 和模块加载顺序
- `aliases.zsh`：别名、颜色变量、辅助函数和网络代理
- `plugins.zsh`：Git 源码插件安装、加载和更新
- `prompt.zsh`：Starship 和预设切换
- `starship.toml`：当前普通 Starship 配置

## 插件

插件不依赖 Homebrew 的插件文件路径。首次启动交互式 Zsh 时，以下仓库会浅克隆到 `.config/zsh/plugins/`：

- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
- [zsh-completions](https://github.com/zsh-users/zsh-completions)

更新已安装插件：

```zsh
zplugin-update
```

## 使用方式

实际 `~/.zshenv` 和 `~/.zshrc` 作为启动桥接，加载本仓库对应文件；`~/.zprofile` 保持 macOS 当前的 Homebrew、Toolbox 和 OrbStack 初始化。

验证语法：

```zsh
for file in "$HOME/.config/zsh"/*.zsh "$HOME/.zshenv" "$HOME/.zshrc"; do
    zsh -n "$file" || exit 1
done
```
