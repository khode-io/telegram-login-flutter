import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'models/model.dart';
import 'telegram_login_method_channel.dart';

abstract class TelegramLoginPlatform extends PlatformInterface {
  TelegramLoginPlatform() : super(token: _token);

  static final Object _token = Object();

  static TelegramLoginPlatform _instance = MethodChannelTelegramLogin();

  /// Default platform instance.
  static TelegramLoginPlatform get instance => _instance;

  /// Set by platform-specific implementations.
  static set instance(TelegramLoginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Configure the SDK.
  Future<void> configure(TelegramLoginConfiguration config) {
    throw UnimplementedError('configure() has not been implemented.');
  }

  /// Whether the SDK is configured.
  bool get isConfigured {
    throw UnimplementedError('isConfigured has not been implemented.');
  }

  /// Start the login flow.
  Future<TelegramLoginResult> login() {
    throw UnimplementedError('login() has not been implemented.');
  }

  /// Handle a callback URL.
  Future<bool> handleUrl(Uri url) {
    throw UnimplementedError('handleUrl() has not been implemented.');
  }

  /// Cancel the in-flight login. Cancel is terminal; late native results
  /// are discarded.
  Future<bool> cancelLogin() {
    throw UnimplementedError('cancelLogin() has not been implemented.');
  }
}
