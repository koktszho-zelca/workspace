#!/bin/bash
# Usage: ./install.sh [install_dir]
# With install_dir: copies bin/* into it and adds it to PATH.
# Without: uses the bin folder inside this git clone.
set -e

REPO_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
SRC_BIN="$REPO_DIR/bin"

if [ ! -d "$SRC_BIN" ]; then
  echo "bin folder not found at $SRC_BIN" >&2
  exit 1
fi

if [ -n "$1" ]; then
  TARGET="${1/#\~/$HOME}"
  mkdir -p "$TARGET"
  TARGET="$(cd "$TARGET" && pwd)"
  if [ "$TARGET" != "$SRC_BIN" ]; then
    cp -f "$SRC_BIN"/* "$TARGET"/
  fi
else
  TARGET="$SRC_BIN"
fi

chmod a+x "$TARGET"/*

case "$(basename "${SHELL:-bash}")" in
  zsh) RC="$HOME/.zshrc" ;;
  *)   RC="$HOME/.bashrc" ;;
esac

LINE="export PATH=\"\$PATH:$TARGET\""
touch "$RC"
if grep -qxF "$LINE" "$RC"; then
  echo "PATH entry already exists in $RC"
else
  printf '\n# workspace helper scripts\n%s\n' "$LINE" >> "$RC"
  echo "Added $TARGET to PATH in $RC"
fi

echo "Installed to: $TARGET"
echo "Run: source $RC   (or open a new terminal)"
