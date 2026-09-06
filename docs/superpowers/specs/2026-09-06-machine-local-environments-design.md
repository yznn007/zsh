# 本机开发环境迁移设计

## 目标

让公共 Zsh 配置仓库只包含可在新 Mac 上直接复用的终端配置，将当前机器使用的 Cargo、JetBrains Toolbox、OrbStack、Bun、Conda 和 Proto 接入口集中到被 Git 忽略的 `local.zsh`。

## 文件边界

- `.zshenv` 保存 XDG、`ZDOTDIR`、仓库目录和 Starship 配置路径。
- `.zprofile` 保存 Homebrew 登录环境初始化。
- `.zshrc` 保存通用交互配置，并在末尾加载 `local.zsh`。
- `local.example.zsh` 公开保存六项开发环境的注释模板，并纳入 Git。
- `local.zsh` 保存当前机器启用的开发环境入口，由 `.gitignore` 排除。
- `README.md` 只把通用终端工具列为新 Mac 的仓库依赖，并说明 `local.zsh` 的用途。
- 博客文章将六项环境描述为本机扩展示例，明确它们不随仓库克隆。

## 运行行为

新 Mac 缺少 `local.zsh` 时，公共别名、补全、fzf、zoxide、插件和 Starship 继续加载。用户可以将 `local.example.zsh` 复制为 `local.zsh`，再启用当前机器需要的部分。当前 Mac 通过现有 `.zshrc` 末尾的条件判断加载 `local.zsh`，六项开发环境继续用于交互式终端。

`local.zsh` 对目录和脚本执行存在性检查。Cargo、Toolbox、OrbStack、Bun、Conda 和 Proto 的程序文件存在时才修改环境。

## 验证

- 对所有 Zsh 文件执行 `zsh -n`。
- 确认三个公共启动文件不再包含六项开发环境入口。
- 确认 `local.zsh` 包含六项入口且处于 Git 忽略状态。
- 确认 `local.example.zsh` 包含六项注释示例且可以由 Git 跟踪。
- 运行 `tests/terminal-tools.zsh`。
- 在全新 PTY 登录 Shell 中检查公共工具和本机环境。
- 运行博客测试、类型检查、格式检查和生产构建。
