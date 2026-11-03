#!/bin/bash
# Usage: bash update.sh [install_dir]
# Defaults to the adjacent bin directory, or ~/.local/share/workspace/bin.
# For a custom installation, pass the same directory used with install.sh.
set -e

REPO_URL="https://github.com/koktszho-zelca/workspace.git"
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
REPO_DIR=""

command -v git >/dev/null 2>&1 || {
  echo "Git is required. Please install git and try again." >&2
  exit 1
}

if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
  REPO_DIR="$(cd "$(dirname "$(readlink -f "$SCRIPT_PATH")")" && pwd)"
fi

if [ -n "${1:-}" ]; then
  TARGET="${1/#\~/$HOME}"
elif [ -n "$REPO_DIR" ] && [ -d "$REPO_DIR/bin" ]; then
  TARGET="$REPO_DIR/bin"
else
  TARGET="$HOME/.local/share/workspace/bin"
fi

if [ ! -d "$TARGET" ]; then
  echo "Installation directory not found: $TARGET" >&2
  echo "Run install.sh first, or pass your existing installation directory." >&2
  exit 1
fi
TARGET="$(cd "$TARGET" && pwd)"

TEMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEMP_DIR"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

git clone --depth 1 --branch main "$REPO_URL" "$TEMP_DIR/workspace"
SRC_BIN="$TEMP_DIR/workspace/bin"
shopt -s nullglob
SCRIPTS=("$SRC_BIN"/*)
if [ "${#SCRIPTS[@]}" -eq 0 ]; then
  echo "No scripts found in the cloned repository." >&2
  exit 1
fi

for SCRIPT in "${SCRIPTS[@]}"; do
  if [ ! -f "$SCRIPT" ]; then
    echo "Expected a script file: $SCRIPT" >&2
    exit 1
  fi
done

for SCRIPT in "${SCRIPTS[@]}"; do
  DEST="$TARGET/$(basename "$SCRIPT")"
  cp -f "$SCRIPT" "$DEST"
  chmod a+x "$DEST"
done

echo "Updated ${#SCRIPTS[@]} scripts in: $TARGET"
echo "Existing same-named scripts were overwritten; unrelated files were left untouched."
