#!/usr/bin/env bash

set -e

TARGET_DIR="$HOME"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

EXCLUDES=(
    "."
    ".."
    ".git"
    ".gitignore"
    "README.md"
    "scripts"
)

is_excluded() {
    local item="$1"
    for excluded in "${EXCLUDES[@]}"; do
        if [[ "$item" == "$excluded" ]]; then
            return 0
        fi
    done
    return 1
}

# Ensure destination containers exist
mkdir -p "$TARGET_DIR/.config"
mkdir -p "$TARGET_DIR/.local/bin"

conflicts=0
link_item() {
    local src="$1"
    local dest="$2"

    # Check if destination already exists (file, directory, or symlink)
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        # Check if it's already a symlink pointing to our source file
        if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
            echo "[OK] Already linked: $dest"
            return 0
        fi

        # Otherwise, report error and skip
        echo "[SKIP] Target already exists: $dest" >&2
        conflicts=$((conflicts + 1))
        return 0
    fi

    # Create symlink safely since destination does not exist
    ln -sv "$src" "$dest"
}

echo "Setting up symlinks from $DOTFILES_DIR..."

for source_path in "$DOTFILES_DIR"/.* "$DOTFILES_DIR"/*; do
    [ -e "$source_path" ] || continue

    item="$(basename "$source_path")"

    if is_excluded "$item"; then
        continue
    fi

    # 1. Handle .config subdirectories
    if [[ "$item" == ".config" ]]; then
        for config_item in "$DOTFILES_DIR/.config"/* "$DOTFILES_DIR/.config"/.*; do
            [ -e "$config_item" ] || continue
            cfg_name="$(basename "$config_item")"
            if [[ "$cfg_name" != "." && "$cfg_name" != ".." ]]; then
                link_item "$config_item" "$TARGET_DIR/.config/$cfg_name"
            fi
        done
        continue
    fi

    # 2. Handle .local/bin scripts
    if [[ "$item" == ".local" ]]; then
        if [ -d "$DOTFILES_DIR/.local/bin" ]; then
            for bin_script in "$DOTFILES_DIR/.local/bin"/* "$DOTFILES_DIR/.local/bin"/.*; do
                [ -e "$bin_script" ] || continue
                script_name="$(basename "$bin_script")"
                if [[ "$script_name" != "." && "$script_name" != ".." ]]; then
                    chmod +x "$bin_script"
                    link_item "$bin_script" "$TARGET_DIR/.local/bin/$script_name"
                fi
            done
        fi
        continue
    fi

    # 3. Handle top-level dotfiles (.zshrc, .ideavimrc, etc.)
    link_item "$source_path" "$TARGET_DIR/$item"
done

echo "Finished processing dotfiles."

if (( conflicts > 0 )); then
    echo "Encountered $conflicts conflict(s)." >&2
    exit 1
fi
