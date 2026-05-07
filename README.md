# Screenshot Tool for Wayland (niri)

 grim + slurp + swappy 截图工具，支持自动复制到 Wayland 和 X11 剪贴板。

解决 niri / xwayland-satellite 环境下 Wayland ↔ X11 剪贴板图片数据不同步的问题。

## 功能

- **区域截图**: 选择区域 → swappy 标注 → 保存 + 复制到剪贴板
- **全屏截图**: 一键全屏 → 保存 + 复制到剪贴板
- **窗口截图**: 选择窗口 → 保存 + 复制到剪贴板
- 同时写入 Wayland (`wl-copy`) 和 X11 (`xclip`) 剪贴板
- 兼容 QQ、微信等 XWayland (Electron) 应用

## 依赖

```bash
sudo apt install grim slurp swappy wl-clipboard xclip
```

## 安装

```bash
git clone https://github.com/chao/screenshot-tool.git
cd screenshot-tool
cp screenshot.sh ~/.local/bin/screenshot.sh
chmod +x ~/.local/bin/screenshot.sh
```

## niri 快捷键配置

在 `~/.config/niri/config.kdl` 的 binds 中添加：

```kdl
binds {
    Print { spawn "sh" "-c" "$HOME/.local/bin/screenshot.sh area"; }
    Ctrl+Print { spawn "sh" "-c" "$HOME/.local/bin/screenshot.sh screen"; }
    Alt+Print { spawn "sh" "-c" "$HOME/.local/bin/screenshot.sh window"; }
}
```

## 用法

```bash
screenshot.sh area     # 区域截图 (默认)
screenshot.sh screen   # 全屏截图
screenshot.sh window   # 窗口截图
```

## 剪贴板同步 (可选)

如需 Wayland ↔ X11 双向剪贴板同步（文本、图片、文件），可配合 [clipsync](https://github.com/123hi123/clipsync) 使用：

```bash
sudo apt install wl-clipboard xclip xxhash
# clipnotify 需要手动编译，见 clipsync README
systemctl --user enable --now clipsync
```
