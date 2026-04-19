## 0.0.1

- Initial release of telegram_login_flutter.
- **Features:**
  - Native OAuth flow powered by the official Telegram Login SDK
  - iOS support with Universal Links (iOS 17.4+) and Custom URL Schemes (fallback)
  - Android support with App Links
  - Automatic URL callback forwarding — no AppDelegate/Activity wiring required
  - User-driven cancellation with `cancelLogin()`
  - Comprehensive error handling with `TelegramLoginError`
- **API:**
  - `TelegramLoginFlutter.configure()` - Configure the SDK with client ID, redirect URI, and scopes
  - `TelegramLoginFlutter.login()` - Start the login flow, returns JWT ID token
  - `TelegramLoginFlutter.cancelLogin()` - Cancel an in-flight login
  - `TelegramLoginFlutter.handleUrl()` - Manual URL forwarding for custom deep link handlers
  - `TelegramLoginFlutter.isConfigured` - Check if SDK is configured
