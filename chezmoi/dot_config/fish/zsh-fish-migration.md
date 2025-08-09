# Migrating from ZSH to Fish Shell

## Overview

This document outlines the process of migrating from ZSH to Fish shell, based on the existing ZSH configuration in the dotfiles.

## Current ZSH Configuration

The ZSH setup includes:

1. **Plugin Management**: Using antidote as plugin manager with plugins like:
   - zsh-abbr (for aliases)
   - zsh-autosuggestions
   - fast-syntax-highlighting
   - oh-my-zsh plugins (git, brew, npm, docker-compose, tmux)

2. **Aliases and Functions**: Many productivity aliases and functions:
   - `mkcd`, `mcd` (create directory and cd)
   - `ff`, `ffe`, `ffs` (find files)
   - `extract` (extract files)
   - `myip` (check external IP)
   - Various eza aliases (replacement for ls)

3. **Keybindings**: Custom keybindings for:
   - Word navigation with alt+arrows
   - Insert last command output
   - FZF integration

4. **FZF Integration**: Comprehensive FZF configuration with preview using bat and eza

5. **Zoxide Integration**: Zoxide for smart directory navigation

6. **Completion System**: Advanced completion system with caching

## Fish Migration Guide

### 1. Plugin Management

Fish doesn't use plugin managers like ZSH. Instead:
- Use `fisher` as package manager
- Convert ZSH plugins to Fish equivalents where available

### 2. Variables and Exports

Convert from ZSH format to Fish:
```fish
# ZSH: export EDITOR="nvim"
set -gx EDITOR nvim

# ZSH: export PATH="$PATH:/new/path"
set -gx PATH $PATH /new/path
```

### 3. Aliases

Convert ZSH aliases to Fish:
```fish
# ZSH: alias ll='eza -lah --classify=auto --icons=auto'
alias ll 'eza -lah --classify=auto --icons=auto'
```

### 4. Functions

Functions in Fish have different syntax:
```fish
# ZSH function
mkcd(){
    if [[ -d $1 ]]; then
        echo "It already exists! cd to the directory."
        cd $1
    else
        mkdir -p $1 && cd $1
    fi
}

# Fish function
function mkcd
    if test -d $argv[1]
        echo "It already exists! cd to the directory."
        cd $argv[1]
    else
        mkdir -p $argv[1] && cd $argv[1]
    end
end
```

### 5. Keybindings

Fish uses the `bind` command:
```fish
# ZSH: bindkey '^[x' insert-last-command-output
bind \ex insert-last-command-output
```

### 6. FZF Integration

Fish has different FZF integration:
- Use `fzf_configure_bindings` if using fzf.fish plugin
- Or manual configuration with functions

## Implementation Plan

1. Set up fisher as package manager
2. Install Fish equivalents of ZSH plugins
3. Convert all aliases to Fish format
4. Rewrite functions in Fish syntax
5. Set up keybindings
6. Configure FZF integration
7. Set up Zoxide for Fish
8. Configure completions
