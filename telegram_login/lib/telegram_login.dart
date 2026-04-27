import 'models/model.dart';
import 'telegram_login_platform_interface.dart';

export 'models/model.dart';

/// Main entry point for Telegram Login.
class TelegramLogin {
  TelegramLoginPlatform get _platform => TelegramLoginPlatform.instance;

  /// Configure the SDK. Must be called before [login].
  Future<void> configure(TelegramLoginConfiguration config) {
    return _platform.configure(config);
  }

  /// Whether the SDK has been configured.
  bool get isConfigured => _platform.isConfigured;

  /// Start the login flow. Returns [TelegramLoginResult] or throws [TelegramLoginError].
  Future<TelegramLoginResult> login() {
    return _platform.login();
  }

  /// Handle a callback URL from Telegram. Called by the app's URL handler.
  Future<bool> handleUrl(Uri url) {
    return _platform.handleUrl(url);
  }

  /// Cancel the in-flight login. Returns true if a login was cancelled.
  ///
  /// Cancel is terminal: if the user later completes authentication in
  /// Telegram and the app is reopened with a valid callback URL, the late
  /// result is discarded by the native plugin.
  Future<bool> cancelLogin() {
    return _platform.cancelLogin();
  }
}
