#!/usr/bin/env bash

set -e

# Run the install script within a fresh Ubuntu docker container
# Run it twice to ensure idempotency.
docker run --volume .:/home/root/dotfiles ubuntu:24.04 bash -c "/home/root/dotfiles/install.sh && /home/root/dotfiles/install.sh"
