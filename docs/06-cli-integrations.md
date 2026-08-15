<!-- markdownlint-disable MD013 MD024 MD025 -->

# atuin

## Integration

- `chezmoi/dot_config/fish/conf.d/90_atuin.fish`: Initializes Atuin for Fish
  and binds the Up key to history search, including explicit bindings for Fish
  4 and older versions.
- `chezmoi/dot_config/fish/conf.d/90_fzf.fish.tmpl`: Keeps `Ctrl-R` assigned
  to Atuin's history search instead of enabling fzf history search.
- `chezmoi/dot_config/zsh/conf.d/third-party/atuin.sh.tmpl`: Initializes Atuin
  for Zsh and assigns the Up-arrow and `Ctrl-R` widgets to history search.
- `chezmoi/dot_config/zsh/completions/_atuin`: Provides native Zsh completions
  for Atuin subcommands and options.

# bat

## Integration

- `chezmoi/dot_config/fish/conf.d/10_03-abbr.fish`: Defines `cat` as a Fish
  abbreviation for `bat`.
- `chezmoi/dot_config/fish/conf.d/99_skim.fish`: Uses `bat --color=always` to
  preview files selected through the Fish `sk` picker.
- `chezmoi/dot_config/zsh/conf.d/third-party/bat.sh`: Sets the shared
  `BAT_THEME` environment variable to `DarkNeon`.

# bun

## Integration

- `chezmoi/dot_config/fish/conf.d/10_03-abbr.fish`: Provides Fish
  abbreviations for common Bun tasks such as installing packages, running
  scripts, testing, and updating dependencies.
- `chezmoi/dot_config/zsh/conf.d/third-party/bun.sh.tmpl`: Provides equivalent
  Zsh aliases for Bun commands when Bun is available.

# chezmoi

## Integration

- `chezmoi/dot_config/fish/conf.d/90_chezmoi.fish.tmpl`: Adds the `nvdot` Fish
  alias for opening the Chezmoi source directory in Neovim.
- `chezmoi/dot_config/zsh/conf.d/third-party/chezmoi.sh.tmpl`: Adds the same
  `nvdot` alias for Zsh.

# docker

## Integration

- `chezmoi/dot_config/fish/conf.d/10_03-abbr.fish`: Defines Fish abbreviations
  for Docker and Docker Compose operations, including containers, images,
  networks, volumes, logs, and interactive execution.
- `chezmoi/dot_config/zsh/conf.d/third-party/docker.sh.tmpl`: Defines Zsh
  aliases for the same common Docker operations when Docker is available.

# eza

## Integration

- `chezmoi/dot_config/fish/conf.d/10_03-abbr.fish`: Replaces common Fish
  listing commands with eza abbreviations such as `ls`, `ll`, `la`, and `lt`.
- `chezmoi/dot_config/fish/conf.d/90_zoxide.fish.tmpl`: Uses eza to render a
  tree preview while selecting a directory from zoxide.
- `chezmoi/dot_config/zsh/conf.d/third-party/eza.sh.tmpl`: Defines Zsh aliases
  for long listings, Git-aware listings, icons, and tree views.

# fd

## Integration

- `chezmoi/dot_config/fish/conf.d/99_skim.fish`: Uses fd to enumerate hidden
  files and directories, excluding `.git`, for the Fish `sk` picker.
- `chezmoi/dot_config/zsh/conf.d/third-party/99_skim.sh`: Uses fd to generate
  candidates for the Zsh `sk` `Ctrl-T` widget.
- `chezmoi/dot_config/zsh/conf.d/third-party/fzf.sh.tmpl`: Uses fd for fzf
  path and directory completion and for the default file candidate list.

# fzf

## Integration

- `chezmoi/dot_config/fish/conf.d/10_02-common-functions.fish.tmpl`: Uses fzf
  in the `alias-select` widget, bound to `Ctrl-E`, to choose an alias from the
  current Fish session.
- `chezmoi/dot_config/fish/conf.d/90_fzf.fish.tmpl`: Leaves fzf's Fish
  initialization disabled and explicitly assigns `Ctrl-R` to Atuin.
- `chezmoi/dot_config/fish/conf.d/90_zoxide.fish.tmpl`: Uses fzf for the
  preview-based zoxide directory picker bound to `Ctrl-Alt-Z`.
- `chezmoi/dot_config/zsh/conf.d/third-party/fzf.sh.tmpl`: Initializes native
  fzf Zsh keybindings and completions, then configures fd, bat, and eza for
  path candidates and previews.
