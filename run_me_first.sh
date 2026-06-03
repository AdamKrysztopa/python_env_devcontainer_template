#!/bin/bash
set -e

# Determine the new repository name from the current directory
NEW_REPO_NAME=$(basename "$PWD")

echo "Renaming 'python_template_repo' to '$NEW_REPO_NAME' in all files..."

# Find and process all files except this script itself. Prune directories that
# can't contain (or shouldn't be touched by) the placeholder: .git holds binary
# pack files, .venv is environment-specific, __pycache__ is generated.
find . \
    -type d \( -name .git -o -name .venv -o -name __pycache__ \) -prune -o \
    -type f ! -name "$(basename "$0")" -print0 | while IFS= read -r -d '' file; do
    if grep -q "python_template_repo" "$file"; then
        # Use the appropriate sed option depending on OS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/python_template_repo/$NEW_REPO_NAME/g" "$file"
        else
            sed -i "s/python_template_repo/$NEW_REPO_NAME/g" "$file"
        fi
        echo "Updated: $file"
    fi
done

echo "Replacement complete. Removing the script..."
rm -- "$0"
