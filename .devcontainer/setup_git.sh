#!/bin/bash
set -e

if [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_USER_EMAIL" ]; then
    echo "GIT_USER_NAME or GIT_USER_EMAIL is not set. Please set them in your local environment."
    exit 1
fi

git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
echo "Git global config updated: $GIT_USER_NAME <$GIT_USER_EMAIL>"