- `chezmoi/dot_config/zsh/conf.d/third-party/zoxide.sh`: Uses fzf for the Zsh
  zoxide directory widget bound to `Alt-Ctrl-Z`.

# git

## Integration

- `chezmoi/dot_config/fish/conf.d/90_sk-git.fish`: Provides native Fish
  `sk-git` widgets that paste selected commit hashes (`Ctrl-G H`) or local
  branches (`Ctrl-G B`) into the command line with Git previews.
- `chezmoi/dot_config/zsh/conf.d/third-party/90_sk-git.sh`: Provides the
  native Zsh `sk` Git integration, preserving pickers for files, branches,
  tags, remotes, hashes, stashes, reflogs, each-ref, and worktrees. In the
  hashes picker, `Ctrl-O` opens the selected commit in a browser and `Ctrl-D`
  shows its diff.
- `chezmoi/dot_config/fish/conf.d/90_git.fish.tmpl`: Adds the `prgl` alias for
  a formatted graphical Git log and defines `gurl` to print the current
  repository's HTTPS URL.
- `chezmoi/dot_config/zsh/conf.d/third-party/git.sh`: Provides the same
  formatted Git log helper and repository URL function for Zsh.

# Homebrew

## Integration

- `chezmoi/dot_config/fish/conf.d/90_homebrew.fish.tmpl`: Sets Homebrew
  environment options on macOS and adds aliases plus the `bups` update helper.
- `chezmoi/dot_config/zsh/conf.d/third-party/homebrew.sh.tmpl`: Adds the same
  Homebrew aliases and update helper to Zsh on macOS.

# Jujutsu

## Integration

- `chezmoi/dot_config/fish/conf.d/90_jujutsu.fish`: Wraps `jj` in Fish so the
  `wq`, `wcd`, and `wacd` workspace commands can change the parent shell's
  directory.
- `chezmoi/dot_config/zsh/conf.d/third-party/jujutsu.sh`: Provides the same
  parent-shell directory handling for those Jujutsu workspace commands in Zsh.

# mise

## Integration

- `chezmoi/dot_config/fish/conf.d/90_mise.fish.tmpl`: Loads `mise activate
  fish` conditionally for the supported Linux and macOS environments.
- `chezmoi/dot_config/zsh/conf.d/third-party/mise.sh.tmpl`: Loads `mise
  activate zsh`, deferred when the Zsh defer helper is available.

# pet

## Integration

- `chezmoi/dot_config/pet/config.toml`: Configures Pet's interactive snippet
  selector to use Skim (`sk`) with a reverse layout and command preview.
- `chezmoi/dot_config/fish/conf.d/90_pet.fish.tmpl`: Binds `Ctrl-F` in Fish
  editing modes to search snippets and adds the `pexec` and `psc` aliases.
- `chezmoi/dot_config/fish/completions/pet.fish`: Provides Fish completions
  for Pet commands and options.
- `chezmoi/dot_config/zsh/conf.d/third-party/pet.sh`: Binds `Ctrl-F` in
  emacs, vi insert, and vi command modes to Pet snippet search and adds the
  `pexec` and `psc` aliases.
- `chezmoi/dot_config/zsh/completions/_pet`: Provides native Zsh completions
  for Pet commands and options.

# pueue

## Integration

- `chezmoi/dot_config/fish/conf.d/10_03-abbr.fish`: Defines short Fish
  abbreviations for `pueue`, starting its daemon, and resetting its queue.
- `chezmoi/dot_config/fish/completions/pueue.fish`: Provides Fish completions
  for Pueue subcommands, options, task IDs, groups, and directories.
- `chezmoi/dot_config/zsh/completions/_pueue`: Provides native Zsh completions
  for Pueue subcommands, options, and task arguments.

# sesh

## Integration

- `chezmoi/dot_config/fish/conf.d/90_sesh.fish`: Binds `Alt-U` in Fish's
  default, insert, and vi modes to execute the `sesh-connect-picker.sh`
  session picker.
- `chezmoi/dot_config/zsh/conf.d/third-party/sesh.sh`: Binds `Alt-U` in Zsh's
  emacs, vi insert, and vi command modes to the sesh picker widget.

# sk

## Integration

- `chezmoi/dot_config/fish/conf.d/90_sk-git.fish`: Uses `sk` for multi-select
  Git commit and local-branch pickers with adaptive previews and Fish-native
  key bindings.
