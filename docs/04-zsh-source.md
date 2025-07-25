# ZSH Source Configuration Documentation

This document provides comprehensive documentation for the ZSH configuration files located in `chezmoi/dot_config/zsh-source/`. These files are loaded by chezmoi to configure the ZSH shell environment with consistent settings across different systems.

## Directory Structure

```
chezmoi/dot_config/zsh-source/
├── 000-xdg.sh.tmpl              # XDG Base Directory Specification
├── 001-base.zsh                 # Basic environment setup
├── 001-bind-keys.zsh            # Key bindings and shortcuts
├── 001-options.bash             # Bash-specific options
├── 001-options.zsh.tmpl         # ZSH options and completion
├── 003-plugin-manager.zsh       # Plugin management (antidote)
├── 020-alerting.sh              # Alert/messaging system
├── 020-colors.sh                # Color definitions
├── 040-path.sh                  # PATH configuration
├── 060-common-aliases.sh.tmpl   # Common aliases
├── 060-common-functions.sh.tmpl # Common utility functions
├── 070-better-defaults.sh.tmpl  # Improved default commands
├── 080-linux.sh.tmpl            # Linux-specific configurations
├── 080-macos.sh.tmpl            # macOS-specific configurations
├── 090-personal.sh.tmpl         # Personal SSH shortcuts
└── third-party/                 # Third-party integrations
```

## File Documentation

### 000-xdg.sh.tmpl - XDG Base Directory Specification

**Purpose**: Configures XDG (Cross-Desktop Group) base directory specification environment variables for consistent file organization across applications.

**Key Variables**:

- `XDG_DATA_HOME`: User-specific data files (default: `~/.local/share`)
- `XDG_CONFIG_HOME`: User-specific configuration files (default: `~/.config`)
- `XDG_STATE_HOME`: User-specific state data (default: `~/.local/state`)
- `XDG_CACHE_HOME`: User-specific cache files (default: `~/.cache`)

**Template Variables**: Uses chezmoi template variables:

- `.xdgDataDir`
- `.xdgConfigDir`
- `.xdgStateDir`
- `.xdgCacheDir`

### 001-base.zsh - Basic Environment Setup

**Purpose**: Establishes fundamental environment variables and paths for the ZSH shell.

**Key Configurations**:

- **Directories**:

  - `DOTFILES`: Points to `~/.dotfiles/`
  - `EDITOR`: Set to `nvim` (Neovim)
  - `GIT_CONFIG_GLOBAL`: Git configuration location

- **Java Configuration**:

  - `JAVA_HOME`: Zulu JDK 17 path for macOS

- **Tool Paths**:

  - `BUN_INSTALL`: Bun runtime location
  - `PROTO_HOME`: Proto toolchain manager
  - `GOBIN`: Go binary directory
  - `STARSHIP_CONFIG`: Starship prompt configuration
  - `LM_STUDIO_BIN`: LM Studio binary directory

- **PATH Construction**: Comprehensive PATH including:
  - Local binaries (`~/.local/bin`)
  - WezTerm executables
  - Bun, Proto, Go, Tmuxifier, Cargo binaries
  - Homebrew (`/opt/homebrew/bin`)
  - LM Studio binaries

### 001-bind-keys.zsh - Key Bindings and Shortcuts

**Purpose**: Configures custom key bindings for enhanced ZSH navigation and productivity.

**Key Bindings**:

- **Alt+x**: Insert last command output
- **Ctrl+r**: Incremental history search backward
- **Alt+Left/Right**: Navigate by words
- **Page Up/Down**: Navigate history lines
- **Home/End**: Beginning/end of line
- **Option+Left/Right**: Beginning/end of line (macOS)

**Special Features**:

- Uses `zsh/parameter` module for history access
- Terminal capability detection for compatibility
- Custom function `insert-last-command-output` for inserting previous command results

### 001-options.bash - Bash-Specific Options

**Purpose**: Configures Bash-specific shell options and history management.

**History Management**:

- **PROMPT_COMMAND**: Appends history immediately
- **HISTSIZE/HISTFILESIZE**: 10,000 entries
- **HISTTIMEFORMAT**: Timestamps in history
- **HISTCONTROL**: Duplicate removal and space-ignored commands
- **HISTIGNORE**: Commands to exclude from history

**Shell Options**:

