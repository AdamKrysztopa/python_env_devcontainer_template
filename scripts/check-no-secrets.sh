#!/bin/bash
# pre-commit guard: refuse to commit per-project dev container secrets.
#
# .devcontainer/devcontainer.env and .devcontainer/ssh/ are git-ignored, but a
# stray `git add -f` could still stage them. This hook is the backstop: if any
# such file is staged, the commit is blocked.
set -euo pipefail

if [ "$#" -gt 0 ]; then
    echo "ERROR: refusing to commit dev container secrets:" >&2
    printf '  %s\n' "$@" >&2
    echo >&2
    echo "These hold a client's git identity / SSH key and must never be committed." >&2
    echo "If you are certain, override with: git commit --no-verify" >&2
    exit 1
fi
