#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="https://github.com/ShirakawaMio/dotfiles.git"

echo -e "${BLUE}开始初始化开发环境...${NC}"

# 1. 安装 Homebrew (如果是 macOS 且未安装)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v brew &> /dev/null; then
        echo -e "${BLUE}未检测到 Homebrew，开始安装...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # 添加 brew 到 path (针对 Apple Silicon)
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        echo -e "${GREEN}Homebrew 已安装${NC}"
    fi
    
    # 2. 安装基础软件 (确保 git 已安装，以便后续克隆)
    echo -e "${BLUE}安装/更新基础软件包 (git, neovim, kitty, zsh, ripgrep, node, python)...${NC}"
    brew install git neovim kitty zsh ripgrep node python
else
    echo -e "${BLUE}非 macOS 系统，跳过 Homebrew 安装。请手动安装 git 以便脚本继续。${NC}"
fi

# 3. 克隆 Dotfiles 仓库 (关键步骤：如果不存在则克隆)
if [ ! -d "$DOTFILES_DIR" ]; then
    echo -e "${BLUE}正在克隆配置仓库到 $DOTFILES_DIR ...${NC}"
    if command -v git &> /dev/null; then
        git clone "$REPO_URL" "$DOTFILES_DIR"
    else
        echo -e "${YELLOW}错误: 未找到 git，无法克隆仓库。请先安装 git。${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}配置仓库已存在，尝试拉取最新代码...${NC}"
    git -C "$DOTFILES_DIR" pull origin main
fi

# 4. 安装 Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${BLUE}安装 Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo -e "${GREEN}Oh My Zsh 已安装${NC}"
fi

# 5. 恢复配置文件 (使用软链接)
echo -e "${BLUE}正在链接配置文件...${NC}"

create_symlink() {
    src="$1"
    dest="$2"
    
    # 确保源文件存在
    if [ ! -e "$src" ]; then
        echo -e "${YELLOW}警告: 源文件不存在，跳过: $src${NC}"
        return
    fi

    # 备份已存在的文件
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        mv "$dest" "$dest.backup.$(date +%s)"
        echo -e "已备份原文件: $dest -> $dest.backup..."
    fi

    # 创建软链接
    ln -sf "$src" "$dest"
    echo -e "已链接: $src -> $dest"
}

# 恢复 .zshrc
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# 恢复 .gitconfig
create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"

# 恢复 .config 下的配置
mkdir -p "$HOME/.config"
# 遍历仓库中的 .config 目录
if [ -d "$DOTFILES_DIR/.config" ]; then
    for config_path in "$DOTFILES_DIR/.config"/*; do
        dir_name=$(basename "$config_path")
        # 跳过 .DS_Store 等文件
        if [ "$dir_name" == ".DS_Store" ]; then continue; fi
        
        target_path="$HOME/.config/$dir_name"
        
        # 如果目标已存在且不是链接，先备份
        if [ -d "$target_path" ] && [ ! -L "$target_path" ]; then
             mv "$target_path" "$target_path.backup.$(date +%s)"
        fi
        
        ln -sf "$config_path" "$target_path"
        echo -e "已链接配置目录: .config/$dir_name"
    done
fi

# 恢复 Oh My Zsh 自定义插件/主题
if [ -d "$DOTFILES_DIR/oh-my-zsh-custom" ]; then
    echo -e "${BLUE}安装 Oh My Zsh 自定义插件/主题...${NC}"
    mkdir -p "$HOME/.oh-my-zsh/custom"
    cp -R "$DOTFILES_DIR/oh-my-zsh-custom/"* "$HOME/.oh-my-zsh/custom/"
    echo -e "${GREEN}已恢复 Oh My Zsh 自定义配置${NC}"
fi

echo -e "${GREEN}🎉 环境初始化完成！请重启终端或运行 'source ~/.zshrc'${NC}"