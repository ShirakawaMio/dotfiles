#!/bin/bash

# 配置部分
DOTFILES_DIR="$HOME/dotfiles"
GITHUB_REPO_URL="" # 留空，初次运行时手动设置 git remote
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}开始备份配置文件...${NC}"

# 1. 确保目标目录结构存在
mkdir -p "$DOTFILES_DIR/.config"

# 2. 复制核心配置文件
# 使用 rsync 确保只同步变更，并排除 .git 目录
# 备份 .zshrc
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$DOTFILES_DIR/"
    echo -e "${GREEN}已备份 .zshrc${NC}"
fi

# 备份 .gitconfig
if [ -f "$HOME/.gitconfig" ]; then
    cp "$HOME/.gitconfig" "$DOTFILES_DIR/"
    echo -e "${GREEN}已备份 .gitconfig${NC}"
fi

# 备份 .config 下的目录 (nvim, kitty)
# 你可以在这里添加更多目录，例如: karabiner, iterm2
CONFIG_DIRS=("nvim" "kitty")

for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$HOME/.config/$dir" ]; then
        # 删除旧的备份以确保清洁（或者使用 rsync --delete）
        rm -rf "$DOTFILES_DIR/.config/$dir"
        cp -R "$HOME/.config/$dir" "$DOTFILES_DIR/.config/"
        echo -e "${GREEN}已备份 .config/$dir${NC}"
    fi
done

# 备份 Oh My Zsh 自定义部分 (插件/主题)
if [ -d "$HOME/.oh-my-zsh/custom" ]; then
    rm -rf "$DOTFILES_DIR/oh-my-zsh-custom"
    cp -R "$HOME/.oh-my-zsh/custom" "$DOTFILES_DIR/oh-my-zsh-custom"
    echo -e "${GREEN}已备份 Oh My Zsh custom plugins/themes${NC}"
fi

# 3. Git 推送
cd "$DOTFILES_DIR"

# 检查是否是 git 仓库
if [ ! -d ".git" ]; then
    echo -e "${YELLOW}初始化 Git 仓库...${NC}"
    git init
    git branch -M main
    echo -e "${YELLOW}请记得添加远程仓库: git remote add origin <your-repo-url>${NC}"
fi

# 检查是否有变更
if [ -n "$(git status --porcelain)" ]; then
    git add .
    git commit -m "Auto backup: $DATE"
    
    # 尝试推送，如果失败（比如没有 remote）则只 commit
    if git remote -v | grep -q origin; then
        echo -e "${YELLOW}推送到 GitHub...${NC}"
        git push origin main
        echo -e "${GREEN}备份完成并已推送！${NC}"
    else
        echo -e "${YELLOW}已提交变更，但未检测到远程仓库，跳过推送。${NC}"
    fi
else
    echo -e "${GREEN}没有检测到配置变更。${NC}"
fi
