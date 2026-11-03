# Workspace

A command manager with an opt-in, locally bundled Git shortcuts plugin. See [USAGE.md](USAGE.md) for every command.

## Requirements

Bash, Git, and standard utilities including `readlink -f`, `mktemp`, `cmp`, and `sed`. Remote one-line commands also require curl. The installer needs write access to its destination and your shell configuration.

## Install mgt

Review remote scripts before executing them.

```bash
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/install.sh | bash
```

Fresh installations use `~/.local/bin`. Only `mgt` is exposed as a command. The Git helpers are bundled under `<install_dir>/.mgt/plugins/git-shortcuts`, outside PATH, ready for offline activation.

The installer adds the destination to `.zshrc` when `$SHELL` identifies Zsh, otherwise `.bashrc`. Open a new terminal or source the appropriate file.

```bash
mgt plugin list
mgt plugin install git-shortcuts
mgt list
```

Plugin installation copies `cb`, `co`, `db`, `lb`, `pb`, `po`, and `sb` into the directory containing mgt. Identical existing files are accepted; conflicting files require explicit `--force`. Symlink and non-file destinations are refused.

```bash
# Overwrites conflicting helper files; back up local changes first:
mgt plugin install git-shortcuts --force
```

## Custom destination or local checkout

```bash
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/install.sh | bash -s -- "$HOME/tools/bin"

# From a repository checkout:
bash install.sh "$HOME/tools/bin"
```

Omitting the destination no longer installs directly into a source checkout's bin directory. New installs use `~/.local/bin`. An existing legacy default at `~/.local/share/workspace/bin/mgt` takes priority and is reused. Pass custom destinations explicitly to both installer and updater.

## Update

```bash
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/update.sh | bash

# Custom destination:
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/update.sh | bash -s -- "$HOME/tools/bin"
```

The updater requires an existing mgt installation. It clones main into a temporary directory, refreshes mgt and the bundled plugin, and cleans up the clone on exit. It reuses the legacy default when present, otherwise `~/.local/bin`.

Enabled plugins are refreshed. Existing legacy Git helpers remain available and are updated individually, without enabling previously absent helpers. Legacy detection uses the known filenames `cb`, `co`, `db`, `lb`, `pb`, `po`, and `sb`; same-named regular files are treated as legacy helpers and may be overwritten. Back up local modifications before updating. Unrelated files are retained. Updates copy files individually and are not atomic.

## Repository layout

```text
bin/
  mgt
  git-shortcuts/
    cb co db lb pb po sb
install.sh
update.sh
README.md
USAGE.md
```

For migration compatibility, old flat copies of the Git helpers are retained in `bin/` for now. The new installer ignores them and uses `bin/git-shortcuts/` as the plugin source. Existing enabled commands are not removed.

## Local script management

```bash
mgt new my-helper
mgt edit my-helper
mgt delete my-helper
```

## Notes

Installation and update can overwrite mgt and cached bundle files. The installer preserves existing top-level Git helper commands; use the updater to refresh them. Root-level installer/updater files in old clones are not automatically replaced: use the remote update command above for migration. Old installer/updater versions do not understand the nested plugin layout.
