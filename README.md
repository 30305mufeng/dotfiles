# muf 的 dotfiles

Arch Linux + Hyprland (HyDE) 桌面环境配置, 用于快速迁移到新机器。

## 环境概览

| 组件 | 选择 |
|---|---|
| WM | Hyprland 0.55+ (HyDE / hyprdots 框架) |
| GPU | Intel UHD 620 + NVIDIA MX150 (混合显卡, 见 `config/hypr/nvidia.conf`) |
| 终端 | kitty |
| Shell | zsh + oh-my-zsh |
| Bar | waybar |
| 启动器 | rofi |
| 通知 | dunst |
| 输入法 | fcitx5 (拼音) |
| 壁纸 | swww (HyDE wallbash) |
| 主题 | Tokyo Night (GTK: ~/.themes, 图标: ~/.icons) |

## 仓库结构

```
├── install.sh               # 部署脚本: 备份现有配置并符号链接本仓库
├── packages/
│   ├── pacman-explicit.txt  # 官方仓库包列表 (pacman -Qqe)
│   ├── pacman-foreign.txt   # AUR 包列表 (pacman -Qqm)
│   └── restore-packages.sh  # 新机器一键恢复软件包
├── config/                  # -> ~/.config/  (hypr, hyde, kitty, waybar, rofi,
│                            #    dunst, fastfetch, fcitx5, wlogout, swaylock,
│                            #    swappy, qt5ct, qt6ct, gtk-3.0, xsettingsd,
│                            #    mimeapps.list, *-flags.conf ...)
├── home/                    # -> ~/  (.zshrc, .vimrc, .vim/, .gitconfig, .ssh/config)
└── local/share/             # -> ~/.local/share/  (bin: HyDE 脚本, fonts: 字体, applications: 自定义桌面项)
```

## 新机器迁移步骤

```bash
# 1. 基础系统装好后, 先装 AUR helper
sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si

# 2. 恢复软件包 (含 hyde-cli-git, hyprland, waybar, kitty 等)
git clone <本仓库地址> ~/dotfiles && cd ~/dotfiles
./packages/restore-packages.sh

# 3. 安装 HyDE 资源 (GTK 主题/图标/HyDE 脚本与默认配置)
#    hyde-cli 安装后执行交互式安装, 或手动:
#    git clone https://github.com/HyDE-Project/HyDE && cd HyDE && ./install.sh

# 4. 部署本仓库配置 (自动备份被替换的原有配置)
./install.sh

# 5. 单独拷贝壁纸 (体积大, 不入 git)
#    ~/Pictures
#    ~/.config/hyde/themes/*/wallpapers

# 6. 重新登录 Hyprland (env 输入法变量等需要重登生效)
```

## 本机日常使用

部署后 `~/.config/hypr` 等位置都是指向本仓库的符号链接, 直接编辑即改仓库:

```bash
cd ~/dotfiles
git status          # 查看改动 (waybar/hyde 的主题切换器会重写部分生成文件)
git add -A && git commit -m "update: xxx"
```

改完 Hyprland 配置即时生效: `hyprctl reload`

## 常用快捷键 (Super = Win 键)

| 按键 | 功能 |
|---|---|
| Alt+Enter | 终端 (kitty) |
| Super+Return | 全屏 |
| Super+Q | 关闭窗口 |
| Super+E / C / B / T | 文件 / 编辑器 / 浏览器 / Typora |
| Super+A / Tab | rofi 应用 / 窗口切换 |
| Super+V | 剪贴板历史 |
| Super+P | 截图选区 |
| Super+S | 特殊工作区 (scratchpad) |
| Super+L | 锁屏 |
| Super+Delete | 退出 Hyprland |
| Super+Alt+方向 | 切壁纸 / waybar 模式 |
| Ctrl+Alt+W | 开关 waybar |

## 注意事项

- **显示器配置**在 `config/hypr/monitors.conf`, 换机器只需改这一个文件
- **NVIDIA 相关**环境变量在 `config/hypr/nvidia.conf` (MX150 无硬件光标等设定); 纯 Intel/AMD 机器可清空该文件
- blur 已在 `userprefs.conf` 中全局关闭 (老 GPU 换性能), 需要时改回 `enabled = true`
- `~/.themes` (GTK 主题) 与 `~/.icons` (图标/光标) 体积过大未入库, 由 HyDE 安装步骤恢复
- vim: 插件 (`~/.vim/plugged`) 与 coc 扩展缓存 (`~/.config/coc`) 未入库, 迁移后在 vim 中执行 `:PlugInstall`, coc 扩展首次启动自动安装
- **ssh 只收录 config, 密钥不入库**: 迁移后需单独拷贝 `~/.ssh/id_ed25519`(及 `.pub`、`*.pem`) 并 `chmod 600`
- clash 配置含订阅令牌未入库, 迁移时单独拷贝 `~/.config/clash`
- VS Code / JetBrains 等 IDE 设置属个人状态未入库
- fcitx5 输入法 env 变量 (`QT_IM_MODULE` / `XMODIFIERS` / `GTK_IM_MODULE`) 在 `hyprland.conf`, 修改后需重新登录
