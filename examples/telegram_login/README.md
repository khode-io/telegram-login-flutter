# telegram_login Example

This example demonstrates how to use the `telegram_login` plugin to
authenticate users with their Telegram accounts.

## Prerequisites

1. A Telegram bot registered with [@BotFather](https://t.me/botfather)
2. For iOS: Apple Developer Team ID
3. For Android: SHA-256 fingerprint of your signing key

## Setup

### 1. Configure your bot with BotFather

1. Open [@BotFather](https://t.me/botfather)
2. Send `/newbot` (or use an existing bot)
3. Go to **Bot Settings → Login Widget**
4. Register your app:
   - **iOS:** Add Bundle ID `io.khode.telegramLoginFlutterExample` and your Team ID
   - **Android:** Add package `io.khode.telegram_login_flutter_example` and your SHA-256 fingerprint

### 2. Update the example code

Open `lib/home_page.dart` and replace the placeholder configuration:

```dart
// Replace with your actual BotFather client ID
const _clientId = 'YOUR_BOT_CLIENT_ID';

// Replace with your actual redirect URI from BotFather
const _redirectUri = 'https://app{CLIENT_ID}-login.tg.dev';
```

### 3. Platform-specific setup

#### iOS

Open `ios/Runner.xcworkspace` in Xcode:

1. Select the Runner target → **Signing & Capabilities**
2. Add **Associated Domains** capability
3. Add entry: `applinks:app{YOUR_CLIENT_ID}-login.tg.dev`
4. For development, add `?mode=developer` to the domain

#### Android

Get your SHA-256 fingerprint:

```bash
# For debug builds
cd android
./gradlew signingReport
```

Or manually:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copy the SHA256 value to BotFather. The example's `AndroidManifest.xml` already
includes the intent filter for the redirect URI.

## Running the Example

```bash
# Get dependencies
flutter pub get

# Run on iOS simulator or device
flutter run -d ios

# Run on Android emulator or device
flutter run -d android
```

## What the Example Demonstrates

- **Configuration:** Shows how to configure the SDK with client ID, redirect URI, and scopes
- **Login Flow:** Initiates Telegram authentication with loading state
- **Cancellation:** Demonstrates `cancelLogin()` to abort in-flight authentication
- **Error Handling:** Displays user-friendly error messages for all error codes
- **Token Display:** Shows the received JWT ID token (with security warning)

## Project Structure

```
lib/
├── main.dart          # App entry point, theme setup
└── home_page.dart     # Complete demo UI with all features
```

## Next Steps

After successful login:

1. Send the `idToken` to your backend over HTTPS
2. Validate the JWT server-side using Telegram's public keys
3. Issue your own session/authentication for the user

See [Validating ID tokens](https://core.telegram.org/bots/telegram-login#validating-id-tokens)
for server-side verification details.
