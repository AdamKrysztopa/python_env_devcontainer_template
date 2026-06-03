# Python Template Repository

This template repository provides a ready-to-use Python development environment leveraging Docker and VS Code Dev Containers.

---

## Prerequisites

Make sure you have installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [VS Code Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Environment Variables

This is the **default identity** the dev container uses for *your own* projects. Export
your git name and email on the host and the container picks them up automatically:

**Linux / macOS:**

```bash
export GIT_USER_NAME="Your Git Username"
export GIT_USER_EMAIL="Your Git Email"
```

Optionally, add them to your `~/.bashrc`, `~/.zshrc`, or similar:

```bash
echo 'export GIT_USER_NAME="Your Git Username"' >> ~/.bashrc
echo 'export GIT_USER_EMAIL="Your Git Email"' >> ~/.bashrc
source ~/.bashrc
```

Alternatively, derive them from your existing global git config:

```bash
export GIT_USER_NAME=$(git config --get user.name)
export GIT_USER_EMAIL=$(git config --get user.email)
```

> For **client work** where the container must commit and push as *someone other than
> your host identity*, do not use these host variables — use the per-project setup in
> [Per-Project Git Identity & Credentials](#per-project-git-identity--credentials) instead.

---

## How to Use this Template

### Step-by-step Guide

1. **Create Repository from Template**:
   - Go to the [template repository](https://github.com/AdamKrysztopa/python_env_devcontainer_template).
   - Click the "Use this template" button and create your own repository.
   - Check that the **Initial Template Setup** GitHub Action ran successfully. If it did not, run the manual fallback in the step below after cloning.

2. **Clone Your New Repository**:

```bash
git clone https://github.com/your-username/your-new-repo.git
cd your-new-repo
```
3. **Open in VS Code with Dev Containers**:
   - Ensure Docker is running.
   - Open VS Code, use `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac), and select `Remote-Containers: Reopen in Container`.

   - *If the GitHub Action did not run successfully, please execute the `run_me_first.sh` script and remove the `.github/workflows/initial_setup.yml` file. This issue may arise depending on your github configuration.*

4. **Initial Setup (Automatic)**:
   - On your first push to `main`, GitHub Actions runs a renaming script that customizes your repository (replacing the `python_template_repo` placeholder), then removes itself.
   - No manual interaction is needed at this stage.

---

## Per-Project Git Identity & Credentials

Treat the dev container as an **isolation boundary** — a per-project `.env` for git, not
just Python. This is for **client work**, where commits must be attributed to (and pushed
with) the *client's* identity rather than your personal one.

### How it works

A single git-ignored file decides everything:

| State | Behavior |
| --- | --- |
| `.devcontainer/devcontainer.env` **present** | Client project: that identity (and any credentials) are applied **inside the container**. |
| **absent** | Your own project: falls back to the host `GIT_USER_*` variables above. Zero setup. |

Identity and credentials are written to the **container's** `~/.gitconfig` / `~/.ssh` only,
so committing from the host in the same folder still uses your personal identity. Nothing
about a client ever lands in version control — `.devcontainer/devcontainer.env` and
`.devcontainer/ssh/` are git-ignored, and a pre-commit hook blocks committing them even if
force-added.

### Recommended: SSH (deploy keys)

Run once per clone, then reopen/rebuild the container:

```bash
./scripts/setup-identity.sh
```

The script prompts for the client name/email and can **generate a per-project SSH key**,
printing the public key for you to register on the client's repo
(**Settings → Deploy keys → Add deploy key**, with write access). If the client gave you a
key instead, drop the private key into `.devcontainer/ssh/` and skip generation.

On container create, `.devcontainer/setup_git.sh` installs the key into the container's
`~/.ssh`, trusts the host, and rewrites an `https://github.com/...` `origin` to its SSH form
so `git push` "just works".

### Alternative: HTTPS + Personal Access Token (PAT)

If a client prefers tokens over SSH, skip the SSH key and instead edit
`.devcontainer/devcontainer.env` (copy it from `devcontainer.env.example`):

```bash
GIT_USER_NAME="Client Dev"
GIT_USER_EMAIL="dev@client.example"
GIT_CREDENTIAL_HOST="github.com"
GIT_CREDENTIAL_USERNAME="client-bot"     # any non-empty value works for a PAT
GIT_CREDENTIAL_TOKEN="ghp_xxxxxxxxxxxx"  # the client's PAT (e.g. a fine-grained token)
```

On create, `setup_git.sh` configures git's credential store inside the container
(`~/.git-credentials`, `chmod 600`) so HTTPS pushes authenticate as that token. Keep the
remote on its `https://` URL in this mode. The token is plaintext in a git-ignored file —
prefer a **fine-grained, repo-scoped, expiring** PAT, and revoke it when the engagement ends.

---

## Project Structure

```text
.
├── .devcontainer
│   ├── Dockerfile
│   ├── devcontainer.env.example  # Template for per-project identity/credentials
│   ├── devcontainer.json
│   └── setup_git.sh              # Applies identity + SSH/PAT creds in the container
├── .github
│   └── workflows
│       ├── ci.yml              # Lint + type-check + tests on push/PR
│       └── initial_setup.yml   # One-time template renaming (self-deletes)
├── scripts
│   ├── check-no-secrets.sh       # pre-commit guard: blocks committing creds
│   └── setup-identity.sh         # One-time per-project identity + SSH key setup
├── tests
│   └── test_main.py
├── .env.example
├── .gitignore
├── .pre-commit-config.yaml
├── .python-version
├── LICENSE
├── README.md
├── main.py
├── pyproject.toml
├── run_me_first.sh             # Renames placeholder; removed after first setup
└── uv.lock
```

---

## Dependency Management

This project uses [uv](https://docs.astral.sh/uv/). Install everything (including dev tools) with:

```bash
uv sync --extra dev
```

Add or remove dependencies with `uv add <pkg>` / `uv add --dev <pkg>` — this updates
both `pyproject.toml` and `uv.lock`. Don't edit `uv.lock` by hand.

The template ships with **no runtime dependencies** — add only what your project needs.

### Tool & dependency versioning

The strategy is deliberately **split** — know which parts float and which are locked:

| Thing | Pinned? | Where | How to update |
| --- | --- | --- | --- |
| **uv** (the tool) | ❌ latest at image build | `.devcontainer/Dockerfile` (`astral.sh/uv/install.sh`) | Rebuild the container; pin by switching to a versioned installer URL (`…/uv/<version>/install.sh`) |
| **ruff / pyright / pytest / pre-commit** | ✅ exact via lockfile | `>=` floors in `pyproject.toml`, exact versions in `uv.lock` | `uv lock --upgrade` (or `uv add --dev ruff@latest`), then commit `uv.lock` |
| **pre-commit hygiene hooks** | ✅ by `rev:` | `.pre-commit-config.yaml` | `uv run pre-commit autoupdate` |
| **Python** | ✅ `3.11` | `.python-version`, Dockerfile `VARIANT` | Bump both, re-sync |

The locked dev-tool set is what everyone actually runs: CI uses `uv sync --extra dev --locked`,
and the pre-commit hooks call the tools via `uv run` — so **local, CI, and commit-time all use
the identical versions** from `uv.lock`, no drift. Only uv itself can move underneath you on a
container rebuild; pin it as above if you need byte-reproducible images.

---

## Common Commands

```bash
uv run python main.py              # Run the entry point
uv run ruff check .                # Lint (autofixes enabled)
uv run ruff format .               # Format
uv run pyright                     # Type-check
uv run pytest                      # Run tests
uv run pre-commit run --all-files  # Run all pre-commit hooks manually
```

### Testing the Setup

```bash
uv run python main.py
```

Expected output:

```text
Hello from your-new-repo!
```

If you see the above message, your setup is successful. You can also run `uv run pytest`.

---

## Development Environment Details

### Python Version

- Python `3.11`

### Development Dependencies

- ruff — linting & formatting
- pyright — type checking
- pytest — testing
- pre-commit — git hooks (installed automatically in the dev container)

### Continuous Integration

`.github/workflows/ci.yml` runs ruff (lint + format check), pyright, and pytest on every
push to `main` and on every pull request.

### Pre-commit Hooks

Hooks are installed automatically by the dev container's `postCreateCommand`. To enable them
manually outside the container:

```bash
uv run pre-commit install
```

### VS Code Extensions Installed by Default

- Python
- Pylance
- Ruff
- ESLint
- Jupyter
- YAML Formatter
- Markdown All-in-One
- Prettier
- Shell-format
- Even Better TOML

### Code Formatting & Linting

- Formatting and linting configured via `ruff` (Google docstring style).

---

## Troubleshooting

If the Dev Container does not start or environment variables are missing, ensure:

- Docker is running.
- Environment variables `GIT_USER_NAME` and `GIT_USER_EMAIL` are correctly set.
- The Dev Containers extension in VS Code is installed and active.

---

## Customizing

Modify `pyproject.toml` and other configuration files to add dependencies and adjust settings as needed for your project.

---

### Contributing

Feel free to suggest improvements or open issues in the original repository.

Happy Coding! 🚀
