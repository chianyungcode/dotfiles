# Chezmoi Phase Headers Design

## Summary

Restore a clear visual boundary between Chezmoi script phases. Every non-empty
phase will print a sparkle-delimited header containing its `PHASE` identifier
before any phase-specific work begins.

For example, phase 10 starts with:

```text
✨ 10-system-packages ✨
```

## Context

Before the phase-oriented script refactor, `shared_script_utils.bash` exposed a
`header()` function that printed a blank line followed by a
sparkle-delimited heading. The refactored `scripts/core.bash` retained
phase-prefixed informational and error messages, but it no longer announces
the start of a phase. Consecutive phases therefore lack a clear visual
boundary in `chezmoi apply` output.

## Design

`chezmoi/.chezmoitemplates/scripts/core.bash` will own phase announcement.
After validating that `PHASE` is set, the core will print:

```text

✨ <PHASE> ✨
```

The shared core is rendered near the beginning of every non-empty phase
entrypoint, before phase-specific templates, data setup, or commands. Placing
the announcement in the core gives all phases the same behavior without
duplicating calls across eight entrypoints.

The header will be plain text without terminal-color detection. The existing
`info()`, `notice()`, `die()`, and error-trap formats remain unchanged.

Conditionally empty phases remain silent because their templates do not render
or execute the shared core.

## Execution Contract

For every non-empty rendered phase:

1. Bash starts and validates `PHASE`.
2. The phase header is the first user-facing output.
3. Phase-specific work begins.
4. Existing informational or error output continues to include the phase
   identifier in brackets.

If core initialization fails before the header can be printed, Bash may exit
without a phase announcement. No package installation or other phase-specific
work will have started in that case.

## Testing

Extend the shared-core behavior fixture to assert:

- the sparkle-delimited header is present;
- it is the first output line after the intentional leading blank line; and
- it appears before the fixture's phase-specific completion message.

The existing render and behavior suites will continue validating all phase
templates and shell behavior.

## Non-Goals

- Restoring the old 452-line shared utility.
- Restoring its color, logging, or alert-level machinery.
- Adding end-of-phase banners or duration reporting.
- Changing Chezmoi phase names, ordering, or run conditions.
