# --------------------
# ENVIRONMENT VARIABLE
# --------------------

# === Directories ===
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x DOTFILES "$HOME/.dotfiles/"
set -x EDITOR nvim
set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
set -x DISABLE_AUTO_TITLE true

# === Paths ===
set -x BUN_INSTALL "$HOME/.bun"
set -x PROTO_HOME "$HOME/.config/proto"
set -x GOBIN "$HOME/go/bin"
set -x BAT_THEME OneHalfDark
set -x LM_STUDIO_BIN "$HOME/.lmstudio/bin"

# Set PATH
set -x PATH $HOME/.local/bin \
    $WEZTERM_EXECUTABLE_DIR \
    $BUN_INSTALL/bin \
    $HOME/.console-ninja/.bin \
    $PROTO_HOME/shims \
    $PROTO_HOME/bin \
    $GOBIN \
    $HOME/.tmuxifier/bin \
    $HOME/.cargo/bin \
    /opt/homebrew/bin \
    $LM_STUDIO_BIN \
    $PATH

# === Bun Completions ===
if test -f "$HOME/.bun/_bun"
    source "$HOME/.bun/_bun"
end

# === FZF Configuration ===
if command -v eza >/dev/null
    set -x LS_CMD "eza --tree --color=always"
else
    set -x LS_CMD "ls -R --color=always"
end

if command -v bat >/dev/null
    set -x CAT_CMD "bat -n --color=always --line-range :500"
else
    set -x CAT_CMD cat
end

set -x FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -x FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"
set -x FZF_CTRL_T_OPTS "--preview 'if [ -d {} ]; then $LS_CMD {} | head -200; else $CAT_CMD {}; fi'"
set -x FZF_ALT_C_OPTS "--preview '$LS_CMD {} | head -200'"
