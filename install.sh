#!/bin/bash
# Usage: ./install.sh [install_dir]
# Also supports: curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/install.sh | bash -s -- [install_dir]
# Reuses an adjacent bin directory, otherwise clones into ~/.local/share/workspace.
set -e

REPO_URL="https://github.com/koktszho-zelca/workspace.git"
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
REPO_DIR=""

if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
  REPO_DIR="$(cd "$(dirname "$(readlink -f "$SCRIPT_PATH")")" && pwd)"
fi

if [ -z "$REPO_DIR" ] || [ ! -d "$REPO_DIR/bin" ]; then
  command -v git >/dev/null 2>&1 || {
    echo "Git is required. Please install git and try again." >&2
    exit 1
  }
  REPO_DIR="$HOME/.local/share/workspace"
  if [ -e "$REPO_DIR" ] || [ -L "$REPO_DIR" ]; then
    echo "Clone destination already exists: $REPO_DIR" >&2
    echo "Run its install.sh if it is a workspace checkout, or choose a different location by cloning manually." >&2
    exit 1
  fi
  mkdir -p "$(dirname "$REPO_DIR")"
  git clone --depth 1 --branch main "$REPO_URL" "$REPO_DIR"
fi

SRC_BIN="$REPO_DIR/bin"
if [ ! -d "$SRC_BIN" ]; then
  echo "bin folder not found at $SRC_BIN" >&2
  exit 1
fi

if [ -n "${1:-}" ]; then
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
