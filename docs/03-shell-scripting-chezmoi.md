# Shell Scripting with Chezmoi

Shell scripting is used for automation in chezmoi, such as installing various homebrew packages, apt packages, and other system configurations. This document covers the comprehensive shell scripting utilities available through chezmoi templates.

## Overview

Chezmoi leverages shell scripting for automation tasks during dotfile deployment. The `shared_script_utils.bash` template provides a robust set of utilities for logging, error handling, and common operations that can be used across different shell scripts.

## Using `shared_script_utils.bash` for Shell Scripting

The `shared_script_utils.bash` template contains various functions for logging, error handling, and utility operations. This template is designed to be included in other shell scripts to provide consistent behavior and utilities.

### Core Features

- **Comprehensive Logging System**: Multiple log levels with colored output
- **Error Handling**: Automatic cleanup and error trapping
- **Utility Functions**: Common operations like array checking, binary detection
- **Cross-platform Support**: Works on macOS, Linux (Ubuntu/Arch)
- **Template Integration**: Uses chezmoi variables for platform detection

## Available Functions and Variables

### Global Variables

| Variable   | Default                             | Description                                                       |
| ---------- | ----------------------------------- | ----------------------------------------------------------------- |
| `LOGFILE`  | `${HOME}/logs/$(basename "$0").log` | Path to log file                                                  |
| `QUIET`    | `false`                             | Suppress console output                                           |
| `LOGLEVEL` | `ERROR`                             | Logging level (ALL, DEBUG, INFO, NOTICE, WARN, ERROR, FATAL, OFF) |
| `VERBOSE`  | `false`                             | Enable verbose output                                             |
| `FORCE`    | `false`                             | Force operations without confirmation                             |
| `DRYRUN`   | `false`                             | Show what would be done without executing                         |

### Logging Functions

All logging functions support automatic line number tracking and function stack tracing.

#### `_alert_ <type> <message> [line_number]`

Core logging function used by all other logging functions.

**Parameters:**

- `type`: One of: success, header, notice, dryrun, debug, warning, error, fatal, info, input
- `message`: The message to log
- `line_number`: Optional line number (use `${LINENO}`)

**Usage:**

```bash
_alert_ "info" "Starting installation process" "${LINENO}"
```

#### Convenience Functions

| Function    | Purpose                     | Color                 |
| ----------- | --------------------------- | --------------------- |
| `error()`   | Error messages              | Bold red              |
| `warning()` | Warning messages            | Yellow                |
| `notice()`  | Notice messages             | Bold                  |
| `info()`    | Information messages        | Gray                  |
| `success()` | Success messages            | Green                 |
| `dryrun()`  | Dry run messages            | Blue                  |
| `input()`   | Input prompts               | Bold underline        |
| `header()`  | Section headers             | Bold white underlined |
| `debug()`   | Debug messages              | Purple                |
| `fatal()`   | Fatal errors (exits script) | Bold red              |

**Examples:**

```bash
info "Installing package: ${package_name}"
warning "Configuration file already exists, backing up"
success "Installation completed successfully"
fatal "Required dependency not found"
```

### Error Handling and Cleanup

#### `_safeExit_ [exit_code]`

Cleanup function that removes temporary directories and script locks before exiting.

**Parameters:**

- `exit_code`: Optional exit code (defaults to 0)

**Usage:**

```bash
_safeExit_ 0  # Clean exit
_safeExit_ 1  # Exit with error
```

#### `_trapCleanup_`

Error trap function that logs detailed error information including:

- Line number where error occurred
- Function call stack
- Executing command
- Script name and source

**Automatic Setup:**

```bash
trap '_trapCleanup_ ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM ERR
```

### Utility Functions

#### `_makeTempDir_ [prefix]`

Creates a secure temporary directory with restricted permissions.

**Parameters:**

- `prefix`: Optional prefix for directory name

**Output:**

- Sets `TMP_DIR` variable to the path of created directory

**Usage:**

```bash
_makeTempDir_ "myscript"
debug "Using temp directory: ${TMP_DIR}"
```

#### `_printFuncStack_`

Returns a formatted string of the current function call stack for debugging.

**Output:**

- String format: `(function:file:line < function:file:line ...)`

**Usage:**

```bash
debug "Current call stack: $(_printFuncStack_)"
```

#### `_hasJQ_`

Checks for jq installation and installs it automatically if missing.

**Platform Support:**

- **macOS**: Uses `brew install jq`
- **Linux (Ubuntu)**: Uses `sudo apt install -y jq`
- **Linux (Arch)**: Uses `sudo pacman -S --noconfirm jq`

