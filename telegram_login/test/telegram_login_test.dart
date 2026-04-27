import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:telegram_login/telegram_login.dart';
import 'package:telegram_login/telegram_login_method_channel.dart';
import 'package:telegram_login/telegram_login_platform_interface.dart';

class MockTelegramLoginPlatform
    with MockPlatformInterfaceMixin
    implements TelegramLoginPlatform {
  bool _isConfigured = false;
  TelegramLoginResult? _loginResult;
  TelegramLoginError? _loginError;
  final bool _handleUrlResult = true;

  void setLoginResult(TelegramLoginResult result) {
    _loginResult = result;
    _loginError = null;
  }

  void setLoginError(TelegramLoginError error) {
    _loginError = error;
    _loginResult = null;
  }

  @override
  bool get isConfigured => _isConfigured;

  @override
  Future<void> configure(TelegramLoginConfiguration config) async {
    _isConfigured = true;
  }

  @override
  Future<TelegramLoginResult> login() async {
    if (_loginError != null) {
      throw _loginError!;
    }
    if (_loginResult != null) {
      return _loginResult!;
    }
    throw TelegramLoginError.notConfigured();
  }

  @override
  Future<bool> handleUrl(Uri url) async {
    return _handleUrlResult;
  }

  @override
  Future<bool> cancelLogin() async => false;
}

void main() {
  final TelegramLoginPlatform initialPlatform = TelegramLoginPlatform.instance;

  test('$MethodChannelTelegramLogin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTelegramLogin>());
  });

  group('TelegramLogin', () {
    late MockTelegramLoginPlatform fakePlatform;
    late TelegramLogin plugin;

    setUp(() {
      fakePlatform = MockTelegramLoginPlatform();
      TelegramLoginPlatform.instance = fakePlatform;
      plugin = TelegramLogin();
    });

    test('configure sets isConfigured to true', () async {
      expect(fakePlatform.isConfigured, isFalse);

      await plugin.configure(
        const TelegramLoginConfiguration(
          clientId: 'test_client_id',
          redirectUri: 'https://test.com/callback',
          scopes: ['profile'],
        ),
      );

      expect(fakePlatform.isConfigured, isTrue);
    });

    test('isConfigured reflects platform state', () async {
      expect(plugin.isConfigured, isFalse);

      await plugin.configure(
        const TelegramLoginConfiguration(
          clientId: 'test_client_id',
          redirectUri: 'https://test.com/callback',
          scopes: ['profile'],
        ),
      );

      expect(plugin.isConfigured, isTrue);
    });

    test('login returns result on success', () async {
      fakePlatform.setLoginResult(
        const TelegramLoginResult(idToken: 'test_id_token'),
      );

      final result = await plugin.login();

      expect(result.idToken, 'test_id_token');
    });

    test('login throws TelegramLoginError on failure', () async {
      fakePlatform.setLoginError(TelegramLoginError.cancelled());

      expect(() => plugin.login(), throwsA(isA<TelegramLoginError>()));
    });

    test('handleUrl returns true on success', () async {
      final success = await plugin.handleUrl(
        Uri.parse('telegram-login-example://callback'),
      );

      expect(success, isTrue);
    });
  });

  group('TelegramLoginResult', () {
    test('fromMap creates instance correctly', () {
      final result = TelegramLoginResult.fromMap({'idToken': 'token123'});

      expect(result.idToken, 'token123');
    });

    test('toMap serializes correctly', () {
      const result = TelegramLoginResult(idToken: 'token123');

      final map = result.toMap();

      expect(map['idToken'], 'token123');
    });
  });

  group('TelegramLoginConfiguration', () {
    test('fromMap creates instance correctly', () {
      final config = TelegramLoginConfiguration.fromMap({
        'clientId': 'client123',
        'redirectUri': 'https://example.com/callback',
        'scopes': ['profile', 'phone'],
      });

      expect(config.clientId, 'client123');
      expect(config.redirectUri, 'https://example.com/callback');
      expect(config.scopes, ['profile', 'phone']);
    });

    test('toMap serializes correctly', () {
      const config = TelegramLoginConfiguration(
        clientId: 'client123',
        redirectUri: 'https://example.com/callback',
        scopes: ['profile', 'phone'],
      );

      final map = config.toMap();

      expect(map['clientId'], 'client123');
      expect(map['redirectUri'], 'https://example.com/callback');
      expect(map['scopes'], ['profile', 'phone']);
    });
  });

  group('TelegramLoginError', () {
    test('notConfigured error has correct code', () {
      final error = TelegramLoginError.notConfigured();

      expect(error.code, TelegramLoginErrorCode.notConfigured);
      expect(error.message, contains('configure()'));
    });

    test('cancelled error has correct code', () {
      final error = TelegramLoginError.cancelled();

      expect(error.code, TelegramLoginErrorCode.cancelled);
      expect(error.message, contains('cancelled'));
    });

    test('serverError can include status code', () {
      final error = TelegramLoginError.serverError(500);

      expect(error.code, TelegramLoginErrorCode.serverError);
      expect(error.statusCode, 500);
    });

    test('equality works correctly', () {
      const error1 = TelegramLoginError(
        code: TelegramLoginErrorCode.cancelled,
        message: 'Test message',
      );
      const error2 = TelegramLoginError(
        code: TelegramLoginErrorCode.cancelled,
        message: 'Test message',
      );

      expect(error1, equals(error2));
    });
  });
}
