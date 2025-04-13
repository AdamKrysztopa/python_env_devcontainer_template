# Official Python base
ARG VARIANT="3.11"
FROM python:${VARIANT}

# Install uv and necessary tools
RUN apt-get update && apt-get install -y curl ca-certificates \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && cp /root/.local/bin/uv /usr/local/bin/uv \
    && pip install pyright ruff uvicorn

# Create vscode user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME

# Set default shell
SHELL ["/bin/bash", "-c"]

# Ensure workspace directory exists and is owned by vscode user
RUN mkdir -p /workspace && chown -R $USERNAME:$USERNAME /workspace
WORKDIR /workspace

# Switch to vscode user
USER $USERNAME

# Create virtual environment at workspace folder
RUN uv venv .venv

# Update PATH
ENV PATH="/workspace/.venv/bin:$PATH"