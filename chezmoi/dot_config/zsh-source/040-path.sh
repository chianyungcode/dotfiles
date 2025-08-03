# Build PATH
_myPaths=(
  "${HOME}/.local/bin"
  "/usr/local/bin"
  "/opt/homebrew/bin"
  "{{ .directories.user_bin_dir }}"
  "{{ .xdgDataDir }}/cargo/bin"
  "/usr/bin/snap"
  "${HOME}/.atuin/bin"
  "${PROTO_HOME}/shims"
  "${PROTO_HOME}/bin"
  "${HOME}/.tmuxifier/bin"
  "${LM_STUDIO_BIN}"
)

for _path in "${_myPaths[@]}"; do
  if [[ -d ${_path} ]]; then
    if ! printf "%s" "${_path}" | grep -q "${PATH}"; then
      PATH="${_path}:${PATH}"
    fi
  fi
done

unset _myPaths _path

typeset -U path # Ensure unique entries in PATH
