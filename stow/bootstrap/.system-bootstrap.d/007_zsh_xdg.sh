#!/bin/bash

# Set up XDG directories for zsh
# Ensures proper directory structure for zsh history and other files

set -e

echo "Setting up XDG directories for zsh..."

# Set XDG variables if not already set
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Create XDG directories for zsh
mkdir -p "${XDG_CONFIG_HOME}/zsh"
mkdir -p "${XDG_CACHE_HOME}/zsh"
mkdir -p "${XDG_DATA_HOME}/zsh"
mkdir -p "${XDG_STATE_HOME}/zsh"

# Create specific directories that zsh expects
mkdir -p "${XDG_DATA_HOME}/oh-my-zsh"

# Create history file (not directory)
touch "${XDG_STATE_HOME}/zsh/history"

# Set proper permissions
chmod 755 "${XDG_CONFIG_HOME}/zsh"
chmod 755 "${XDG_CACHE_HOME}/zsh"
chmod 755 "${XDG_DATA_HOME}/zsh"
chmod 755 "${XDG_STATE_HOME}/zsh"
chmod 644 "${XDG_STATE_HOME}/zsh/history"
chmod 755 "${XDG_DATA_HOME}/oh-my-zsh"

echo "XDG directories for zsh created successfully"
