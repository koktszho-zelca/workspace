# Git shortcuts usage

See the [repository README](../../README.md) for installation, updates, requirements, and general mgt commands.

## Enable the bundle

```bash
mgt plugin list
mgt plugin install git-shortcuts
```

Fresh installations expose only mgt. Activation uses the locally cached bundle, needs no network, and records `.mgt/enabled/git-shortcuts`. Existing identical files are accepted; conflicting files require `mgt plugin install git-shortcuts --force`. Back up local edits first. Symlinks and non-file destinations are refused. Documentation is not copied as a command.

Run these helpers inside the Git repository you want to work with.

## Quick reference

| Helper | Usage | Purpose |
| --- | --- | --- |
| cb | `cb` | Copy current branch name to clipboard |
| co | `co branch_name` | Find and check out a branch |
| co | `co -M new_branch_name` | Force-rename current local branch |
| db | `db [-f\|--force] branch_name` | Find and delete a local branch |
| lb | `lb` | List local branches |
| pb | `pb [branch_name]` | Pull into the current branch |
| po | `po branch_name` | Push a local branch and set upstream |
| sb | `sb branch_name` | Print a matching branch name |

## cb: copy the current branch

```bash
cb
```

Uses the first available clipboard tool: pbcopy, wl-copy, xclip, or clip.exe. Prints `Copied: branch-name` on success. Without a clipboard tool, prints an error and the branch name and exits with status 1. Detached HEAD reports HEAD rather than a branch name.

## lb: list local branches

```bash
lb
```

Runs `git branch`; remote branches are not listed.

## sb: search for a branch

```bash
sb feature/login
sb login
```

Prefers an exact local name, then the first case-insensitive local substring match. Only when no local match exists, searches cached origin branches using the same priorities. Does not fetch. Prints the name without origin/ or a trailing newline. No match exits with status 1. Multiple partial matches select the first rather than producing an ambiguity error.

## co: checkout or force-rename

```bash
co feature/login
co login
co -M feature/new-name
```

Normal mode resolves through the adjacent sb and runs git checkout. It inherits sb's local-first matching and cached-origin fallback. Remote tracking behavior depends on Git configuration.

`co -M new-name` runs `git branch -M -- new-name`, requiring exactly one valid new name. It bypasses sb and renames the current local branch without partial matching. Warning: it can replace an existing local target branch, subject to Git restrictions. It does not rename a remote branch or push changes.

## db: delete a local branch

```bash
db feature/login
db login
db -f login
db login -f
db --force login
db login --force
```

Searches local branches only, never origin. An exact case-sensitive name takes priority; otherwise uses case-insensitive substring matching. No match reports an error. Multiple partial matches lists every matching branch and exits without deleting anything, even with force. Specify an exact name to resolve ambiguity.

Normal mode runs `git branch -d -- matched-name`. Force uses -D, allowing unmerged branch deletion while preserving Git's other restrictions. Flags work before or after the name. Remote server branches are never deleted.

## pb: pull, not push

```bash
pb
pb login
```

Without an argument runs git pull using the configured upstream. With an argument resolves via sb and runs `git pull origin resolved-name`. Changes are pulled into the current branch, not the named branch. This does not switch branches. Git configuration controls reconciliation and conflicts may require resolution.

## po: push and set upstream

```bash
po feature/login
```

Requires exactly one valid, existing local branch name. Pushes it to the same-named branch on origin and sets upstream using an explicit branch-to-branch refspec, equivalent to `git push -u origin feature/login` here.

No partial matching, default branch, or force-push. Does not switch branches and can push a branch other than the currently checked-out one. Requires origin and push permission. Git reports authentication, network, and rejected-push errors directly.
