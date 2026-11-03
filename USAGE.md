# Script usage

See [README.md](README.md) for installation instructions. Run Git helpers inside the Git repository you want to work with. Examples assume the helper scripts are installed and on PATH.

## Quick reference

| Script | Usage | Purpose |
| --- | --- | --- |
| cb | `cb` | Copy the current branch name to the clipboard |
| co | `co branch_name` | Resolve a branch name and check it out |
| db | `db [-f\|--force] branch_name` | Search local branches and delete a unique match |
| lb | `lb` | List local branches |
| mgt | `mgt new/edit/delete name` or `mgt list` | Manage local helper scripts |
| pb | `pb [branch_name]` | Pull changes into the current branch |
| po | `po branch_name` | Push a local branch to origin and set upstream |
| sb | `sb branch_name` | Print a matching branch name |
| install.sh | `bash install.sh [install_dir]` | Install helpers and configure PATH |
| update.sh | `bash update.sh [install_dir]` | Refresh installed helpers using a temporary clone |

## cb: copy the current branch name

```bash
cb
```

Uses the first available clipboard tool: `pbcopy`, `wl-copy`, `xclip`, or `clip.exe`. On success, prints `Copied: branch-name`. If no clipboard tool is available, prints an error and the branch name, then exits with status 1. In detached HEAD state, Git reports `HEAD` instead of a branch name.

## lb: list local branches

```bash
lb
```

Runs `git branch`. It does not list remote branches.

## sb: search for a branch

```bash
sb feature/login
sb login
```

Search order:

1. Exact local branch name.
2. First case-insensitive local substring match.
3. If there is no local match, exact name among cached `origin` branches.
4. First case-insensitive substring match among cached `origin` branches.

Prints the branch name without an `origin/` prefix or trailing newline. Exits with status 1 when no match exists. Does not fetch from the remote. Unlike `db`, multiple partial matches do not produce an ambiguity warning: the first is selected.

## co: check out a matching branch

```bash
co feature/login
co login
```

Resolves the argument using the adjacent `sb` helper, then runs `git checkout` with the resolved name. Inherits `sb`'s local-first matching and cached-origin fallback. Checkout success and remote-branch tracking behavior depend on Git and repository configuration; the helper does not explicitly create a tracking branch.

## pb: pull changes

```bash
# Pull using the current branch's configured upstream:
pb

# Resolve a name using sb, then pull from origin:
pb feature/login
pb login
```

With no argument, runs `git pull`. With an argument, runs `git pull origin` with the name resolved by the adjacent `sb` helper.

This pulls changes into the current branch; it does not switch to the named branch. Pull reconciliation follows your Git configuration and may require conflict resolution. `pb` means pull, not push.

## po: push a local branch to origin

```bash
po feature/login
```

Pushes the exact local branch to the same-named branch on `origin` and sets its upstream, equivalent to `git push -u origin feature/login` for this example. The script uses an explicit branch-to-branch refspec to avoid ambiguity with tags.

Requires exactly one valid, existing local branch name. Does not use `sb`, partial matching, force-push, or a default branch. Does not switch branches; it can push a local branch other than the currently checked-out one. Requires an `origin` remote and permission to push. Git reports authentication, network, and rejected-push errors directly.

## db: delete a local branch

```bash
# Normal deletion:
db feature/login

# Partial name, provided it identifies one local branch:
db login

# Force deletion; flags work before or after the name:
db -f login
db login -f
db --force login
db login --force
```

Searches local branches only, never `origin` or other remote-tracking branches. Prefers an exact case-sensitive name; otherwise uses case-insensitive substring matching.

- No match: prints an error and exits without deleting anything.
- One match: runs `git branch -d -- matched-name`.
- Multiple partial matches: lists every match and exits without deleting anything, even with a force flag.
- An exact match takes priority over other partial matches.

`-f` or `--force` uses `git branch -D` instead of `-d`, allowing deletion of an unmerged local branch. Git still enforces its other restrictions. This never deletes a branch on the remote server.

Example ambiguity message:

```text
Multiple local branches match 'login'; use an exact name:
  feature/login
  fix/login-error
```

Then specify the exact name, for example `db feature/login`.

## mgt: manage helper scripts

```bash
mgt list
mgt new my-helper
mgt edit my-helper
mgt delete my-helper
```

- `list`: shows executable files and descriptions taken from their second line, stripping a leading comment marker.
- `new`: creates a Bash script, opens the editor, and makes the file executable. Refuses to overwrite an existing file.
- `edit`: opens an existing file and makes it executable afterward.
- `delete`: asks for confirmation; only `y` or `Y` deletes the file.

Defaults to the directory containing `mgt` and the `nano` editor. Override them with:

```bash
MGT_EDITOR=vim mgt edit my-helper
MGT_BIN_DIR="$HOME/.local/bin" mgt list
```

`MGT_EDITOR` should name an editor executable, not a command with embedded arguments. Use simple helper filenames, not paths. Changes are local; `mgt` does not commit or push them. Updates overwrite local changes to same-named repository scripts.

## install.sh: install helpers

```bash
bash install.sh
bash install.sh "$HOME/.local/bin"
```

Reuses an adjacent `bin` directory when present. Otherwise clones the public repository's `main` branch into `~/.local/share/workspace`. Without a destination argument, uses the checkout's `bin` directory; with an argument, copies `bin/*` there. Makes scripts executable and adds the destination to `.zshrc` or `.bashrc` based on `$SHELL`.

Standalone installation stops if the clone destination already exists. It does not automatically pull updates. Reload the appropriate shell configuration or open a new terminal after installation. Custom destinations are not saved for automatic discovery by the updater.

## update.sh: update installed helpers

```bash
bash update.sh
bash update.sh "$HOME/.local/bin"
```

Requires an existing destination directory. Without an argument, uses the adjacent `bin` directory if available; otherwise uses `~/.local/share/workspace/bin`. For custom installations, pass the same destination used during installation.

Clones `main` into a temporary directory, copies `bin/*` to the destination, makes copied scripts executable, and cleans up the temporary clone on exit. Overwrites matching files, including local modifications. Leaves unrelated files and scripts removed from the repository untouched.

Does not update root-level files such as `install.sh`, `update.sh`, or documentation, and does not change PATH. Copies files individually, so a copy error can leave a partially updated destination.

For remote installation and update commands, see [README.md](README.md). Review remote scripts before executing them.
