#!/usr/bin/env bash
# ============================================================
# dotfiles 安装脚本
# 将仓库中的配置以符号链接方式部署到 ~/.config、~/ 等 position
# 已存在的同名文件/目录会先备份到 ~/.config/cfg_backups/dotfiles-<时间戳>/
# ============================================================
set -euo pipefail

DOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.config/cfg_backups/dotfiles-$STAMP"

backup_and_link() {
    local src="$1" dst="$2"
    # 已经指向本仓库则跳过
    if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
        echo "  [ok] $dst (已链接)"
        return
    fi
    # 备份已存在的目标
    if [ -e "$dst" ] || [ -L "$dst" ]; then
        local rel="${dst#"$HOME"/}"
        mkdir -p "$BACKUP/$(dirname "$rel")"
        mv "$dst" "$BACKUP/$rel"
        echo "  [备份] $dst -> $BACKUP/$rel"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "  [链接] $dst -> $src"
}

echo "==> 部署 ~/.config 下的配置"
for entry in "$DOT"/config/*; do
    name="$(basename "$entry")"
    backup_and_link "$entry" "$HOME/.config/$name"
done

echo "==> 部署 HOME 目录文件 (shell 等)"
for entry in "$DOT"/home/.[!.]* "$DOT"/home/*; do
    [ -e "$entry" ] || continue
    name="$(basename "$entry")"
    backup_and_link "$entry" "$HOME/$name"
done

echo "==> 部署 ~/.local/share (脚本与字体)"
for entry in "$DOT"/local/share/*; do
    name="$(basename "$entry")"
    backup_and_link "$entry" "$HOME/.local/share/$name"
done

echo ""
echo "完成! 备份位置: $BACKUP"
echo "后续步骤:"
echo "  1. 安装软件包:    ./packages/restore-packages.sh"
echo "  2. 重新登录 Hyprland 会话使 env 变量生效"
echo "  3. 壁纸需单独拷贝: ~/Pictures 及 config/hyde/themes/*/wallpapers"
