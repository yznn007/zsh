# 个人 Zsh 配置模块化迁移设计

## 目标

将当前 macOS 用户配置迁移到 `/Users/Apple/.config/zsh`，沿用参考仓库的模块化组织方式，并让当前实际启动的 Zsh 配置从该目录加载。迁移保持现有功能，不自动加入参考仓库中当前未使用的 zoxide、Vi 模式、fzf 快捷键或其他插件。

本次新增约束：Zsh 插件不再通过 Homebrew 文件路径加载，而是由仓库中的 `plugins.zsh` 使用 Git 克隆到配置目录下的 `plugins/` 后加载。

## 方案选择

### 方案 A：只修改当前 `~/.zshrc`

把 Homebrew 插件的两行 `source` 替换为 Git 插件加载逻辑，其他配置继续留在用户目录。改动最小，但仓库不能成为完整配置来源。

### 方案 B：仓库模块化配置 + 用户目录启动桥接（采用）

仓库保存实际配置模块；`~/.zshenv` 加载仓库的环境模块，`~/.zshrc` 加载仓库的启动入口。`~/.zprofile` 保持原样，以保留 Homebrew、Toolbox 和 OrbStack 的登录 Shell 初始化。这样插件路径、别名、代理、Conda、Proto 和提示符均由仓库入口统一管理，同时不改变登录初始化职责。

### 方案 C：把所有启动文件都移动到仓库并切换 `ZDOTDIR`

可以做到完全由仓库接管启动文件，但需要新增或接管 `.zprofile`，会改变当前 macOS 登录 Shell 的加载链，超出本次“保持现有行为”的范围。

## 配置边界

仓库根目录继续保留参考仓库的核心文件：

- `.zshenv`：XDG 目录、仓库配置路径、Cargo 环境
- `.zshrc`：环境变量、补全、Conda、Proto 和模块加载顺序
- `aliases.zsh`：别名、颜色变量、现有辅助函数和代理函数
- `plugins.zsh`：Git 插件安装、加载和更新
- `prompt.zsh`：Starship 初始化及现有 `starship_use`
- `bindings.zsh`、`fzf.zsh`：保留模块边界；不添加当前未使用的快捷键
- `starship.toml`：当前生效的普通 Starship 配置副本
- `.gitignore`、`README.md`、`LICENSE`：保留仓库管理、说明和 MIT 许可

备用的 `starship_pills.toml` 不纳入本次迁移；现有 `starship_use pills` 仍按当前路径查找它。`~/.zprofile` 不迁移、不改写。

## 插件安装与加载

`plugins.zsh` 管理以下三个当前使用的插件：

- `zsh-users/zsh-autosuggestions`
- `zsh-users/zsh-syntax-highlighting`
- `zsh-users/zsh-completions`

插件目录固定为 `$ZSH_CONFIG_DIR/plugins`，该目录加入 `.gitignore`，避免把第三方源码提交到仓库。首次启动时使用浅克隆；后续启动直接从本地源码加载；`zplugin-update` 对已安装插件执行 `git pull --ff-only`。

`zsh-completions` 的 `src/` 目录在 `compinit` 前加入 `FPATH`。两个可执行插件在模块中加载，其中语法高亮最后加载，以保留 Zsh widget 的兼容性。加载失败时输出明确错误，但不阻塞其他配置继续执行。

## 实际配置同步

修改前备份当前 `/Users/Apple/.zshenv` 和 `/Users/Apple/.zshrc`。修改后：

- `~/.zshenv` 只负责定位并加载仓库 `.zshenv`
- `~/.zshrc` 只负责加载仓库 `.zshrc`
- `~/.zprofile` 继续使用现有内容

因此新开交互 Shell 时，仓库内容和实际交互配置保持同一来源；本次不执行 `exec zsh`，不强制关闭或重启用户当前终端。

## 验证

验证分为四层：

1. 对仓库内全部 `.zsh` 文件执行 `zsh -n` 语法检查。
2. 使用干净的非交互 Zsh 加载仓库模块，确认无语法错误。
3. 启动一个新的交互 Zsh，确认三个插件目录均已安装、插件函数存在、Homebrew 插件路径不再被引用。
4. 检查 Git 工作树、提交内容、本地 HEAD、跟踪分支和 GitHub 远端 SHA 一致。

本次不验证真实代理网络、Starship 渲染视觉效果或每个第三方插件的全部运行时功能；这些需要分别依赖网络状态、终端字体和插件自身运行环境。
