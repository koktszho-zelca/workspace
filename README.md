# Workspace

A command manager with an opt-in, locally bundled Git shortcuts plugin. See the [Git shortcuts usage guide](bin/git-shortcuts/USAGE.md) for Git command examples and behavior.

## Requirements

Bash, Git, and standard utilities including `readlink -f`, `mktemp`, `cmp`, and `sed`. Remote one-line commands also require curl. Installation needs write access to the destination and your shell configuration.

## Install mgt

Review remote scripts before executing them.

```bash
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/install.sh | bash
```

Fresh installations use `~/.local/bin` and expose only `mgt`. The seven Git helpers are cached under `<install_dir>/.mgt/plugins/git-shortcuts`, outside PATH, for offline activation. Documentation is not installed as a command.

Open a new terminal or reload the shell configuration selected by the installer: `.zshrc` when `$SHELL` identifies Zsh, otherwise `.bashrc`.

## Enable Git shortcuts

```bash
mgt plugin list
mgt plugin install git-shortcuts
mgt list
```

Activation copies `cb`, `co`, `db`, `lb`, `pb`, `po`, and `sb` into the command directory. All destination conflicts are checked before copying. Identical files are accepted. Conflicting files require explicit overwrite permission:

```bash
# Back up local changes first:
mgt plugin install git-shortcuts --force
```

Symlink and non-file destinations are refused. There is no plugin uninstall command yet. The enabled marker records activation; it does not verify that every command still exists.

## Custom destination or local checkout

```bash
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/install.sh | bash -s -- "$HOME/tools/bin"

# From the repository root:
bash install.sh "$HOME/tools/bin"
```

Pass the same custom destination to the updater. Omitting the destination uses `~/.local/bin`, except that the current scripts still prefer `~/.local/share/workspace/bin` if mgt exists there. Source checkouts are not used as the default destination.

## Update

```bash
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/update.sh | bash

# Custom destination:
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/update.sh | bash -s -- "$HOME/tools/bin"
```

Requires an existing mgt installation. Clones main into a temporary directory, refreshes mgt and its bundle, and cleans up on exit. Enabled plugins are refreshed. The current updater also refreshes existing top-level regular files named after the seven helpers, without enabling absent helpers. Same-named local modifications may be overwritten; back them up first.

Unrelated files remain. Copies are not atomic, so an error can leave a partial update. Root-level installer/updater files and documentation in old checkouts are not replaced by updating installed commands; use the latest remote updater.

## Manage local scripts

```bash
mgt list
mgt new my-helper
mgt edit my-helper
mgt delete my-helper
MGT_EDITOR=vim mgt edit my-helper
MGT_BIN_DIR="$HOME/tools/bin" mgt list
```

The default directory is the directory containing mgt. The default editor is nano; MGT_EDITOR must name an executable without embedded arguments. New/edit operations make files executable. Delete requires y or Y confirmation. List describes executable files using their second-line comments.

Use simple filenames, not paths. MGT_BIN_DIR overrides the command destination, including plugin activation; bundle lookup remains relative to mgt. Put custom destinations on PATH yourself when using this override. Changes are local and are not committed or pushed.

## Repository layout

```text
bin/
  mgt
  git-shortcuts/
    cb
    co
    db
    lb
    pb
    po
    sb
    USAGE.md
install.sh
update.sh
README.md
```

Git helper implementations live only in `bin/git-shortcuts/`; there are no duplicate top-level Git helpers. The installer preserves existing enabled helper commands and copies only mgt plus the seven cached bundle scripts. Use the updater to refresh enabled helpers.
