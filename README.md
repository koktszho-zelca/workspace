# Workspace

Command-line helper scripts for your development workspace.

## Requirements

- Bash and Git.
- curl for the one-line installer and updater.
- Standard command-line utilities, including readlink with support for `-f` and mktemp.
- Write access to the destination directory; installation also requires write access to your shell configuration file.

## Quick install

Review `install.sh` before running remote code. To install:

```bash
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/install.sh | bash
```

The installer clones the public repository over HTTPS into `~/.local/share/workspace` and adds its `bin` directory to PATH. No GitHub authentication is needed for the public clone.

Open a new terminal after installation, or reload your shell configuration:

```bash
# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc
```

Run only the command for your shell.

## Install into a custom directory

```bash
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/install.sh | bash -s -- "$HOME/.local/bin"
```

The repository is still cloned into `~/.local/share/workspace`. The helper scripts are copied into the specified directory, made executable, and that directory is added to PATH. Existing same-named files in the target directory are overwritten.

## Install from a local checkout

```bash
git clone https://github.com/koktszho-zelca/workspace.git
cd workspace
bash install.sh
```

When run from a checkout, the installer reuses its adjacent `bin` directory instead of cloning again. You can also copy scripts into a custom directory:

```bash
bash install.sh "$HOME/.local/bin"
```

## Installer behavior

- Standalone installation clones the `main` branch with `--depth 1`.
- If `~/.local/share/workspace` already exists, standalone installation stops rather than overwriting it. For an existing checkout, run its installer directly:

  ```bash
  bash "$HOME/.local/share/workspace/install.sh"
  ```

- The installer does not automatically pull updates to an existing checkout. Use the updater below to refresh installed helper scripts.
- PATH is configured in `~/.zshrc` when `$SHELL` identifies Zsh; otherwise it uses `~/.bashrc`.
- An identical PATH configuration line is not added twice.

## Updating

Review `update.sh` before running remote code.

### Default installation

```bash
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/update.sh | bash
```

When piped into Bash without an argument, the updater targets `~/.local/share/workspace/bin`.

### Custom installation directory

Pass the same destination used during installation:

```bash
curl -fsSL https://raw.githubusercontent.com/koktszho-zelca/workspace/main/update.sh | bash -s -- "$HOME/.local/bin"
```

The installer does not save custom destination choices, so the updater cannot discover them automatically.

### From a local checkout

If `update.sh` is present in your checkout, run:

```bash
bash update.sh

# Or specify your installed scripts directory:
bash update.sh "$HOME/.local/bin"
```

Without an argument, a locally executed updater uses the adjacent `bin` directory when it exists; otherwise it falls back to `~/.local/share/workspace/bin`. For a checkout installed elsewhere, pass its `bin` directory explicitly when using the remote command.

### Update behavior

- Requires an existing destination directory; run the installer first if it does not exist.
- Clones the latest `main` branch over HTTPS into a temporary directory with `--depth 1`.
- Copies all scripts matched by `bin/*` into the destination and makes each copied file executable.
- Overwrites same-named scripts, including local modifications. Back up changes you want to keep.
- Leaves unrelated files and scripts removed from the repository untouched.
- Cleans up the temporary clone on normal exit, errors, or handled interrupts.
- Updates only helper scripts, not `install.sh`, `update.sh`, README files, Git metadata, or PATH configuration.
- Copies files individually; an error during copying can leave a partially updated destination.
