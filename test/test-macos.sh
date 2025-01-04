#!/usr/bin/env bash

set -e

# Run it twice to ensure idempotency.
./install.sh
./install.sh
