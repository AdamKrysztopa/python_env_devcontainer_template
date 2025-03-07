# Use the official Python image as a base
ARG VARIANT="3.11"
FROM python:${VARIANT}

# Install uv using the official installer
RUN apt-get update && apt-get install -y curl ca-certificates \
    && curl -LsSf https://astral.sh/uv/install.sh | sh \
    && cp /root/.local/bin/uv /usr/local/bin/uv

# Install other tools
RUN pip install pyright ruff uvicorn

# Create directory for our custom Python symlinks if it doesn't exist
RUN mkdir -p /opt/uv/python_template_repo/bin

# Create symlinks to the container's python3 as both "python" and "python3"
RUN ln -sf "$(which python3)" /opt/uv/python_template_repo/bin/python \
    && ln -sf "$(which python3)" /opt/uv/python_template_repo/bin/python3

# Update PATH so that our custom directory comes first
ENV PATH="/opt/uv/python_template_repo/bin:/usr/local/bin:$PATH"

# Create a non-root user with home /home/vscode
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME

# Set the default shell to bash
SHELL ["/bin/bash", "-c"]

# Update PATH so that our custom directory comes first, but also include the default system paths.
ENV PATH="/opt/uv/python_template_repo/bin:/usr/local/bin:$PATH"

# Switch to non-root user
USER $USERNAME