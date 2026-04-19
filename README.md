# Telegram Login

A Flutter plugin that wraps the official Telegram Login SDK and exposes a Dart API for signing users in with their Telegram account.

[![pub package](https://img.shields.io/pub/v/telegram_login.svg)](https://pub.dev/packages/telegram_login)
[![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

## Packages

| Package                                                                                                          | Pub                                                                                                |
| ---------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| [telegram_login](packages/telegram_login/)                                                                       | [pub package](https://pub.dev/packages/telegram_login)                                             |

## Features

- Native OAuth flow powered by the official Telegram SDKs
- iOS: Universal Links (iOS 17.4+) and Custom URL Schemes (fallback)
- Android: App Links support
- Automatic URL callback forwarding — no `AppDelegate` / `Activity` wiring required
- `cancelLogin()` for user-driven cancellation; late native callbacks are discarded

## Quick Start

```dart
import 'package:telegram_login/telegram_login.dart';

final telegramLogin = TelegramLogin();

await telegramLogin.configure(
  const TelegramLoginConfiguration(
    clientId: 'YOUR_BOT_CLIENT_ID',
    redirectUri: 'https://app12345-login.tg.dev',
    scopes: ['profile'],
  ),
);

try {
  final result = await telegramLogin.login();
  print('ID Token: ${result.idToken}');
  // Send result.idToken to your backend for verification.
} on TelegramLoginError catch (e) {
  print('Login failed: ${e.code.name} — ${e.message}');
}
```

## Documentation

- [Package README](packages/telegram_login/README.md) - Detailed API documentation
- [Example](examples/telegram_login/) - Runnable example app

## Contributing

We welcome contributions! Please read our [Contributing Guide](CONTRIBUTING.md) for details on how to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