- `chezmoi/dot_config/zsh/conf.d/third-party/90_sk-git.sh`: Provides the
  native Zsh `sk` Git picker set for files, branches, tags, remotes, hashes,
  stashes, reflogs, each-ref, and worktrees; the hashes picker keeps `Ctrl-O`
  for browser opening and `Ctrl-D` for diffs.
- `chezmoi/dot_config/fish/conf.d/99_skim.fish`: When both `sk` and `fd` are
  available, binds `Ctrl-T` in normal and insert Fish modes to a multi-select
  file/directory picker with adaptive previews from `bat` and `lla`; `Ctrl-E`
  opens all marked files in `$EDITOR`, `Ctrl-C` keeps the default cancellation
  behavior, and `Ctrl-D` changes into a highlighted directory before reopening
  the picker.
- `chezmoi/dot_config/zsh/conf.d/third-party/99_skim.sh`: Binds `Ctrl-T` to a
  Zsh Line Editor widget that uses fd for candidates and bat/lla for previews;
  `Ctrl-E` opens all marked files in `$EDITOR`, `Ctrl-C` keeps the default
  cancellation behavior, and `Ctrl-D` changes into a highlighted directory
  before reopening the picker.
  The binding is deferred when possible to reduce startup cost.

# television

## Integration

- `chezmoi/dot_config/television/cable/git-hashes.toml`: Browse commit hashes
  with `git show` previews.
- `chezmoi/dot_config/television/cable/git-branches.toml`: Browse local
  branches with graphical log previews.
- `chezmoi/dot_config/television/cable/git-files.toml`: Browse tracked files
  with file-history previews.
- `chezmoi/dot_config/television/cable/git-remotes.toml`: Browse remotes with
  remote log previews.
- `chezmoi/dot_config/television/cable/git-worktrees.toml`: Browse worktrees
  with status and log previews.
- `chezmoi/dot_config/television/cable/git-stashes.toml`: Browse stashes with
  `git show` previews.
- `chezmoi/dot_config/television/cable/git-reflogs.toml`: Browse reflog entries
  with `git show` previews.
- `chezmoi/dot_config/television/cable/git-tags.toml`: Browse tags with
  `git show` previews.

Invoke a channel directly, for example `tv xgit-branches` or
`tv xgit-hashes`. Normal confirmation still writes the selected value to
stdout.

Press `Ctrl-X` inside any `xgit-*` channel to search its object-specific
actions. The action picker includes browser, inspection, editing, and curated
Git mutation commands. Destructive actions are labeled `(destructive)`; they
execute without a second confirmation. After an action changes repository
state, press `Ctrl-R` when its description requests a reload.

Browser actions share
`~/.config/television/scripts/git-open`, which resolves HTTPS and SCP-style SSH
remotes, including configured SSH aliases, before using the platform opener.

# starship

## Integration

- `chezmoi/dot_config/fish/conf.d/90_starship.fish`: Initializes the Starship
  prompt for Fish.
- `chezmoi/dot_config/zsh/conf.d/third-party/starship.sh.tmpl`: Initializes
  the Starship prompt for Zsh when Starship is available.

# tmuxifier

## Integration

- `chezmoi/dot_config/fish/completions/tmuxifier.fish`: Provides lazy Fish
  completions for Tmuxifier sessions, windows, subcommands, and layout names.
- `chezmoi/dot_config/fish/conf.d/90_tmuxifier.fish`: Documents the intentional
  decision to skip startup initialization and rely on the completion file.
- `chezmoi/dot_config/zsh/conf.d/third-party/tmuxifier.sh`: Documents the same
  intentional decision for Zsh; the native initialization command is left
  disabled to avoid the extra startup cost.

# yazi

## Integration

- `chezmoi/dot_config/fish/conf.d/90_yazi.fish.tmpl`: Defines the `y` wrapper,
  which reads Yazi's final working directory and changes Fish into it.
- `chezmoi/dot_config/zsh/conf.d/third-party/yazi.sh`: Defines the equivalent
  `y` wrapper for Zsh and removes its temporary cwd file afterward.

# zoxide

## Integration

- `chezmoi/dot_config/fish/conf.d/90_zoxide.fish.tmpl`: Initializes zoxide for
  Fish and adds a preview-based directory picker on `Ctrl-Alt-Z`.
- `chezmoi/dot_config/zsh/conf.d/third-party/zoxide.sh`: Initializes zoxide
  for Zsh and adds the equivalent fzf-backed picker on `Alt-Ctrl-Z`.

<!-- markdownlint-enable MD013 MD024 MD025 -->
