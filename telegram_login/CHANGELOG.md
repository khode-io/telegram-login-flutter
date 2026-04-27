## 1.2.1

- Fix iOS compilation error for consumers on older Flutter SDK versions
  - Removed `FlutterSceneLifeCycleDelegate` conformance and `addSceneDelegate` call
  - These APIs are not available on Flutter versions below 3.16+
  - `addApplicationDelegate` alone is sufficient; Flutter's engine forwards scene delegate URL events to registered application delegates automatically

## 1.2.0

- iOS implementation is now self-contained and no longer depends on the external `telegram-login-ios` Swift package
  - Uses `ASWebAuthenticationSession`, `CryptoKit`, and standard iOS APIs directly
  - Supports Universal Links (iOS 17.4+) and Custom URL Schemes (fallback) via embedded OAuth logic
  - Same Dart API with no breaking changes for Flutter consumers

## 1.1.0

- **Breaking Change:** Android SDK dependency changed from GitHub Packages to Maven Central
  - Users no longer need to configure GitHub authentication
  - No more `gpr.user` or `gpr.key` required in `~/.gradle/gradle.properties`
  - No repository configuration needed in app's `android/settings.gradle`
- Enhanced dartdoc coverage for all public API elements
- Added `example` symlink for pub.dev compliance
- Fixed pubspec.yaml description for better pub.dev score

## 1.0.1

- Fixed documentation to reflect correct Android minimum SDK (API 23, Android 6.0+)
- Enhanced pubspec.yaml description for pub.dev compliance
- Updated Android SDK source link in documentation

## 1.0.0

- Initial stable release of telegram_login.
- **Features:**
  - Native OAuth flow powered by the official Telegram Login SDK
  - iOS support with Universal Links (iOS 17.4+) and Custom URL Schemes (fallback)
  - Android support with App Links
  - Automatic URL callback forwarding — no AppDelegate/Activity wiring required
  - User-driven cancellation with `cancelLogin()`
  - Comprehensive error handling with `TelegramLoginError`
- **API:**
  - `TelegramLogin.configure()` - Configure the SDK with client ID, redirect URI, and scopes
  - `TelegramLogin.login()` - Start the login flow, returns JWT ID token
  - `TelegramLogin.cancelLogin()` - Cancel an in-flight login
  - `TelegramLogin.handleUrl()` - Manual URL forwarding for custom deep link handlers
  - `TelegramLogin.isConfigured` - Check if SDK is configured
