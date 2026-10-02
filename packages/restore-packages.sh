#!/usr/bin/env bash
# ============================================================
# 在新机器上恢复软件包
#   pacman-explicit.txt : 官方仓库显式安装的包
#   pacman-foreign.txt  : AUR / 本地构建的包
# 依赖: yay 或 paru (AUR helper)
# ============================================================
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

AUR_HELPER=""
for h in paru yay; do
    command -v "$h" >/dev/null 2>&1 && AUR_HELPER="$h" && break
done
if [ -z "$AUR_HELPER" ]; then
    echo "错误: 未找到 paru 或 yay, 请先安装其中一个 AUR helper" >&2
    exit 1
fi
echo "使用 AUR helper: $AUR_HELPER"

echo "==> 恢复官方仓库软件包"
sudo pacman -S --needed --noconfirm - < pacman-explicit.txt

echo "==> 恢复 AUR / 本地构建软件包 (跳过已安装)"
"$AUR_HELPER" -S --needed --noconfirm - < pacman-foreign.txt

echo "完成!"
