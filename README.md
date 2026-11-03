# Workspace

Command-line helper scripts for your development workspace.

## Requirements

- Bash and Git.
- curl for the one-line installer.
- Standard command-line utilities, including readlink with support for `-f`.
- Write access to the installation directory and your shell configuration file.

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

- The installer does not automatically pull updates to an existing checkout.
- PATH is configured in `~/.zshrc` when `$SHELL` identifies Zsh; otherwise it uses `~/.bashrc`.
- An identical PATH configuration line is not added twice.
