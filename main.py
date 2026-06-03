"""Entry point module for the template application."""


def greeting() -> str:
    """Return the application's greeting message.

    Returns:
        The greeting string shown on startup.
    """
    return 'Hello from python_template_repo!'


def main() -> None:
    """Print the greeting message."""
    print(greeting())


if __name__ == '__main__':
    main()
