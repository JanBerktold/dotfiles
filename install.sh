#!/usr/bin/env bash

# Abort in case of any errors
set -e

is_wsl2 () {
    if is_macos; then
        return 1
    fi

    return $(grep -i Microsoft /proc/version);
}

is_ubuntu() {
    if [ -f /etc/os-release ]; then
        if grep -qi "ubuntu" /etc/os-release; then
            return 0
        fi
    fi
    return 1
}

is_macos() {
    [ "$(uname)" = "Darwin" ]
    return $?
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

# Read where our dotfiles repository was checked out.
# Typically, this would be ~/dotfiles, but we can't rely on that.
dotfiles="$(pwd)"

if ! { is_ubuntu || is_macos; }; then
    echo "Currently, only Ubuntu and macOS are supported"
    exit 1
fi

# Install Fish
if is_ubuntu; then
    echo "Updating package lists..."
    try_sudo apt-get update

    try_sudo apt-get install --assume-yes fish

elif is_macos; then
    echo "Installing fish on macos"

    brew install fish
fi

FISH_PATH=$(command -v fish)
if [ -z "$FISH_PATH" ]; then
    echo "Error: Fish installation failed - binary not found"
    exit 1
fi
 
# Check if fish is already in /etc/shells
if ! grep -q "^$FISH_PATH$" /etc/shells; then
    echo "Adding Fish to /etc/shells..."
    try_sudo bash -c "echo $FISH_PATH >> /etc/shells"
fi

# Change default shell to fish, if not already done.
if [ "$SHELL" != "$FISH_PATH" ]; then
    echo "Changing default shell to Fish..."
    try_sudo chsh -s "$FISH_PATH" "$(get_username)"
else
    echo "Fish is already the default shell"
fi

# Setup the fish config
mkdir -p ~/.config
ln -sf "$dotfiles/fish" ~/.config/fish 

# Setup the git config
echo "setting up $dotfiles/git"
ln -sf "$dotfiles/git" ~/.config/

# Ensure we have git installed
if is_ubuntu; then
	try_sudo apt-get update
	try_sudo apt-get install --assume-yes git vim curl build-essential htop
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

# Install Rust
curl https://sh.rustup.rs -sSf | sh -s -- -y

echo "dotfiles install finished"
