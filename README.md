# My Dotfiles

个人开发环境配置文件备份与自动化初始化工具。支持 **macOS** 和主流 **Linux** 发行版（Ubuntu/Debian, Fedora, Arch）。

## 🚀 一键配置新机器

在新机器上执行以下命令，即可自动安装 Homebrew (macOS)、基础软件（Git, Zsh, Neovim, Kitty 等）、Oh My Zsh，并同步你的个人配置：

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ShirakawaMio/dotfiles/main/setup.sh)"
```

## 🛠️ 包含的配置
- **Shell**: Zsh (`.zshrc`) + Oh My Zsh 插件与主题
- **编辑器**: Neovim (`.config/nvim`)
- **终端**: Kitty (`.config/kitty`)
- **Git**: 基础配置 (`.gitconfig`)

## 📂 目录结构
- `backup.sh`: 备份本地配置并推送到 GitHub。
- `setup.sh`: 跨平台环境初始化脚本。
- `oh-my-zsh-custom/`: 存放 Oh My Zsh 的自定义插件和主题。

## 🔄 同步与备份

### 手动备份
当你修改了本地配置，运行以下脚本同步到 GitHub：
```bash
~/dotfiles/backup.sh
```

### 自动备份
脚本已默认尝试通过 Crontab 设置每日自动备份。你可以通过 `crontab -l` 查看任务：
```bash
0 12 * * * /Users/mio/dotfiles/backup.sh >> /Users/mio/dotfiles/backup.log 2>&1
```

## ⚠️ 注意事项
- **私钥与机密**: 脚本不会备份 `.ssh` 或其他包含敏感信息的文件。请确保不要手动将 API 密钥等放入此仓库。
- **Linux 支持**: 在 Linux 上运行时，脚本会尝试使用 `sudo` 和对应的包管理器（apt, dnf, pacman）安装依赖。