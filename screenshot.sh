#!/bin/bash
# 截图脚本 - 直接写入 Wayland + X11 剪贴板
# 用法: screenshot.sh [area|screen|window]

MODE="${1:-area}"
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
FILEPATH="$SCREENSHOT_DIR/screenshot_${TIMESTAMP}.png"

notify() {
    notify-send "Screenshot" "$1" --icon=screenshot-recorded 2>/dev/null || true
}

copy_to_clipboards() {
    # 杀掉之前的 wl-copy/xclip 避免残留
    pkill -f "wl-copy --type image/png" 2>/dev/null
    # 写入 Wayland 剪贴板 (后台保持数据存活)
    cat "$1" | wl-copy --type image/png &
    # 写入 X11 剪贴板 (loops=2 允许被读取2次后退出)
    xclip -selection clipboard -t image/png -i "$1" -loops 2 2>/dev/null &
    sleep 0.5
}

if [ "$MODE" = "area" ]; then
    GRIM_FILE=$(mktemp --suffix=.png)
    grim -g "$(slurp -d)" "$GRIM_FILE" 2>/dev/null
    if [ $? -eq 0 ] && [ -s "$GRIM_FILE" ]; then
        swappy -f "$GRIM_FILE" -o "$FILEPATH" 2>/dev/null
        if [ -f "$FILEPATH" ]; then
            copy_to_clipboards "$FILEPATH"
            notify "Saved: $FILEPATH"
        else
            LATEST=$(ls -t "$SCREENSHOT_DIR"/screenshot_*.png 2>/dev/null | head -1)
            if [ -n "$LATEST" ] && [ "$LATEST" -nt "$GRIM_FILE" ]; then
                copy_to_clipboards "$LATEST"
                notify "Saved: $LATEST"
            else
                notify "Screenshot cancelled"
            fi
        fi
    else
        notify "Screenshot cancelled"
    fi
    rm -f "$GRIM_FILE" 2>/dev/null
elif [ "$MODE" = "screen" ]; then
    grim "$FILEPATH" 2>/dev/null
    if [ $? -eq 0 ] && [ -s "$FILEPATH" ]; then
        copy_to_clipboards "$FILEPATH"
        notify "Saved: $FILEPATH"
    fi
elif [ "$MODE" = "window" ]; then
    WINDOW_GEOM=$(slurp -o 2>/dev/null)
    if [ -n "$WINDOW_GEOM" ]; then
        grim -g "$WINDOW_GEOM" "$FILEPATH" 2>/dev/null
        if [ $? -eq 0 ] && [ -s "$FILEPATH" ]; then
            copy_to_clipboards "$FILEPATH"
            notify "Saved: $FILEPATH"
        fi
    fi
fi
