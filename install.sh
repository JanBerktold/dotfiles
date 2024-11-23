#!/usr/bin/env bash

# Abort in case of any errors
set -e

is_wsl2 () { return $(grep -i Microsoft /proc/version); }

is_ubuntu() {
    if [ -f /etc/os-release ]; then
        if grep -qi "ubuntu" /etc/os-release; then
            return 0
        fi
    fi
    return 1
}

try_sudo() {
    if command -v sudo >/dev/null 2>&1; then
        sudo "$@"
    else
        "$@"
    fi
}

get_username() {
    # Try $USER first
    if [ -n "${USER-}" ]; then
        echo "$USER"
        return
    fi

    # Try whoami command
    if command -v whoami >/dev/null 2>&1; then
        whoami
        return
    fi

    # Try logname command
    if command -v logname >/dev/null 2>&1; then
        logname
        return
    fi

    # Last resort: parse passwd file
    id -un
}

dotfiles=~/dotfiles

if ! is_ubuntu; then
	echo "Currently, only Ubuntu is supported"
	exit 1
fi

# Install Fish
echo "Updating package lists..."
try_sudo apt-get update

# Check if fish is already installed
if ! command -v fish >/dev/null 2>&1; then
	try_sudo apt-get install --assume-yes fish

	# Check if fish is already in /etc/shells
	if ! grep -q "^$FISH_PATH$" /etc/shells; then
        	echo "Adding Fish to /etc/shells..."
        	try_sudo bash -c "echo $FISH_PATH >> /etc/shells"
        fi
	        
	echo "Changing default shell to Fish..."
	try_sudo chsh -s "$(which fish)" "$(get_username)"
fi

# Setup the fish config
mkdir -p ~/.config
ln -sf $dotfiles/fish ~/.config/fish 

# Ensure we have git installed
if is_ubuntu; then
	try_sudo apt-get update
	try_sudo apt-get install --assume-yes git
fi

# If we're running on WSL2, then let's use the Windows 1Password agent.
# It will have our ssh keys.
if is_wsl2; then
	echo "Configured git to use the Windows 1Password ssh.exe agent"
	git config --global core.sshCommand "ssh.exe"
fi

# Install [bat]https://github.com/sharkdp/bat), and replace cat with it.
if is_ubuntu; then
	echo "Installing bat"
	try_sudo apt-get install --assume-yes bat

	# The .deb package installs `bat` as `batcat`, so let's symlink it back.
	mkdir -p ~/.local/bin
	ln -sf /usr/bin/batcat ~/.local/bin/bat
fi

echo "dotfiles install finished"
