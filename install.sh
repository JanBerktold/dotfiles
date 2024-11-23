#!/usr/bin/env bash

dotfiles=~/dotfiles

mkdir -p ~/.config

ln -sf $dotfiles/fish ~/.config/fish 

echo "dotfiles install finished"
