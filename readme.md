## Dotfiles Bootstrap

This repo centralizes shell, editor, and tooling configuration. To apply the setup on a fresh machine:

1. Clone the repo, then `cd` into it.
2. Run the main bootstrapper:

   ```bash
   ./setup_env.sh
   ```

   - Append `--dry` to preview which jobs would run without executing them.
   - Pass a regex argument to target specific job scripts; for example `./setup_env.sh zsh` runs only `jobs/zsh.sh`.

The script aborts on the first failure so you can fix the issue and rerun. Jobs rely on Debian/Ubuntu tooling (`apt-get`, `sudo`), so adjust when using another distro.

### Linking dotfiles with GNU Stow

If you manage symlinks with GNU Stow:

1. Install stow (`sudo apt-get install stow` on Debian/Ubuntu).
2. From the repo root, link the desired module(s):

   ```bash
   stow -t $HOME zsh tmux nvim git
   ```

   - Omit modules you do not need; rerun with `stow -D <module>` to remove a set of links.
   - Use `stow --simulate ...` to preview the actions without touching the filesystem.
