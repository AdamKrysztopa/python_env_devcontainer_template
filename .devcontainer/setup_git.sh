#!/bin/bash
# Configure the dev container's git identity and (optionally) credentials.
#
# The dev container is the isolation unit ("an .env on steroids"):
#   * .devcontainer/devcontainer.env present -> client project: use its identity
#   * else host-provided GIT_USER_* env vars  -> your own project: inherit host
#   * else                                    -> warn and continue (never fail create)
#
# Identity (user.name/email), SSH keys and HTTPS tokens are written to the
# CONTAINER's HOME (~/.gitconfig, ~/.ssh, ~/.git-credentials), so your host
# identity and keys are never touched.
#
# Runs automatically via postCreateCommand; safe to re-run:
#   bash .devcontainer/setup_git.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/devcontainer.env"
SSH_SRC_DIR="$SCRIPT_DIR/ssh"

# 1. Load the per-project file if present (its values win over host env).
if [ -f "$ENV_FILE" ]; then
    echo "Loading project git config from $ENV_FILE"
    set -a
    # shellcheck disable=SC1090
    source "$ENV_FILE"
    set +a
fi

GIT_CREDENTIAL_HOST="${GIT_CREDENTIAL_HOST:-github.com}"

# 2. Identity (commit attribution).
if [ -n "${GIT_USER_NAME:-}" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
    git config --global user.name "$GIT_USER_NAME"
    git config --global user.email "$GIT_USER_EMAIL"
    echo "Git identity set: $GIT_USER_NAME <$GIT_USER_EMAIL>"
else
    echo "WARNING: git identity not configured."
    echo "  Run ./scripts/setup-identity.sh for this project,"
    echo "  or export GIT_USER_NAME / GIT_USER_EMAIL on your host."
fi

# 3. Credentials. Prefer an SSH key; otherwise fall back to an HTTPS PAT.
priv_key=""
if [ -d "$SSH_SRC_DIR" ]; then
    shopt -s nullglob
    for f in "$SSH_SRC_DIR"/*; do
        [ -f "$f" ] || continue
        case "$(basename "$f")" in
            *.pub | known_hosts | config | *.md | .gitkeep) continue ;;
        esac
        priv_key="$f"
        break
    done
fi

if [ -n "$priv_key" ]; then
    # --- SSH (recommended) ---
    key_name="$(basename "$priv_key")"
    install -d -m 700 "$HOME/.ssh"
    cp "$priv_key" "$HOME/.ssh/$key_name"
    chmod 600 "$HOME/.ssh/$key_name"

    # Trust the host so the first push is non-interactive.
    ssh-keyscan "$GIT_CREDENTIAL_HOST" >>"$HOME/.ssh/known_hosts" 2>/dev/null || true
    [ -f "$HOME/.ssh/known_hosts" ] && sort -u "$HOME/.ssh/known_hosts" -o "$HOME/.ssh/known_hosts"

    # Point the host at our key (idempotent).
    if ! grep -qs "IdentityFile ~/.ssh/$key_name" "$HOME/.ssh/config" 2>/dev/null; then
        {
            echo "Host $GIT_CREDENTIAL_HOST"
            echo "  IdentityFile ~/.ssh/$key_name"
            echo "  IdentitiesOnly yes"
        } >>"$HOME/.ssh/config"
        chmod 600 "$HOME/.ssh/config"
    fi
    echo "SSH credentials installed for $GIT_CREDENTIAL_HOST (key: $key_name)"

    # Convenience: rewrite an HTTPS GitHub origin to SSH so pushes use the key.
    REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
    if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        origin="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)"
        if [[ "$origin" =~ ^https://github\.com/(.+)$ ]]; then
            path="${BASH_REMATCH[1]%.git}"
            new="git@github.com:${path}.git"
            git -C "$REPO_ROOT" remote set-url origin "$new"
            echo "Rewrote origin to SSH: $new"
        fi
    fi
elif [ -n "${GIT_CREDENTIAL_TOKEN:-}" ]; then
    # --- HTTPS + Personal Access Token (alternative) ---
    user="${GIT_CREDENTIAL_USERNAME:-x-access-token}"
    git config --global credential.helper store
    printf 'https://%s:%s@%s\n' "$user" "$GIT_CREDENTIAL_TOKEN" "$GIT_CREDENTIAL_HOST" \
        >"$HOME/.git-credentials"
    chmod 600 "$HOME/.git-credentials"
    echo "HTTPS credentials installed for $GIT_CREDENTIAL_HOST (user: $user)"
else
    echo "No SSH key in $SSH_SRC_DIR and no PAT set — skipping credential setup."
fi
