---
title: Configuration
description: Configuration reference for the Telegram Login Flutter plugin.
---

## TelegramLoginConfiguration

The `TelegramLoginConfiguration` class defines all the parameters needed to configure the Telegram Login SDK.

### Fields

| Field            | Type           | Required | Description                                                                        |
| ---------------- | -------------- | -------- | ---------------------------------------------------------------------------------- |
| `clientId`       | `String`       | Yes      | The numeric bot client ID from BotFather.                                          |
| `redirectUri`    | `String`       | Yes      | Either `https://app{id}-login.tg.dev` (Universal/App Link) or `yourscheme://path`. |
| `scopes`         | `List<String>` | Yes      | OAuth scopes, e.g. `['profile']`.                                                  |
| `fallbackScheme` | `String?`      | No       | Custom URL scheme used on iOS < 17.4 when `redirectUri` is an `https://` URL.      |

### Example Configuration

#### Universal Links (iOS 17.4+ / Android)

```dart
const TelegramLoginConfiguration(
  clientId: '12345',
  redirectUri: 'https://app12345-login.tg.dev',
  scopes: ['profile'],
)
```

#### Custom URL Scheme with Fallback

```dart
const TelegramLoginConfiguration(
  clientId: '12345',
  redirectUri: 'https://app12345-login.tg.dev',
  scopes: ['profile'],
  fallbackScheme: 'myapp', // Used on iOS < 17.4
)
```

#### Pure Custom Scheme

```dart
const TelegramLoginConfiguration(
  clientId: '12345',
  redirectUri: 'myapp://auth',
  scopes: ['profile'],
  fallbackScheme: 'myapp',
)
```

## Available Scopes

You can request specific permissions when initiating authorization. The `openid` scope is required.

| Scope                 | Description                                                        | Claims Returned                         |
| --------------------- | ------------------------------------------------------------------ | --------------------------------------- |
| `openid`              | Required. Returns the user's unique identifier and auth timestamp. | `sub`, `iss`, `iat`, `exp`              |
| `profile`             | User's basic info: name, username, and profile photo URL.          | `name`, `preferred_username`, `picture` |
| `phone`               | User's verified phone number. Requires user consent.               | `phone_number`                          |
| `telegram:bot_access` | Allows your bot to send direct messages to the user after login.   | —                                       |

## Platform-Specific Considerations

### iOS

- **Universal Links** require iOS 17.4+ and proper Associated Domains configuration
- **Custom URL Schemes** work on all iOS versions but are less secure
- When using Universal Links, always provide a `fallbackScheme` for older iOS versions

### Android

- Uses App Links for secure URL handling
- Ensure your SHA-256 fingerprint is registered with BotFather
- The intent filter with `autoVerify="true"` enables automatic link verification
