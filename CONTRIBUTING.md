# Contributing to OpenAI Link Analyzer

Thank you for your interest in contributing to the OpenAI Link Analyzer plugin for Discourse! This document provides guidelines and instructions for contributing to this project.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork to your local machine
3. Set up a Discourse development environment following the [official guide](https://meta.discourse.org/t/beginners-guide-to-install-discourse-for-development-using-docker/102009)
4. Place the plugin in the `plugins` directory of your Discourse installation
5. Start the development server

## Development Workflow

1. Create a new branch for your feature or bugfix
2. Make your changes
3. Write or update tests for your changes
4. Run the tests to ensure they pass
5. Submit a pull request

## Running Tests

### Frontend Tests

```sh
bin/rails plugin:qunit['openai-link-analyzer']
```

### Backend Tests

```sh
LOAD_PLUGINS=1 bin/rails plugin:spec['openai-link-analyzer']
```

## Code Style

- Follow the [Discourse coding standards](https://meta.discourse.org/t/discourse-coding-standards/66967)
- Use 2 spaces for indentation
- Keep lines under 100 characters when possible
- Write clear, descriptive commit messages

## Adding Features

When adding new features, please:

1. Update the documentation in README.md
2. Add appropriate tests
3. Update translations if adding user-facing text
4. Consider performance implications

## Reporting Bugs

If you find a bug, please create an issue on GitHub with:

1. A clear description of the bug
2. Steps to reproduce
3. Expected behavior
4. Actual behavior
5. Screenshots if applicable
6. Your environment details (Discourse version, browser, etc.)

## Pull Request Process

1. Update the README.md with details of changes if applicable
2. Update the version number in plugin.rb following [SemVer](https://semver.org/)
3. The PR will be merged once it has been reviewed and approved

## License

By contributing to this project, you agree that your contributions will be licensed under the project's MIT license.

## Questions?

If you have any questions about contributing, please open an issue or contact the maintainers. 