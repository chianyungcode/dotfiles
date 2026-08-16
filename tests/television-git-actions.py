#!/usr/bin/env python3

from __future__ import annotations

import pathlib
import sys

import tomllib

channel_dir = pathlib.Path(sys.argv[1])
ansi_selector = r"{split:\n:0|strip_ansi|split:\t:0}"
plain_selector = r"{split:\n:0}"
tab_selector = r"{split:\n:0|split:\t:0}"


def action(description: str, command: str, mode: str = "fork") -> dict[str, str]:
    return {
        "description": description,
        "command": command,
        "shell": "bash",
        "mode": mode,
        "separator": "\n",
    }


EXPECTED = {
    "git-hashes": {
        "open-browser": action(
            "Open commit in browser",
            f"$HOME/.config/television/scripts/git-open commit '{ansi_selector}'",
        ),
        "diff-working-tree": action(
            "Diff commit against working tree",
            f"git diff --color=always '{ansi_selector}'",
        ),
        "checkout-detached": action(
            "Checkout commit detached (modifies repository; Ctrl-R to reload)",
            f"git switch --detach '{ansi_selector}'",
        ),
        "cherry-pick": action(
            "Cherry-pick commit (modifies repository; Ctrl-R to reload)",
            f"git cherry-pick '{ansi_selector}'",
        ),
        "revert": action(
            "Revert commit (modifies repository; Ctrl-R to reload)",
            f"git revert '{ansi_selector}'",
        ),
    },
    "git-branches": {
        "open-browser": action(
            "Open branch in browser",
            f"$HOME/.config/television/scripts/git-open branch '{ansi_selector}'",
        ),
        "switch": action(
            "Switch branch (modifies repository; Ctrl-R to reload)",
            f"git switch '{ansi_selector}'",
        ),
        "merge": action(
            "Merge selected branch into current (modifies repository; Ctrl-R to reload)",
            f"git merge '{ansi_selector}'",
        ),
        "rebase": action(
            "Rebase current branch onto selected (modifies repository; Ctrl-R to reload)",
            f"git rebase '{ansi_selector}'",
        ),
        "delete": action(
            "Delete local branch (destructive; Ctrl-R to reload)",
            f"git branch -d '{ansi_selector}'",
        ),
    },
    "git-tags": {
        "open-browser": action(
            "Open tag in browser",
            f"$HOME/.config/television/scripts/git-open tag '{ansi_selector}'",
        ),
        "checkout-detached": action(
            "Checkout tag detached (modifies repository; Ctrl-R to reload)",
            f"git switch --detach '{ansi_selector}'",
        ),
        "push-origin": action(
            "Push tag to origin (modifies remote)",
            f"git push origin '{ansi_selector}'",
        ),
        "delete": action(
            "Delete local tag (destructive; Ctrl-R to reload)",
            f"git tag -d '{ansi_selector}'",
        ),
    },
    "git-files": {
        "open-browser": action(
            "Open file in browser",
            f"$HOME/.config/television/scripts/git-open file '{plain_selector}'",
        ),
        "edit": action(
            "Edit file",
            f'${{EDITOR:-vi}} -- \'{plain_selector}\'',
        ),
        "stage": action(
            "Stage file (modifies repository; Ctrl-R to reload)",
            f"git add -- '{plain_selector}'",
        ),
        "restore": action(
            "Restore file (destructive; Ctrl-R to reload)",
            f"git restore --worktree -- '{plain_selector}'",
        ),
    },
    "git-remotes": {
        "open-browser": action(
            "Open remote in browser",
            f"$HOME/.config/television/scripts/git-open remote '{tab_selector}'",
        ),
        "fetch": action(
            "Fetch remote (modifies repository; Ctrl-R to reload)",
            f"git fetch '{tab_selector}'",
        ),
        "fetch-prune": action(
            "Fetch and prune remote (destructive; Ctrl-R to reload)",
            f"git fetch --prune '{tab_selector}'",
        ),
    },
    "git-worktrees": {
        "shell": action(
            "Open shell in worktree",
            f'cd \'{tab_selector}\' && exec "${{SHELL:-/bin/sh}}" -l',
            mode="execute",
        ),
        "edit": action(
            "Edit worktree",
            f'${{EDITOR:-vi}} -- \'{tab_selector}\'',
        ),
        "remove": action(
            "Remove worktree (destructive; Ctrl-R to reload)",
            f"git worktree remove '{tab_selector}'",
        ),
    },
    "git-stashes": {
        "apply": action(
            "Apply stash (modifies repository; Ctrl-R to reload)",
            f"git stash apply '{ansi_selector}'",
        ),
        "pop": action(
            "Pop stash (destructive; Ctrl-R to reload)",
            f"git stash pop '{ansi_selector}'",
        ),
        "drop": action(
            "Drop stash (destructive; Ctrl-R to reload)",
            f"git stash drop '{ansi_selector}'",
        ),
    },
    "git-reflogs": {
        "checkout-detached": action(
            "Checkout reflog entry detached (modifies repository; Ctrl-R to reload)",
            f"git switch --detach '{ansi_selector}'",
        ),
        "cherry-pick": action(
            "Cherry-pick reflog entry (modifies repository; Ctrl-R to reload)",
            f"git cherry-pick '{ansi_selector}'",
        ),
        "hard-reset": action(
            "Hard-reset to reflog entry (destructive; Ctrl-R to reload)",
            f"git reset --hard '{ansi_selector}'",
        ),
    },
}


for channel_name, expected_actions in EXPECTED.items():
    filename = channel_dir / f"{channel_name}.toml"
    with filename.open("rb") as channel_file:
        channel = tomllib.load(channel_file)
    assert "keybindings" not in channel, f"{channel_name} overrides global keybindings"
    assert channel.get("actions") == expected_actions, (
        f"{channel_name} action contract mismatch:\n"
        f"expected={expected_actions!r}\nactual={channel.get('actions')!r}"
    )

print("television Git action contract passed")
