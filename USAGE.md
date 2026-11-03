# Script usage

See [README.md](README.md) for installation, update, migration, and requirements.

## Enable the bundled Git helpers

```bash
mgt plugin list
mgt plugin install git-shortcuts
mgt plugin install git-shortcuts --force
```

Fresh installation exposes only mgt. Activation copies the local bundle into the command directory and records an enabled marker under `.mgt/enabled/git-shortcuts`. It needs no network. All destination conflicts are checked before copying. Identical files are accepted; differing files require `--force`. Symlinks and non-file destinations are refused. Copy failures can still leave a partially installed plugin. There is no plugin uninstall command yet.

## Quick reference

| Command | Usage | Purpose |
| --- | --- | --- |
| mgt | `mgt list` | List executable files in the command directory |
| cb | `cb` | Copy current branch name to the clipboard |
| co | `co branch_name` | Find and check out a branch |
| co | `co -M new_branch_name` | Force-rename the current local branch |
| db | `db [-f\|--force] branch_name` | Find and delete a local branch |
| lb | `lb` | List local branches |
| pb | `pb [branch_name]` | Pull changes into the current branch |
| po | `po branch_name` | Push a local branch and set its upstream |
| sb | `sb branch_name` | Print a matching branch name |

Run Git helpers inside the repository you want to work with.

## mgt: manage local scripts

```bash
mgt list
mgt new my-helper
mgt edit my-helper
mgt delete my-helper
MGT_EDITOR=vim mgt edit my-helper
MGT_BIN_DIR="$HOME/tools/bin" mgt list
```

Defaults to the directory containing mgt and the nano editor. New/edit operations make files executable. Delete requires y or Y confirmation. List shows executable files with their second-line comments as descriptions. Use simple filenames, not paths. MGT_EDITOR names an editor executable, without embedded arguments. MGT_BIN_DIR changes the destination command directory, including plugin activation; the bundle is located relative to mgt itself. That custom destination must already be on PATH to invoke its commands directly. Local edits are not committed or pushed.

## cb: clipboard

```bash
cb
```

Uses the first available tool: pbcopy, wl-copy, xclip, or clip.exe. Prints `Copied: branch-name` on success. If none exists, prints an error and the branch name and exits with status 1. Detached HEAD reports HEAD rather than a branch name.

## lb: list branches

```bash
lb
```

Runs `git branch`, listing local branches only.

## sb: find a branch

```bash
sb feature/login
sb login
```

Searches local branches first: exact name, then the first case-insensitive substring match. Only if no local match exists, searches cached origin branches the same way. Does not fetch. Prints the name without origin/ or a trailing newline. No match exits with status 1. Multiple partial matches select the first; unlike db, sb does not reject ambiguity.

## co: checkout or rename

```bash
co login
co feature/login
co -M feature/new-name
```

Normal mode resolves the name using the adjacent sb and runs git checkout. It inherits sb's local-first search and cached-origin fallback. Remote tracking behavior depends on Git configuration.

`co -M new-name` runs `git branch -M -- new-name` directly, without lookup. It requires exactly one valid new name and force-renames the current local branch. It can replace an existing local target branch, subject to Git restrictions. It does not rename anything on the remote or push changes.

## db: delete a local branch

```bash
db feature/login
db login
db -f login
db login -f
db --force login
db login --force
```

Searches local branches only. Exact case-sensitive names take priority over case-insensitive substring matches. Zero matches reports an error. Multiple partial matches lists every match and exits without deleting anything, even with force. Specify an exact name to resolve ambiguity.

Normal mode runs `git branch -d -- matched-name`. Force uses `-D`, allowing deletion of an unmerged branch while retaining Git's other restrictions. Flags may appear before or after the name. Remote server branches are never deleted.

## pb: pull, not push

```bash
pb
pb login
```

Without an argument runs git pull using the configured upstream. With an argument resolves through sb and runs `git pull origin resolved-name`. This pulls into the current branch, not the named branch, and never switches branches. Git configuration governs reconciliation; conflicts may require resolution.

## po: push and set upstream

```bash
po feature/login
```

Requires exactly one valid existing local branch name. Pushes that branch to the same-named branch on origin and sets upstream, using an explicit branch-to-branch refspec. Equivalent to `git push -u origin feature/login` for this example. No partial matching, force-push, or default branch. Does not switch branches. Requires origin and push permission; Git reports authentication, network, and rejected-push errors.

## Install and update

```bash
bash install.sh
bash install.sh "$HOME/tools/bin"
bash update.sh
bash update.sh "$HOME/tools/bin"
```

New default destination: ~/.local/bin. Existing legacy default ~/.local/share/workspace/bin is reused when mgt is present there. Custom destinations must be passed explicitly; they are not discovered automatically. Installer installs mgt and a hidden plugin bundle, adds the destination to shell startup PATH, and preserves existing helper commands. Updater clones into a temporary directory, refreshes the manager and bundle, and updates enabled plugins or existing legacy helper filenames. Local modifications may be overwritten. Unrelated files remain; removed upstream scripts are not automatically deleted. Root-level documentation and installer/updater files are not refreshed. Use the remote commands in README for old-checkout migration.
