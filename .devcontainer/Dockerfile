# Official Python base
ARG VARIANT="3.11"
FROM python:${VARIANT}

# Install uv. The project's .venv is created in the workspace folder by the
# devcontainer postCreateCommand (`uv sync`), not here — VS Code bind-mounts the
# repo to /workspaces/<repo>, so a venv baked into the image would be orphaned.
#
# NOTE: this pulls the LATEST uv at image build time — uv itself is intentionally
# NOT pinned, so rebuilding the container may pick up a newer uv. To pin it for
# reproducible image builds, use a versioned installer URL instead, e.g.:
#   curl -LsSf https://astral.sh/uv/0.5.11/install.sh | sh
# (The Python toolchain — ruff/pyright/pytest — IS pinned via uv.lock; see README.)
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && cp /root/.local/bin/uv /usr/local/bin/uv \
    && rm -rf /var/lib/apt/lists/*

# Create vscode user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME

# Set default shell
SHELL ["/bin/bash", "-c"]

# Switch to vscode user
USER $USERNAME
