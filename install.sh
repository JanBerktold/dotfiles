#!/usr/bin/env bash

is_wsl2 () { return $(grep -i Microsoft /proc/version); }

dotfiles=~/dotfiles

# Setup the fish config
mkdir -p ~/.config
ln -sf $dotfiles/fish ~/.config/fish 

# If we're running on WSL2, then let's use the Windows 1Password agent.
# It will have our ssh keys.
if [[ is_wsl2 ]]; then
	echo "Configured git to use the Windows 1Password ssh.exe agent"
	git config core.sshCommand "ssh.exe"
fi

echo "dotfiles install finished"