**Usage:**

```bash
_hasJQ_  # Will install jq if not found
```

#### `_inArray_ [options] <value> <array...>`

Checks if a value exists in an array with optional case-insensitive and regex support.

**Options:**

- `-i`: Ignore case
- `-r`: Use regex matching

**Parameters:**

- `value`: Value to search for
- `array`: Array elements to search in

**Return:**

- `0` if found
- `1` if not found

**Usage:**

```bash
packages=("git" "vim" "curl")
if _inArray_ "git" "${packages[@]}"; then
    info "Git is already in the list"
fi

# Case-insensitive search
if _inArray_ -i "VIM" "${packages[@]}"; then
    info "Vim found (case-insensitive)"
fi

# Regex search
if _inArray_ -r "^vi.*" "${packages[@]}"; then
    info "Found package starting with 'vi'"
fi
```

#### `_uvBinaryPath_ [options]`

Locates the uv binary (Python package manager) in common installation paths.

**Options:**

- `-p`: Don't exit if binary not found, return empty string

**Return:**

- Path to uv binary if found
- Exit code 1 if not found (unless -p is used)

**Search Paths:**

1. `command -v uv`
2. `${HOME}/.local/bin/uv`
3. `${XDG_DATA_HOME}/cargo/uv`
4. `${HOME}/.cargo/bin/uv`

**Usage:**

```bash
UV_PATH=$(_uvBinaryPath_)
if [[ -n "${UV_PATH}" ]]; then
    info "Found uv at: ${UV_PATH}"
fi

# Don't exit on failure
UV_PATH=$(_uvBinaryPath_ -p)
```

### Color Support

The template automatically detects terminal capabilities and sets appropriate colors:

- **256-color terminals**: Uses extended color palette
- **8-color terminals**: Falls back to basic colors
- **Non-terminal output**: Disables colors automatically

**Available Colors:**

- `white`, `blue`, `yellow`, `green`, `red`, `purple`, `gray`
- `bold`, `underline`, `reverse`, `reset`

**Usage:**

```bash
echo "${green}Success!${reset}"
echo "${bold}${blue}Important:${reset} ${yellow}Warning message${reset}"
```

### Script Safety Features

The template includes several safety mechanisms:

- **Bash version check**: Ensures Bash 4+ features are available
- **Strict mode**: `set -o errexit`, `set -o pipefail`, `set -o nounset`
- **Error trapping**: Comprehensive error handling and cleanup
- **Signal handling**: Proper cleanup on SIGINT, SIGTERM, etc.

### Integration with Chezmoi Scripts

To use these utilities in chezmoi scripts:

1. **Include the template** in your script:

```bash
{{- template "shared_script_utils.bash" . }}
```

2. **Use in run scripts** (e.g., `run_onchange_before_10-homebrew-packages.sh.tmpl`):

```bash
#!/usr/bin/env bash
{{- template "shared_script_utils.bash" . }}

header "Installing Homebrew Packages"

# Check for required tools
_hasJQ_

# Your installation logic here
info "Processing package list..."
```

### Complete Example

Here's a complete example of using the utilities in a chezmoi script:

```bash
#!/usr/bin/env bash
{{- template "shared_script_utils.bash" . }}

header "System Package Installation"

# Set custom log file
LOGFILE="${HOME}/logs/package-installation.log"
LOGLEVEL="INFO"

# Check prerequisites
_hasJQ_
UV_PATH=$(_uvBinaryPath_ -p)

if [[ -z "${UV_PATH}" ]]; then
    warning "uv not found, Python package installation will be skipped"
fi

# Process package list
_makeTempDir_ "package-install"
info "Using temporary directory: ${TMP_DIR}"

# Example array operations
REQUIRED_TOOLS=("git" "curl" "wget")
for tool in "${REQUIRED_TOOLS[@]}"; do
    if command -v "${tool}" >/dev/null 2>&1; then
        success "${tool} is already installed"
    else
        info "Installing ${tool}..."
        # Installation logic here
    fi
done

success "Package installation completed"
_safeExit_ 0
```

## Best Practices

1. **Always include the template** at the start of your scripts
2. **Use appropriate log levels** for different types of messages
3. **Include line numbers** in debug/error messages using `${LINENO}`
4. **Use temporary directories** for file operations via `_makeTempDir_`
5. **Check for dependencies** using functions like `_hasJQ_`
6. **Clean exit** with `_safeExit_` to ensure proper cleanup
7. **Test scripts** with `DRYRUN=true` to preview changes
