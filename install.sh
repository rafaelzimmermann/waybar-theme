#!/bin/bash
set -e

WAYBAR_THEME_DIR="$(cd "$(dirname "$0")" && pwd)"
DEST="$HOME/.config/waybar"

echo "→ Setting default theme (catppuccin-mocha)..."
cp "$WAYBAR_THEME_DIR/themes/catppuccin-mocha.css" "$WAYBAR_THEME_DIR/theme.css"

echo "→ Copying waybar config to $DEST..."
mkdir -p "$DEST"
cp "$WAYBAR_THEME_DIR/config.jsonc" "$DEST/"
cp "$WAYBAR_THEME_DIR/style.css"    "$DEST/"
cp "$WAYBAR_THEME_DIR/theme.css"    "$DEST/"
cp -r "$WAYBAR_THEME_DIR/modules"   "$DEST/"
cp -r "$WAYBAR_THEME_DIR/styles"    "$DEST/"
cp -r "$WAYBAR_THEME_DIR/scripts"   "$DEST/"
cp -r "$WAYBAR_THEME_DIR/themes"    "$DEST/"
cp -r "$WAYBAR_THEME_DIR/icons"     "$DEST/"

echo "→ Restarting waybar..."
pkill waybar || true
setsid waybar &>/dev/null &

echo "Done."
