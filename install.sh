#!/bin/bash
# Usage: bash install.sh [install_dir]; installs mgt with an opt-in plugin bundle
set -e
[ "$#" -le 1 ] || { echo "Usage: bash install.sh [install_dir]" >&2; exit 1; }
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
REPO_DIR=""
if [ -n "$SCRIPT_PATH" ] && [ -f "$SCRIPT_PATH" ]; then
  REPO_DIR="$(cd "$(dirname "$(readlink -f "$SCRIPT_PATH")")" && pwd)"
fi
if [ -n "${1:-}" ]; then
  TARGET="${1/#\~/$HOME}"
elif [ -f "$HOME/.local/share/workspace/bin/mgt" ]; then
  TARGET="$HOME/.local/share/workspace/bin"
else
  TARGET="$HOME/.local/bin"
fi
TEMP_DIR=""
trap '[ -z "$TEMP_DIR" ] || rm -rf -- "$TEMP_DIR"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
if [ -z "$REPO_DIR" ] || [ ! -f "$REPO_DIR/bin/mgt" ] || [ ! -d "$REPO_DIR/bin/git-shortcuts" ]; then
  command -v git >/dev/null 2>&1 || { echo "Git is required." >&2; exit 1; }
  TEMP_DIR=$(mktemp -d)
  git clone --depth 1 --branch main https://github.com/koktszho-zelca/workspace.git "$TEMP_DIR/workspace"
  REPO_DIR="$TEMP_DIR/workspace"
fi
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"
[ ! -L "$TARGET/mgt" ] || { echo "Refusing symlink: $TARGET/mgt" >&2; exit 1; }
BUNDLE="$TARGET/.mgt/plugins/git-shortcuts"
mkdir -p "$BUNDLE"
if [ "$TARGET" != "$REPO_DIR/bin" ]; then
  cp -f "$REPO_DIR/bin/mgt" "$TARGET/mgt"
fi
chmod a+x "$TARGET/mgt"
for FILE in "$REPO_DIR/bin/git-shortcuts"/*; do
  [ -f "$FILE" ] && [ ! -L "$FILE" ] || { echo "Invalid plugin file: $FILE" >&2; exit 1; }
  DEST="$BUNDLE/$(basename "$FILE")"
  [ ! -L "$DEST" ] || { echo "Refusing symlink: $DEST" >&2; exit 1; }
  cp -f "$FILE" "$DEST"
  chmod a+x "$DEST"
done
case "$(basename "${SHELL:-bash}")" in zsh) RC="$HOME/.zshrc" ;; *) RC="$HOME/.bashrc" ;; esac
printf -v ESCAPED '%q' "$TARGET"
LINE="export PATH=\"\$PATH\":$ESCAPED"
touch "$RC"
if ! grep -qxF "$LINE" "$RC"; then
  printf '\n# workspace command manager\n%s\n' "$LINE" >> "$RC"
fi
echo "Installed mgt in: $TARGET"
echo "Existing commands were preserved; bundled Git helpers were not enabled."
echo "Reload $RC or open a new terminal, then run: mgt plugin install git-shortcuts"
