# Chezmoi Phase Headers Implementation Plan

<!-- markdownlint-disable MD013 -->

> **For agentic workers:** REQUIRED SUB-SKILL: Use
> superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use
> checkbox (`- [ ]`) syntax for tracking.

**Goal:** Print a sparkle-delimited phase header before every non-empty
Chezmoi phase begins its phase-specific work.

**Architecture:** Keep phase announcement in the shared Bash core rendered by
every non-empty entrypoint. Assert the core fixture's complete stdout so the
test proves both the exact format and its position before phase work.

**Tech Stack:** Bash 3.2-compatible shell, Chezmoi Go templates, ripgrep,
ShellCheck, Jujutsu

## Global Constraints

- The phase header format is exactly `✨ <PHASE> ✨`, preceded by one blank line.
- The header is the first user-facing output from every non-empty phase.
- Conditionally empty phases remain silent.
- Existing phase-prefixed informational and error formats remain unchanged.
- Do not restore terminal-color detection or other legacy utility behavior.
- Preserve unrelated working-copy changes and use `jj` for version control.

---

### Task 1: Announce Phases from the Shared Core

**Files:**

- Modify: `tests/chezmoi-script-behavior.sh:73-76`
- Modify: `chezmoi/.chezmoitemplates/scripts/core.bash:3-5`

**Interfaces:**

- Consumes: Each entrypoint assigns a non-empty string to the `PHASE` shell
  variable before rendering `scripts/core.bash`.
- Produces: The shared core writes `\n✨ $PHASE ✨\n` to stdout exactly once
  before returning control to phase-specific rendered code.

- [ ] **Step 1: Write the failing shared-core output assertion**

Replace the loose success-output assertion in
`tests/chezmoi-script-behavior.sh`:

```bash
rg -q '\[core-test\] fixture complete' <<<"$success_output"
```

with an exact output contract:

```bash
expected_success_output=$'\n✨ core-test ✨\n[core-test] fixture complete'
if [[ "$success_output" != "$expected_success_output" ]]; then
    printf 'unexpected core output:\n%s\n' "$success_output" >&2
    exit 1
fi
```

This names the production change that will make the test pass: the shared core
must prepend the exact phase header. Comparing the entire fixture stdout also
proves that the header precedes the fixture's phase-specific `info()` call and
is emitted only once.

- [ ] **Step 2: Run the behavior suite and verify the new assertion fails**

Run:

```bash
./tests/chezmoi-script-behavior.sh
```

Expected: FAIL near the start with:

```text
unexpected core output:
[core-test] fixture complete
```

The failure must be caused by the absent phase header, not a missing command,
render error, or unrelated fixture failure.

- [ ] **Step 3: Add the minimal shared-core announcement**

In `chezmoi/.chezmoitemplates/scripts/core.bash`, add the `printf` immediately
after the existing `PHASE` validation:

```bash
: "${PHASE:?PHASE must be set before loading scripts/core.bash}"

printf '\n✨ %s ✨\n' "$PHASE"

TEMP_DIR=""
```

Do not add a separate public helper: every phase must announce itself once
during shared-core initialization, and no current caller needs to print an
additional header.

- [ ] **Step 4: Run the focused behavior suite and verify it passes**

Run:

```bash
./tests/chezmoi-script-behavior.sh
```

Expected: PASS with exit status 0 and no stderr.

- [ ] **Step 5: Run render and static verification**

Run:

```bash
./tests/chezmoi-render-scripts.sh
shellcheck tests/chezmoi-script-behavior.sh
shellcheck chezmoi/.chezmoitemplates/scripts/core.bash
```

Expected: all three commands pass with exit status 0. The render suite proves
that representative macOS, Ubuntu, and Arch entrypoints still render and
parse; ShellCheck proves the changed source and test remain statically valid.

- [ ] **Step 6: Review the scoped diff**

Run:

```bash
jj diff -- tests/chezmoi-script-behavior.sh \
    chezmoi/.chezmoitemplates/scripts/core.bash
```

Expected: only the exact-output regression assertion and one shared-core
`printf` are present. Existing user changes elsewhere remain untouched.

- [ ] **Step 7: Commit the implementation**

Run:

```bash
jj commit -m "feat(chezmoi): announce script phases" \
    tests/chezmoi-script-behavior.sh \
    chezmoi/.chezmoitemplates/scripts/core.bash
```

Expected: a new commit containing only the two implementation files, leaving
all unrelated working-copy changes in the current change.
