---
title: Error Handling
description: Learn how to handle errors from the Telegram Login Flutter plugin.
---

## TelegramLoginError

The `login()` method throws `TelegramLoginError` on failure. The error carries:

| Property     | Type                     | Description                             |
| ------------ | ------------------------ | --------------------------------------- |
| `code`       | `TelegramLoginErrorCode` | The error code enum                     |
| `message`    | `String?`                | Optional error message with details     |
| `statusCode` | `int?`                   | For server errors, the HTTP status code |

## Error Codes

| Error Code            | When It Happens                                              | Recommended Action                                                        |
| --------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------- |
| `notConfigured`       | `configure()` was not called before `login()`.               | Call `configure()` with valid credentials before attempting login.        |
| `noAuthorizationCode` | Callback URL did not contain a `code` query parameter.       | Check that the redirect URI is correctly configured in BotFather.         |
| `serverError`         | Token endpoint returned a non-200 status (`statusCode`).     | Check `statusCode` for details. May be a temporary Telegram server issue. |
| `requestFailed`       | Generic SDK-level request failure.                           | See `message` for details. Check network connectivity.                    |
| `cancelled`           | User dismissed the auth sheet or `cancelLogin()` was called. | No UI error needed; user intentionally cancelled.                         |
| `networkError`        | Network failure while contacting Telegram.                   | Offer a retry. Check device connectivity.                                 |
| `platformError`       | Unexpected native or channel error.                          | See `message` for details. May require debugging.                         |

## Example Error Handling

```dart
try {
  final result = await telegramLogin.login();
  // Handle success
} on TelegramLoginError catch (e) {
  switch (e.code) {
    case TelegramLoginErrorCode.cancelled:
      // User cancelled — no UI error needed.
      break;
    case TelegramLoginErrorCode.networkError:
      // Offer a retry.
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Network Error'),
          content: const Text('Please check your connection and try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      break;
    case TelegramLoginErrorCode.notConfigured:
      // Call configure() first.
      debugPrint('Error: configure() was not called');
      break;
    case TelegramLoginErrorCode.serverError:
      debugPrint('Server error: ${e.statusCode}');
      break;
    default:
      // noAuthorizationCode, requestFailed, platformError
      debugPrint('Login error: ${e.code.name} — ${e.message}');
      break;
  }
}
```

## Common Error Scenarios

### Not Configured

Occurs when you call `login()` before `configure()`:

```dart
// ❌ Wrong
final result = await telegramLogin.login();

// ✅ Correct
await telegramLogin.configure(configuration);
final result = await telegramLogin.login();
```

### No Authorization Code

Usually indicates a mismatch between the `redirectUri` configured in your app and what's registered with BotFather:

1. Verify your Bundle ID (iOS) or package name (Android) in BotFather
2. Check that your redirect URI matches exactly
3. Ensure Associated Domains / intent filters are correctly configured

### Network Error

Transient connectivity issues. Best practice:

- Show a user-friendly message
- Offer a retry button
- Consider exponential backoff for automatic retries

### Server Error

Telegram's token endpoint returned an error. The `statusCode` may provide additional context:

- `400` - Bad request (check your configuration)
- `401` - Unauthorized (invalid client ID)
- `500` - Telegram server error (retry later)

## Logging and Debugging

During development, enable verbose logging to diagnose issues:

```dart
try {
  final result = await telegramLogin.login();
} on TelegramLoginError catch (e, stackTrace) {
  debugPrint('TelegramLoginError: ${e.code.name}');
  debugPrint('Message: ${e.message}');
  debugPrint('Status code: ${e.statusCode}');
  debugPrint('Stack trace: $stackTrace');
}
```
