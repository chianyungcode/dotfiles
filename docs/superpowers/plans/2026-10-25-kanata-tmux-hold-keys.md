# Kanata tmux Hold Keys Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `a` and `;` tap normally and activate the tmux layer when held; leave `'` as a plain key.

**Architecture:** Give `a` the existing tmux hold action and define a dedicated `;` tap-hold alias, preserving each tap key. Replace `a`'s current sublayers hold behavior.

**Tech Stack:** Kanata configuration, chezmoi template.

**Spec:** `docs/superpowers/specs/2026-10-25-kanata-tmux-hold-keys-design.md`

## Global Constraints

- Change only the base-layer aliases/key mappings in `chezmoi/dot_config/kanata/parts/core.kbd.tmpl`.
- Do not change tap/hold timings or tmux-layer mappings.
- No test fixture is planned for this config-only change.

## Review Focus

- Tapping `a` or `;` still emits its normal character; retain each as the tap action of its tap-hold mapping.
- Holding either key selects `tmux`; `'` remains a plain key.
- No remaining base-layer mapping uses `a` for the `sublayers` hold.

---

### Task 1: Update base-layer tmux hold keys

**Files:**
- Modify: `chezmoi/dot_config/kanata/parts/core.kbd.tmpl`

- [ ] Change `a`'s tap-hold mapping to use `@lwh_tmux` as its hold action.
- [ ] Add a dedicated semicolon tap-hold alias whose tap is `;` and hold is `@lwh_tmux`; use it at the base-layer `;` position.
- [ ] Verify the template/config using available repository tooling; confirm mappings and that the rendered Kanata config parses, if a parser/check command is available.
