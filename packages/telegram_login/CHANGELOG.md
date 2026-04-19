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

