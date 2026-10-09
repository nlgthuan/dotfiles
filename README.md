# Dotfiles

Personal configuration files and custom environment setup for Mac.

## Structure

```text
~/dotfiles/
├── .config/         # App-specific configs (nvim, tmux, etc.)
├── .local/
│   └── bin/         # Custom user scripts and executables
├── scripts/
│   └── install.sh   # Symlink installer script
├── .ideavimrc
├── .zshrc
├── .zshrc.local
├── .gitignore
└── README.md

```

## Installation

 **Make the install script executable and run it:**
```bash
chmod +x scripts/install.sh
./scripts/install.sh

```

## How It Works

The `install.sh` script manages symbolic links from `~/dotfiles` into home directory (`~`):

* **Safety Checks:** If a target file or directory already exists in `$HOME` (and isn't already pointing to dotfiles), the script skips it to prevent overwriting local data.
* **Granular `.config` & `.local/bin` Linking:** Instead of symlinking the entire `~/.config` or `~/.local` directory, it symlinks individual application subdirectories and scripts. This keeps untracked, machine-local data out of Git.
* **Automatic Permissions:** Scripts inside `.local/bin` are automatically granted execute permissions (`chmod +x`) during installation.

## Making Changes

* **Existing Files:** Edit files directly in `~/dotfiles` or via their symlinked locations in `$HOME`. Changes take effect immediately without re-running the installer.
* **New Configurations:** Place new dotfiles or scripts into the appropriate repository directory, then re-run `./scripts/install.sh` to establish new symlinks.

## Install with homebrew

- zsh
- fzf
- nvm
- rg
- pg
- tmux
- nvim

## ZSH plugins

No framework; `.zshrc` sources plain git clones from `~/.local/share/zsh/plugins`.
On a new machine, run once:

```bash
mkdir -p ~/.cache/zsh ~/.local/share/zsh/plugins
for repo in Aloxaf/fzf-tab zsh-users/zsh-autosuggestions zdharma-continuum/fast-syntax-highlighting; do
  git clone --depth 1 "https://github.com/$repo" ~/.local/share/zsh/plugins/"${repo#*/}"
done
```

Update with `for p in ~/.local/share/zsh/plugins/*; do git -C "$p" pull; done`.
