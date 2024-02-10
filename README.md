# dotfiles

This repository contains my personal dotfiles and a script to install them on a new machine.

## Packages Installed

The script installs the following packages:

- [GNU Stow](https://www.gnu.org/software/stow/): A symlink farm manager that can take distinct packages of software and/or data located in separate directories on the filesystem, and link them together into a single directory tree.
- [Starship](https://starship.rs/): A minimal, blazing-fast, and infinitely customizable prompt for any shell.
- Zsh: A powerful shell that features some improvements over bash including spelling correction, cd correction, better theme support, and more.
- [Oh My Zsh](https://github.com/ohmyzsh/ohmyzsh/): An open-source, community-driven framework for managing your Zsh configuration. It comes bundled with a ton of helpful functions, helpers, plugins, themes.
- Oh My Zsh plugins (zsh-autosuggestions): This plugin suggests commands as you type based on history and completions.
- tmux: A terminal multiplexer that lets you switch easily between several programs in one terminal.
- [tpm](https://github.com/tmux-plugins/tpm): Tmux Plugin Manager.
- [bun](https://bun.sh/): bun 🍞

## Usage

Before running the script, make sure to backup your existing dotfiles as this script will overwrite them.

To run the script, use the following command:

```bash
bash ./install.sh
```
