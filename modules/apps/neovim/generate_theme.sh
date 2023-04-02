#!/usr/bin/env bash

# Generates a tmux statusline theme based off the theme in neovim
# May require some edits

nvim -c ":Tmuxline vim_statusline_1 | TmuxlineSnapshot! $(dirname "$0")/tmux_theme | qa!"
