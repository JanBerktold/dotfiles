#!/usr/bin/env bash

set -e

# Run it twice to ensure idempotency.
/home/root/dotfiles/install.sh
/home/root/dotfiles/install.sh
