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

No framework; `.zshrc` sources plain git clones from `~/.local/share/zsh/plugins`:

```bash
mkdir -p ~/.local/share/zsh/plugins && cd ~/.local/share/zsh/plugins
git clone https://github.com/aloxaf/fzf-tab
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions
```

Update with `for p in ~/.local/share/zsh/plugins/*; do git -C "$p" pull; done`.
