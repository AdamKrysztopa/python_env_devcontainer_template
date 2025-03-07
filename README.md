# Python Template Repository

This template repository provides a ready-to-use Python development environment leveraging Docker and VS Code Dev Containers.

---

## Prerequisites

Make sure you have installed:

- [Docker](https://docs.docker.com/get-docker/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [VS Code Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

### Environment Variables

Set the following environment variables on your system before proceeding:

If the git username and email you need to use is different from one on the global settings, use:
**Linux / macOS:**

```bash
export GIT_USER_NAME="Your Git Username"
export GIT_USER_EMAIL="Your Git Email"
```

Optionally, you can add them to your `~/.bashrc`, `~/.zshrc`, or similar:

```bash
echo 'export GIT_USER_NAME="Your Git Username"' >> ~/.bashrc
echo 'export GIT_USER_EMAIL="Your Git Email"' >> ~/.bashrc
source ~/.bashrc
```

elsewere, all exports can be replaced with:

```bash
export GIT_USER_NAME=$(git config --get user.name)
export GIT_USER_EMAIL=$(git config --get user.email)
```

---

## How to Use this Template

### Step-by-step Guide

1. **Create Repository from Template**:
   - Go to the [template repository](https://github.com/AdamKrysztopa/template_repo).
   - Click the "Use this template" button and create your own repository.
   - Now you can check if github action went correct, if not need to do the step in after repo clonning.

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
   - On creating your first branch, GitHub Actions will automatically run a renaming script to customize your repository.
   - No manual interaction is needed at this stage.

---

## Project Structure

```text
.
├── .devcontainer
│   ├── Dockerfile
│   ├── devcontainer.json
│   └── setup_git.sh
├── main.py
└── pyproject.toml
```

---

## Testing the Setup

Run the provided Python script to confirm everything is set up correctly:

```bash
python main.py
```

Expected output:

```text
Hello from your-new-repo!
```

If you see the above message, your setup is successful.

---

## Development Environment Details

### Python Version

- Python `3.11`

### Default Python Packages

Included libraries:

- numpy
- pandas
- plotly
- uvicorn
- ipykernel

Development dependencies:

- ruff
- pyright

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

