#!/usr/bin/env bash

set -e

# Run the install script within a fresh Ubuntu docker container
docker run --volume .:/home/root/dotfiles ubuntu:24.04 /home/root/dotfiles/install.sh
