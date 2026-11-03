#!/bin/bash
# Usage: bash update.sh [install_dir]; refresh mgt and enabled Git shortcuts
set -e
[ "$#" -le 1 ] || { echo "Usage: bash update.sh [install_dir]" >&2; exit 1; }
if [ -n "${1:-}" ]; then
  TARGET="${1/#\~/$HOME}"
elif [ -f "$HOME/.local/share/workspace/bin/mgt" ]; then
  TARGET="$HOME/.local/share/workspace/bin"
else
  TARGET="$HOME/.local/bin"
fi
[ -f "$TARGET/mgt" ] || { echo "mgt installation not found: $TARGET. Pass your install directory." >&2; exit 1; }
TARGET="$(cd "$TARGET" && pwd)"
command -v git >/dev/null 2>&1 || { echo "Git is required." >&2; exit 1; }
TEMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$TEMP_DIR"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
git clone --depth 1 --branch main https://github.com/koktszho-zelca/workspace.git "$TEMP_DIR/workspace"
ENABLED=false
[ ! -f "$TARGET/.mgt/enabled/git-shortcuts" ] || ENABLED=true
LEGACY=()
for NAME in cb co db lb pb po sb; do
  if [ -f "$TARGET/$NAME" ] && [ ! -L "$TARGET/$NAME" ]; then
    LEGACY+=("$NAME")
  fi
done
bash "$TEMP_DIR/workspace/install.sh" "$TARGET"
if [ "$ENABLED" = true ]; then
  MGT_BIN_DIR="$TARGET" bash "$TARGET/mgt" plugin install git-shortcuts --force
else
  for NAME in "${LEGACY[@]}"; do
    cp -f "$TARGET/.mgt/plugins/git-shortcuts/$NAME" "$TARGET/$NAME"
    chmod a+x "$TARGET/$NAME"
  done
fi
echo "Updated mgt, the plugin bundle, and previously enabled Git helpers in: $TARGET"
echo "Same-named helper modifications may have been overwritten."
