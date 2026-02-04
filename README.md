# My Dotfiles

个人开发环境配置文件备份。

## 目录结构
- `backup.sh`: 将本地配置复制到此目录并推送到 GitHub。
- `setup.sh`: 在新机器上安装环境并恢复配置。
- `.config/`: 包含 nvim, kitty 等应用的配置。
- `.zshrc`, `.gitconfig`: 核心 Shell 和 Git 配置。

## 🚀 快速开始

### 1. 首次设置 (在当前机器)
初始化 Git 仓库并推送到你的 GitHub：

```bash
cd ~/dotfiles
git init
git branch -M main
git add .
git commit -m "Initial backup"

# 替换为你的 GitHub 仓库地址
git remote add origin https://github.com/USERNAME/dotfiles.git
git push -u origin main
```

### 2. 定期备份
你可以手动运行备份脚本：
```bash
~/dotfiles/backup.sh
```

或者设置定时任务 (Cron) 每天自动备份：
1. 运行 `crontab -e`
2. 添加一行 (例如每天中午 12 点备份)：
   ```bash
   0 12 * * * /Users/mio/dotfiles/backup.sh >> /tmp/dotfiles_backup.log 2>&1
   ```

### 3. 在新机器上恢复
克隆仓库并运行安装脚本：
```bash
git clone https://github.com/USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```
