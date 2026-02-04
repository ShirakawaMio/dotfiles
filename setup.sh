#!/bin/bash

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$HOME/dotfiles"

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
    
    # 2. 安装基础软件
    echo -e "${BLUE}安装基础软件包 (git, neovim, kitty, zsh, ripgrep, node, python)...${NC}"
    brew install git neovim kitty zsh ripgrep node python
else
    echo -e "${BLUE}非 macOS 系统，跳过 Homebrew 安装。请手动安装基础软件。${NC}"
fi

# 3. 安装 Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${BLUE}安装 Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo -e "${GREEN}Oh My Zsh 已安装${NC}"
fi

# 4. 恢复配置文件 (使用软链接，这样修改实时生效)
echo -e "${BLUE}正在链接配置文件...${NC}"

create_symlink() {
    src="$1"
    dest="$2"
    
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
for dir in "nvim" "kitty"; do
    if [ -d "$DOTFILES_DIR/.config/$dir" ]; then
        # 注意：对于目录，我们通常链接整个目录
        # 如果目标目录已存在且不是链接，先备份
        if [ -d "$HOME/.config/$dir" ] && [ ! -L "$HOME/.config/$dir" ]; then
             mv "$HOME/.config/$dir" "$HOME/.config/$dir.backup.$(date +%s)"
        fi
        ln -sf "$DOTFILES_DIR/.config/$dir" "$HOME/.config/$dir"
        echo -e "已链接配置目录: .config/$dir"
    fi
done

# 恢复 Oh My Zsh 自定义插件/主题
if [ -d "$DOTFILES_DIR/oh-my-zsh-custom" ]; then
    cp -R "$DOTFILES_DIR/oh-my-zsh-custom/"* "$HOME/.oh-my-zsh/custom/"
    echo -e "${GREEN}已恢复 Oh My Zsh 自定义插件${NC}"
fi

echo -e "${GREEN}环境初始化完成！请重启终端或运行 'source ~/.zshrc'${NC}"
