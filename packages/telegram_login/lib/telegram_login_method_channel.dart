import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'models/model.dart';
import 'telegram_login_platform_interface.dart';

/// Method channel implementation of [TelegramLoginPlatform].
class MethodChannelTelegramLogin extends TelegramLoginPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('telegram_login');

  bool _isConfigured = false;

  @override
  bool get isConfigured => _isConfigured;

  @override
  Future<void> configure(TelegramLoginConfiguration config) async {
    try {
      await methodChannel.invokeMethod<void>('configure', config.toMap());
      _isConfigured = true;
    } on PlatformException catch (e) {
      throw TelegramLoginError.platformError(
        e.message ?? 'Configuration failed',
      );
    }
  }

  @override
  Future<TelegramLoginResult> login() async {
    if (!_isConfigured) {
      throw TelegramLoginError.notConfigured();
    }

    try {
      final result = await methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'login',
      );

      if (result == null) {
        throw TelegramLoginError.noAuthorizationCode();
      }

      return TelegramLoginResult.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw _mapPlatformException(e);
    }
  }

  @override
  Future<bool> cancelLogin() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('cancelLogin');
      return result ?? false;
    } on PlatformException catch (e) {
      throw TelegramLoginError.platformError(e.message ?? 'Cancel failed');
    }
  }

  @override
  Future<bool> handleUrl(Uri url) async {
    try {
      final result = await methodChannel.invokeMethod<bool>('handleUrl', {
        'url': url.toString(),
      });
      return result ?? false;
    } on PlatformException catch (e) {
      throw TelegramLoginError.platformError(
        e.message ?? 'URL handling failed',
      );
    }
  }

  TelegramLoginError _mapPlatformException(PlatformException e) {
    switch (e.code) {
      case 'NOT_CONFIGURED':
        return TelegramLoginError.notConfigured();
      case 'NO_AUTH_CODE':
        return TelegramLoginError.noAuthorizationCode();
      case 'SERVER_ERROR':
        final statusCode = int.tryParse(
          e.message?.split(':').last.trim() ?? '',
        );
        return TelegramLoginError.serverError(statusCode);
      case 'REQUEST_FAILED':
        return TelegramLoginError.requestFailed(e.message);
      case 'CANCELLED':
        return TelegramLoginError.cancelled();
      case 'NETWORK_ERROR':
        return TelegramLoginError.networkError(e.message);
      default:
        return TelegramLoginError.platformError(e.message ?? 'Unknown error');
    }
  }
}
