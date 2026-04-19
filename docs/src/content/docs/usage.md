---
title: Usage
description: Learn how to use the Telegram Login Flutter plugin API.
---

## Basic Flow

The typical usage pattern involves three steps:

1. Create a `TelegramLogin` instance
2. Configure it with your bot credentials
3. Initiate the login flow

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

:::caution[Concurrent Login Calls]
The plugin does not guard against a second concurrent `login()` call. Since the native SDK simply overwrites its pending completion, the first Dart `Future` would be orphaned — ensure only one login is in flight at a time (for example by disabling the login button while `_isLoading` is true).
:::

## TelegramLogin API

### configure()

Configures the plugin with your Telegram bot credentials. Must be called before `login()`.

```dart
Future<void> configure(TelegramLoginConfiguration configuration)
```

### login()

Initiates the Telegram Login OAuth flow. Returns a `TelegramLoginResult` with the ID token.

```dart
Future<TelegramLoginResult> login()
```

Throws `TelegramLoginError` on failure. See [Error Handling](/error-handling) for details.

### cancelLogin()

Cancels an in-flight login attempt. Returns `true` if a login was in flight and was cancelled, `false` otherwise.

```dart
Future<bool> cancelLogin()
```

**Cancellation is terminal:** if the user subsequently completes authentication in Telegram and the app is reopened with a valid callback URL, the late result is silently discarded by the native plugin and the cancelled Future stays cancelled.

### handleUrl()

Manually forwards a URL to the Telegram SDK. Only needed if your app intercepts URLs before the platform delivers them to the plugin (for example inside a custom deep-link router).

```dart
Future<void> handleUrl(Uri url)
```

## TelegramLoginResult

The result object returned on successful login:

| Field     | Type     | Description                                                                        |
| --------- | -------- | ---------------------------------------------------------------------------------- |
| `idToken` | `String` | The JWT ID token returned by Telegram. Send this to your backend for verification. |

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:telegram_login/telegram_login.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _telegramLogin = TelegramLogin();
  bool _isLoading = false;
  String? _error;
  String? _idToken;

  @override
  void initState() {
    super.initState();
    _configure();
  }

  Future<void> _configure() async {
    await _telegramLogin.configure(
      const TelegramLoginConfiguration(
        clientId: '12345',
        redirectUri: 'https://app12345-login.tg.dev',
        scopes: ['profile'],
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _idToken = null;
    });

    try {
      final result = await _telegramLogin.login();
      setState(() => _idToken = result.idToken);
      // Send token to backend for verification
    } on TelegramLoginError catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancel() async {
    await _telegramLogin.cancelLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Telegram Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_idToken != null)
              Text('Logged in! Token: ${_idToken!.substring(0, 20)}...'),
            if (_error != null)
              Text('Error: $_error', style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Login with Telegram'),
            ),
            if (_isLoading)
              TextButton(
                onPressed: _cancel,
                child: const Text('Cancel'),
              ),
          ],
        ),
      ),
    );
  }
}
```

## Security Note

The `idToken` returned on success is a JWT. You **must**:

1. Send it to your backend over HTTPS.
2. Validate the signature and claims server-side (see [Validating ID tokens](https://core.telegram.org/bots/telegram-login#validating-id-tokens)).
3. Only log the user in based on the validated claims.

Never treat a client-side-only JWT as authenticated.
