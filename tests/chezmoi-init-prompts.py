#!/usr/bin/env python3

from __future__ import annotations

import os
import pathlib
import pty
import select
import shutil
import subprocess
import sys
import tempfile
import time

ROLE = "Choose this machine's primary role?"
IDENTITY = "Choose your identity profile?"
DEVELOPMENT = "Enable development tools?"
HOMELAB = "Enable homelab tools?"
PERSONAL = "Enable personal tools?"
GRAPHICAL = "Enable graphical tools?"
SECRETS = "Choose the secrets provider?"
AGE = "Enable Age-encrypted files?"
ALL_QUESTIONS = (ROLE, IDENTITY, DEVELOPMENT, HOMELAB, PERSONAL, GRAPHICAL, SECRETS, AGE)


def fail(message: str, transcript: str) -> None:
    print(message, file=sys.stderr)
    print("----- prompt transcript -----", file=sys.stderr)
    print(transcript, file=sys.stderr)
    raise SystemExit(1)


def run_case(repo_root: pathlib.Path, name: str, expected: list[tuple[str, str]]) -> str:
    with tempfile.TemporaryDirectory(prefix=f"chezmoi-{name}-") as temp_name:
        temp_root = pathlib.Path(temp_name)
        source_dir = temp_root / "source"
        data_dir = source_dir / ".chezmoidata"
        data_dir.mkdir(parents=True)
        shutil.copy2(repo_root / "chezmoi" / ".chezmoi.toml.tmpl", source_dir / ".chezmoi.toml.tmpl")
        shutil.copy2(repo_root / "chezmoi" / ".chezmoidata" / "accounts.toml", data_dir / "accounts.toml")
        command = ["chezmoi", "--cache", str(temp_root / "cache"), "--persistent-state", str(temp_root / "state.boltdb"), "-S", str(source_dir), "-c", str(temp_root / "chezmoi.toml"), "-D", str(temp_root / "home"), "init", "--prompt"]
        environment = os.environ.copy()
        environment["TERM"] = "dumb"
        environment["NO_COLOR"] = "1"
        master_fd, slave_fd = pty.openpty()
        process = subprocess.Popen(command, stdin=slave_fd, stdout=slave_fd, stderr=slave_fd, env=environment, close_fds=True)
        os.close(slave_fd)
        transcript = ""
        seen: set[str] = set()
        expected_index = 0
        deadline = time.monotonic() + 20
        try:
            while process.poll() is None:
                if time.monotonic() > deadline:
                    process.kill()
                    fail(f"{name}: timed out waiting for prompts", transcript)
                ready, _, _ = select.select([master_fd], [], [], 0.2)
                if not ready:
                    continue
                try:
                    chunk = os.read(master_fd, 4096)
                except OSError:
                    break
                if not chunk:
                    break
                transcript += chunk.decode("utf-8", errors="replace")
                for question in ALL_QUESTIONS:
                    question_offset = transcript.find(question)
                    if question_offset < 0 or question in seen:
                        continue
                    if transcript.find("> ", question_offset) < 0:
                        continue
                    if expected_index >= len(expected):
                        process.kill()
                        fail(f"{name}: unexpected prompt {question!r}", transcript)
                    expected_question, answer = expected[expected_index]
                    if question != expected_question:
                        process.kill()
                        fail(f"{name}: expected {expected_question!r}, got {question!r}", transcript)
                    seen.add(question)
                    expected_index += 1
                    payload = answer or ("server" if question == ROLE else "")
                    os.write(master_fd, payload.encode("utf-8") + b"\r")
            return_code = process.wait(timeout=5)
        finally:
            os.close(master_fd)
        if return_code != 0:
            fail(f"{name}: chezmoi init exited with {return_code}", transcript)
        if expected_index != len(expected):
            missing = [question for question, _ in expected[expected_index:]]
            fail(f"{name}: missing prompts: {missing}", transcript)
        positions = [transcript.index(question) for question, _ in expected]
        if positions != sorted(positions):
            fail(f"{name}: prompts appeared out of order", transcript)
        return transcript


def main() -> None:
    repo_root = pathlib.Path(__file__).resolve().parents[1]
    if shutil.which("chezmoi") is None:
        raise SystemExit("missing required command: chezmoi")
    server_transcript = run_case(repo_root, "server", [(ROLE, ""), (DEVELOPMENT, ""), (HOMELAB, "")])
    for forbidden in (IDENTITY, PERSONAL, GRAPHICAL, SECRETS, AGE):
        if forbidden in server_transcript:
            fail(f"server: forbidden prompt appeared: {forbidden!r}", server_transcript)
    run_case(repo_root, "workstation", [(ROLE, "workstation"), (IDENTITY, ""), (DEVELOPMENT, ""), (HOMELAB, ""), (PERSONAL, ""), (GRAPHICAL, ""), (SECRETS, ""), (AGE, "")])
    print("chezmoi init prompt flow passed")


if __name__ == "__main__":
    main()
