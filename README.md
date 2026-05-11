# Clipboard Sync (Wayland ↔ X11)

niri / XWayland 环境下 Wayland ↔ X11 剪贴板双向同步工具，兼容微信、QQ 等 XWayland 应用。

## 功能

- **纯文字同步**: UTF-8 文本双向同步，自动补全 `charset=utf-8` 声明（修复 Ghostty/GTK4 中文粘贴乱码）
- **图片同步**: PNG/JPEG 双向同步
- **文件链接同步**: `text/uri-list` ↔ `x-special/gnome-copied-files`
- **微信图片同步**: `application/x-qt-image` 类型文件链接
- **HTML 富文本同步**: QQ/微信富文本内容（同步 HTML 的同时保留纯文本副本）

## 依赖

```bash
sudo apt install wl-clipboard xclip xxhash clipnotify
```

## 文件说明

| 文件 | 作用 |
|------|------|
| `clipsync` | 主入口，启动 x2w 和 w2x 两个子进程 |
| `clipsync-x2w` | X11 → Wayland 同步（监听 `clipnotify` 信号） |
| `clipsync-w2x` | Wayland → X11 同步（`wl-paste --watch` 监听） |
| `screenshot.sh` | grim + slurp + swappy 截图工具（独立功能） |

## 安装

```bash
sudo cp clipsync clipsync-x2w clipsync-w2x /usr/bin/
sudo chmod +x /usr/bin/clipsync /usr/bin/clipsync-x2w /usr/bin/clipsync-w2x
sudo cp clipsync.service /usr/lib/systemd/user/
systemctl --user enable --now clipsync
```

## 关键设计决策

### charset=utf-8 强制声明

微信等 XWayland 应用复制文字时，通过 XWayland bridge 传到 Wayland 的 MIME type 是 `text/plain`（不带 `charset=utf-8`）。Ghostty 1.3.1 的 GTK4 后端会优先请求 `text/plain;charset=utf-8`，找不到后回退到无 charset 的 `text/plain`，GTK 默认按 Latin-1 解码 UTF-8 字节，导致中文变成 `\E5\88\66...` 转义序列。

`clipsync-x2w` 在同步纯文字到 Wayland 时，始终使用 `wl-copy --type text/plain;charset=utf-8`，确保 GTK4 应用能正确解码。即使内容哈希一致（XWayland bridge 已同步），也会检查 Wayland 是否缺少 charset 声明并强制覆盖。

### XWayland 竞态重试

XWayland 应用的剪贴板数据通过 bridge 传递有延迟，`xclip` 首次读取可能返回空。`clipsync-x2w` 在读取为空时会等待 0.3s 后重试一次。

### HTML 分支优先级

`clipsync-w2x` 的 HTML 分支条件为 `text/html` 存在且 `text/plain` 不存在时才匹配。微信/QQ 复制文字时同时提供 `text/html` + `text/plain`，走纯文本分支处理，避免 HTML 覆盖纯文本。

## 截图工具（独立功能）

grim + slurp + swappy 截图工具，支持自动复制到 Wayland 和 X11 剪贴板。

```bash
./screenshot.sh area     # 区域截图 (默认)
./screenshot.sh screen   # 全屏截图
./screenshot.sh window   # 窗口截图
```

niri 快捷键配置：

```kdl
binds {
    Print { spawn "sh" "-c" "$HOME/.local/bin/screenshot.sh area"; }
    Ctrl+Print { spawn "sh" "-c" "$HOME/.local/bin/screenshot.sh screen"; }
    Alt+Print { spawn "sh" "-c" "$HOME/.local/bin/screenshot.sh window"; }
}
```
