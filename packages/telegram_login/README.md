A Flutter plugin that wraps the official Telegram Login SDK and exposes a Dart
API for signing users in with their Telegram account.

| Platform | SDK Source                                                                                              |
| -------- | ------------------------------------------------------------------------------------------------------- |
| iOS      | [TelegramMessenger/telegram-login-ios](https://github.com/TelegramMessenger/telegram-login-ios)         |
| Android  | [TelegramMessenger/telegram-login-android](https://github.com/TelegramMessenger/telegram-login-android) |

## Features

- Native OAuth flow powered by the official Telegram SDKs
- iOS: Universal Links (iOS 17.4+) and Custom URL Schemes (fallback)
- Android: App Links support
- Automatic URL callback forwarding — plugin handles native URL callbacks; just configure your manifest/plist
- `cancelLogin()` for user-driven cancellation; late native callbacks are discarded

## Prerequisites

- **iOS:** 15.0 or newer, Xcode 15 or newer
- **Android:** API 23+ (Android 6.0+)
- Flutter `>=3.3.0`, Dart SDK `^3.6.0`
- A registered Telegram bot via [@BotFather](https://t.me/botfather)

## Installation

Add the package to your app's `pubspec.yaml`:

```yaml
dependencies:
  telegram_login: ^1.0.1
```

Then run `flutter pub get`.

- **iOS:** On first build, CocoaPods / SwiftPM will resolve the underlying
  `telegram-login-ios` SDK automatically.
- **Android:** The Gradle build will pull the Telegram Login SDK.

## Setup

### 1. Register your bot with BotFather

1. Open [@BotFather](https://t.me/botfather)
2. Send `/newbot` (or pick an existing bot)
3. Go to **Bot Settings → Login Widget**
4. Register your app:
   - **iOS:** Provide Bundle ID and Apple Team ID
   - **Android:** Provide package name and SHA-256 fingerprint

BotFather will give you a bot client ID (a numeric string) and provision a
secure domain of the form `app{CLIENT_ID}-login.tg.dev` for universal/app links.

### 2. Configure your app

#### iOS Setup

Pick **one** of the two URL delivery mechanisms.

##### Option A — Universal Links (recommended, iOS 17.4+)

1. In Xcode, select your app target → **Signing & Capabilities**
2. Click **+ Capability** → **Associated Domains**
3. Add **both** entries for your login domain:
   - `applinks:app{YOUR_CLIENT_ID}-login.tg.dev`
   - `webcredentials:app{YOUR_CLIENT_ID}-login.tg.dev`
4. For development builds, you may append `?mode=developer` to each entry.

> **Why `webcredentials:` is required.** iOS 17.4+ refuses HTTPS callbacks in
> `ASWebAuthenticationSession` unless the app is associated with the callback
> host via the `webcredentials` service type. Without it, the session fails
> instantly with _"Using HTTPS callbacks requires Associated Domains using the
> `webcredentials` service type for `<host>`"_ and the user sees a cancelled
> login.

Use the `https://` URL as your `redirectUri`:

```dart
redirectUri: 'https://app12345-login.tg.dev'
```

##### Option B — Custom URL Scheme (fallback, also required on iOS < 17.4)

1. Open your app's `Info.plist`
2. Add a URL Type:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

Then use your scheme as the `redirectUri`, and pass the same scheme as
`fallbackScheme`:

```dart
TelegramLoginConfiguration(
  clientId: '12345',
  redirectUri: 'myapp://auth',
  scopes: ['profile'],
  fallbackScheme: 'myapp',
)
```

#### Android Setup

1. Register your SHA-256 fingerprint with BotFather:

   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

   Copy the SHA256 value and provide it to BotFather.

2. Add an intent filter to your `AndroidManifest.xml` inside your main activity:

```xml
<activity android:name=".MainActivity">
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="https"
              android:host="app{YOUR_CLIENT_ID}-login.tg.dev" />
    </intent-filter>
</activity>
```

Use the same `https://app{CLIENT_ID}-login.tg.dev` URL as your `redirectUri`.

### 3. URL callback forwarding — nothing to do

The plugin automatically registers itself as a delegate, so Telegram callbacks
are forwarded to the native SDK without any code in your `AppDelegate` or
`MainActivity`. If your app intercepts URLs somewhere else (for example from a
router package), use [`handleUrl`](#manual-url-forwarding) to hand them off.

## Usage

### Basic flow

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

> The plugin does not guard against a second concurrent `login()` call.
> Since the native SDK simply overwrites its pending completion, the first
> Dart `Future` would be orphaned — ensure only one login is in flight at
> a time (for example by disabling the login button while `_isLoading` is
> true).

### Cancel an in-flight login

Reject the pending `login()` Future from Dart, for example when the user
taps a "Back" button while Telegram is open:

```dart
final cancelled = await telegramLogin.cancelLogin();
```

Returns `true` if a login was in flight and was cancelled, `false`
otherwise. **Cancellation is terminal:** if the user subsequently
completes authentication in Telegram and the app is reopened with a valid
callback URL, the late result is silently discarded by the native plugin
and the cancelled Future stays cancelled.

### Manual URL forwarding

Only needed if your app intercepts URLs before the platform delivers them to
the plugin (for example inside a custom deep-link router). Pass the URL to
the plugin and it will forward it to the native SDK:

```dart
await telegramLogin.handleUrl(Uri.parse(urlString));
```

## Configuration reference

| Field            | Type           | Description                                                                        |
| ---------------- | -------------- | ---------------------------------------------------------------------------------- |
| `clientId`       | `String`       | The numeric bot client ID from BotFather.                                          |
| `redirectUri`    | `String`       | Either `https://app{id}-login.tg.dev` (Universal/App Link) or `yourscheme://path`. |
| `scopes`         | `List<String>` | OAuth scopes, e.g. `['profile']`.                                                  |
| `fallbackScheme` | `String?`      | Custom URL scheme used on iOS < 17.4 when `redirectUri` is an `https://` URL.      |

## Error handling

`login()` throws `TelegramLoginError` on failure. The error carries a
`code` (enum `TelegramLoginErrorCode`), an optional `message`, and, for
server errors, a `statusCode`.

| Error code            | When it happens                                              |
| --------------------- | ------------------------------------------------------------ |
| `notConfigured`       | `configure()` was not called before `login()`.               |
| `noAuthorizationCode` | Callback URL did not contain a `code` query parameter.       |
| `serverError`         | Token endpoint returned a non-200 status (`statusCode`).     |
| `requestFailed`       | Generic SDK-level request failure (see `message`).           |
| `cancelled`           | User dismissed the auth sheet or `cancelLogin()` was called. |
| `networkError`        | Network failure while contacting Telegram.                   |
| `platformError`       | Unexpected native or channel error (see `message`).          |

```dart
try {
  final result = await telegramLogin.login();
} on TelegramLoginError catch (e) {
  switch (e.code) {
    case TelegramLoginErrorCode.cancelled:
      // User cancelled — no UI error needed.
      break;
    case TelegramLoginErrorCode.networkError:
      // Offer a retry.
      break;
    case TelegramLoginErrorCode.notConfigured:
      // Call configure() first.
      break;
    case TelegramLoginErrorCode.serverError:
      print('Server error: ${e.statusCode}');
      break;
    default:
      // noAuthorizationCode, requestFailed, platformError
      break;
  }
}
```

## Security note

The `idToken` returned on success is a JWT. You **must**:

1. Send it to your backend over HTTPS.
2. Validate the signature and claims server-side (see
   [Validating ID tokens](https://core.telegram.org/bots/telegram-login#validating-id-tokens)).
3. Only log the user in based on the validated claims.

Never treat a client-side-only JWT as authenticated.

## Example

A runnable example lives under [`example/`](example/). It shows
configuration, login, cancellation, and error rendering for both iOS and Android.

## License

MIT
