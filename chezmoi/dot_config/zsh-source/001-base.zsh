#--------------------
# Oh-My-Zsh Setup
#--------------------
export ZSH="$HOME/.oh-my-zsh"

# === Directories ===
export DOTFILES="$HOME/.dotfiles/"
export EDITOR="nvim"
export GIT_CONFIG_GLOBAL="$HOME/.config/git/config"

# === zulu java ===
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# === Paths ===
export BUN_INSTALL="$HOME/.bun"
export PROTO_HOME="$HOME/.config/proto"
export GOBIN="$HOME/go/bin"
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
export BAT_THEME="OneHalfDark"
export LM_STUDIO_BIN="$HOME/.lmstudio/bin"

export PATH="$HOME/.local/bin:$WEZTERM_EXECUTABLE_DIR:$BUN_INSTALL/bin:$HOME/.console-ninja/.bin:$PROTO_HOME/shims:$PROTO_HOME/bin:$GOBIN:$HOME/.tmuxifier/bin:$HOME/.cargo/bin:/opt/homebrew/bin:$LM_STUDIO_BIN:$PATH"

typeset -U path # Ensure unique entries in PATH

export DISABLE_AUTO_TITLE='true'
