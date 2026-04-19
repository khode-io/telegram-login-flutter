# Contributing to Telegram Login

Thank you for your interest in contributing to Telegram Login! We welcome contributions from the community.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/telegram-login-flutter.git`
3. Create a new branch: `git checkout -b feature/my-feature`

## Development Setup

### Prerequisites

- Flutter SDK >=3.3.0
- Dart SDK ^3.6.0
- Android SDK (for Android development)
- Xcode 15+ (for iOS development)

### Package Structure

This is a monorepo with the following structure:

```
telegram_login_flutter/
├── packages/
│   └── telegram_login/     # Main plugin package
├── examples/
│   └── telegram_login/     # Example app
└── docs/                   # Documentation site
```

### Running the Example

```bash
cd examples/telegram_login
flutter pub get
flutter run
```

## Making Changes

1. Make your changes in the appropriate package directory
2. Write or update tests as needed
3. Ensure all tests pass: `flutter test`
4. Update documentation if needed

## Submitting Changes

1. Commit your changes: `git commit -am "Add new feature"`
2. Push to your fork: `git push origin feature/my-feature`
3. Open a Pull Request against the main repository

## Pull Request Guidelines

- Provide a clear description of the changes
- Reference any related issues
- Ensure CI checks pass
- Keep changes focused and atomic

## Code Style

- Follow the Dart style guide
- Use `dart format` to format your code
- Run `flutter analyze` to check for issues

## Testing

- Write unit tests for new functionality
- Test on both iOS and Android if your changes affect platform code
- Ensure the example app still works

## Documentation

- Update README.md if you change the API
- Add comments to public APIs
- Update the docs site if needed

## Questions?

Feel free to open an issue for questions or discussion.

Thank you for contributing!