- **Directory Navigation**:

  - `autocd`: Type directory names to cd
  - `dirspell`: Spelling correction for tab-completion
  - `cdspell`: Spelling correction for cd arguments
  - `globstar`: Recursive globbing with \*\*

- **Tab Completion**:

  - Case-insensitive completion
  - Hyphen/underscore equivalence
  - Show all matches on first tab
  - Mark symlinked directories

- **SSH Autocompletion**: Based on known_hosts entries

### 001-options.zsh.tmpl - ZSH Options and Completion

**Purpose**: Comprehensive ZSH configuration with advanced completion and history management.

**ZSH Options**:

- **History**: Extended history, duplicate removal, shared history
- **Completion**: Auto-list, auto-menu, case-insensitive
- **Navigation**: Auto-cd, auto-pushd, pushd ignore duplicates
- **Globbing**: Extended glob, dot files included, numeric sorting
- **Behavior**: No beep, immediate background job notification

**Advanced Completion**:

- **Caching**: Completion cache at `~/.cache/zsh/cache`
- **Colors**: Custom color schemes for different completion types
- **FZF Integration**: fzf-tab for fuzzy completion
- **SSH Hosts**: Dynamic SSH host completion
- **Git**: Special handling for git commands

### 003-plugin-manager.zsh - Plugin Management

**Purpose**: Manages ZSH plugins using antidote (modern plugin manager).

**Configuration**:

- **Antidote Setup**:

  - Plugin file: `~/.zsh_plugins.txt`
  - Static generation: Creates `.zsh_plugins.zsh` when plugins change
  - Lazy loading for performance

- **Oh-My-Zsh Alternative**:
  - Commented Oh-My-Zsh configuration available
  - Plugin list includes: git, direnv, bun, 1password, npm, etc.

**Usage**:

- Add plugins to `~/.zsh_plugins.txt`
- Antidote automatically generates optimized static file
- Supports both GitHub and local plugins

### 020-alerting.sh - Alert/Messaging System

**Purpose**: Provides a unified messaging system for shell scripts with color-coded output.

**Alert Types**:

- `success`: Green success messages
- `error`: Red error messages
- `warning`: Yellow warning messages
- `info`: Gray informational messages
- `debug`: Purple debug messages
- `header`: Bold yellow section headers
- `input`: Bold underlined input prompts

**Functions**:

- `_alert_`: Core alerting function
- Convenience functions: `error()`, `warning()`, `success()`, etc.
- Terminal detection for color support
- Non-terminal output compatibility

### 020-colors.sh - Color Definitions

**Purpose**: Defines terminal colors and provides color testing utilities.

**Features**:

- **Color Detection**: Automatic 256-color vs basic color support
- **Color Variables**: `bold`, `underline`, `reverse`, `reset`
- **Color Functions**: `colors()` and `mycolors()` for testing
- **Terminal Type**: Automatic TERM variable setting
- **LESS Colors**: Man page color configuration

**Color Variables**:

- `white`, `blue`, `yellow`, `green`, `red`, `purple`, `gray`
- Supports both 256-color and basic 8-color terminals

### 040-path.sh - PATH Configuration

**Purpose**: Dynamically builds and manages the system PATH.

**Path Sources**:

- `~/.local/bin`
- `/usr/local/bin`
- `/opt/homebrew/bin`
- User bin directory (template variable)
- Cargo binaries
- Atuin shell history
- Snap packages (Linux)

**Features**:

- Directory existence checking
- Duplicate prevention
- Template variable support
- Clean PATH management

### 060-common-aliases.sh.tmpl - Common Aliases

**Purpose**: Provides convenient aliases for common commands and tools.

**Development Aliases**:

- `c`: VS Code
- `nv`: Neovim
- `lzg`: LazyGit
- `lzd`: LazyDocker
- `bfzf`: Bun script selection with fzf

**Directory Aliases**:

- `dotfiles`: Navigate to dotfiles directory
- `config`: Navigate to ~/.config

**File Listing** (using eza):

- `l`: Basic long listing
- `ll`: All files with human-readable sizes
- `llm`: Sorted by modification time
- `la`: Detailed attributes
- `lx`: Extended attributes
- `lt`: Tree view
- `llt`: Tree view with details

**Platform Detection**: Conditional Git integration based on OS/architecture

### 060-common-functions.sh.tmpl - Common Utility Functions

**Purpose**: Provides essential shell utility functions for daily operations.

**File Operations**:

- `ff`: Find files by name
- `ffs`: Find files starting with pattern
- `ffe`: Find files ending with pattern
- `mkcd`: Create directory and enter it
- `mcd`: Make directory with verbose output
- `buf`: Backup file with timestamp

**System Operations**:

- `su`: Sudo last command or provided command
- `extract`: Universal archive extractor
- `chgext`: Batch file extension changer
- `myip`: External IP address checker with multiple sources

**Help System**:

- `help`: Universal help tool for commands, aliases, functions
- Supports man pages, tldr, and custom script help
- Detects command type (builtin, alias, function, etc.)

**Encoding Utilities**:

- `escape`: Escape special characters
- `htmldecode/htmlencode`: HTML entity handling
- `urlencode/urldecode`: URL encoding/decoding

### 070-better-defaults.sh.tmpl - Improved Default Commands

**Purpose**: Replaces default commands with better alternatives when available.

**Command Replacements**:

- **ping**: Uses `gping` (graphical ping) or `prettyping` when available
- **cat**: Uses `bat` (better cat with syntax highlighting) when available

**Template Logic**: Uses `lookPath` to check for command availability

### 080-linux.sh.tmpl - Linux-Specific Configurations

**Purpose**: Provides Linux-specific aliases and functions.

**Distribution Detection**:

- Ubuntu/Debian: `apt-get` aliases
- Fedora: `dnf` aliases
- Arch: `pacman` aliases
- openSUSE: `zypper` aliases
- Alpine: `apk` aliases

**System Management**:

- `ctl`: systemctl alias
- `reboot`: Safe reboot command
- `sstart/srestart`: Start/restart services with status
- `logs`: Journalctl aliases for service logs

**Startup Scripts**: Executes `linux-startup.sh` if present in user bin directory

### 080-macos.sh.tmpl - macOS-Specific Configurations

**Purpose**: Provides macOS-specific aliases and functions.

**Clipboard Integration**:

- `cpwd`: Copy current directory to clipboard
- `caff`: Prevent sleep during command execution

**Finder Integration**:

- `f`: Open Finder at current/specific directory
- `showdot/hidedot`: Toggle hidden files in Finder
- `finderpath`: Get path of frontmost Finder window

**System Management**:

- `spot-on/spot-off`: Spotlight indexing control
- `fixmounts`: Re-mount network drives
- `flushdns`: Clear DNS cache
- `cleanupLS`: Clean LaunchServices database

**File Management**:

- `listdsstore`: Find .DS_Store files
- `rmdsstore`: Remove .DS_Store files recursively
- `unquarantine`: Remove quarantine attributes
- `spotlight`: Search using Spotlight metadata
- `ql`: QuickLook file preview

### 090-personal.sh.tmpl - Personal SSH Shortcuts

**Purpose**: Creates SSH aliases for personal remote servers.

**Configuration**:

- **Conditional Loading**: Only loads when `.use_secrets` is true
- **Dynamic Aliases**: Creates aliases based on `.remote_servers` configuration
- **Tailscale Support**: Creates additional `tail<name>` aliases for Tailscale IPs

**Usage**:

- Creates `alias servername="ssh servername"` for each server
- Creates `alias tailservername="ssh tailservername"` for Tailscale connections

## Usage and Integration

### Loading Order

The files are loaded in numerical order (000-090) to ensure proper dependency management:

1. XDG directories are set first
2. Basic environment is established
3. Shell options are configured
4. Plugin manager is initialized
5. Utilities and aliases are loaded
6. Platform-specific configurations are applied last

### Template Variables

The configuration uses chezmoi template variables for customization:

- `.xdg*Dir`: XDG directory paths
- `.chezmoi.os`: Operating system detection
- `.chezmoi.osRelease.id`: Linux distribution detection
- `.directories.user_bin_dir`: User binary directory
- `.use_secrets`: Enable personal configurations
- `.remote_servers`: SSH server configurations

### Third-Party Directory

The `third-party/` directory contains additional integrations and external configurations that extend the base ZSH setup.

## Best Practices

1. **Customization**: Modify template variables in chezmoi configuration rather than editing files directly
2. **Testing**: Use `chezmoi apply --dry-run` to test changes
3. **Organization**: Keep personal configurations in `090-personal.sh.tmpl`
4. **Portability**: Use template conditions for cross-platform compatibility
5. **Performance**: Leverage antidote's static file generation for faster startup
