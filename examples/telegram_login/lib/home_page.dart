import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:telegram_login/telegram_login.dart';

/// Platform-specific Telegram Login configuration registered with BotFather.
///
/// iOS and Android each have their own `clientId` / redirect domain because
/// BotFather issues them separately per platform fingerprint.
TelegramLoginConfiguration _buildConfig() {
  const scopes = ['profile', 'phone', 'telegram:bot_access'];

  if (!kIsWeb && Platform.isAndroid) {
    // Android App Link. The `app{clientId}-login.tg.dev` domain is
    // auto-provisioned by Telegram when the Android app is registered with
    // BotFather, and the /.well-known/assetlinks.json pinning the SHA-256
    // fingerprint is served automatically.
    return const TelegramLoginConfiguration(
      clientId: '8797183478',
      redirectUri: 'https://app2036562104-login.tg.dev/tglogin',
      scopes: scopes,
    );
  }
  // iOS Universal Link. The matching `/.well-known/apple-app-site-association`
  // file serves `TEAMID.bundleId` for this domain with `"paths": ["*"]`, so no
  // explicit path is needed — the host alone is enough for the Telegram SDK
  // and for Apple to route the callback to the app. The Runner target has
  // `applinks:app2142222789-login.tg.dev?mode=developer` in its entitlements.
  return const TelegramLoginConfiguration(
    clientId: '8797183478',
    redirectUri: 'https://app2142222789-login.tg.dev',
    scopes: scopes,
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _telegramLogin = TelegramLogin();

  bool _isConfigured = false;
  TelegramLoginResult? _loginResult;
  TelegramLoginError? _loginError;
  bool _isLoading = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _isConfigured = _telegramLogin.isConfigured;
  }

  Future<void> _configure() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Configuring...';
    });

    try {
      await _telegramLogin.configure(_buildConfig());

      setState(() {
        _isConfigured = true;
        _statusMessage = 'Configuration successful!';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Configuration failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _login() async {
    if (!_isConfigured) {
      setState(() {
        _statusMessage = 'Please configure first!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loginResult = null;
      _loginError = null;
      _statusMessage = 'Opening Telegram...';
    });

    try {
      final result = await _telegramLogin.login();
      setState(() {
        _loginResult = result;
        _statusMessage = 'Login successful!';
      });
      _showSnackBar('Login successful', Colors.green);
    } on TelegramLoginError catch (e) {
      setState(() {
        _loginError = e;
        _statusMessage = _friendlyMessage(e);
      });
      _showSnackBar(
        _friendlyMessage(e),
        e.code == TelegramLoginErrorCode.cancelled ? Colors.orange : Colors.red,
      );
    } catch (e) {
      setState(() {
        _statusMessage = 'Unexpected error: $e';
      });
      _showSnackBar('Unexpected error: $e', Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancelLogin() async {
    final cancelled = await _telegramLogin.cancelLogin();
    if (!cancelled) {
      _showSnackBar('No login in progress to cancel', Colors.grey);
    }
  }

  String _friendlyMessage(TelegramLoginError error) {
    switch (error.code) {
      case TelegramLoginErrorCode.cancelled:
        return 'Login cancelled';
      case TelegramLoginErrorCode.notConfigured:
        return 'SDK not configured. Call configure() first.';
      case TelegramLoginErrorCode.noAuthorizationCode:
        return 'No authorization code was returned by Telegram';
      case TelegramLoginErrorCode.serverError:
        return 'Telegram server error'
            '${error.statusCode != null ? ' (${error.statusCode})' : ''}';
      case TelegramLoginErrorCode.requestFailed:
        return 'Request failed: ${error.message ?? 'unknown reason'}';
      case TelegramLoginErrorCode.networkError:
        return 'Network connection lost. Please check your internet and tap Login again.';
      case TelegramLoginErrorCode.platformError:
        return error.message ?? 'Platform error';
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Telegram Login Demo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ConfigStatusCard(isConfigured: _isConfigured),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _configure,
                icon: const Icon(Icons.settings),
                label: const Text('Configure SDK'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading || !_isConfigured ? null : _login,
                icon: const Icon(Icons.login),
                label: const Text('Login with Telegram'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
              if (_isLoading) ...[
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _cancelLogin,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Login'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              if (_statusMessage != null)
                _StatusBanner(message: _statusMessage!),
              if (_loginResult != null) ...[
                const SizedBox(height: 16),
                _LoginSuccessCard(result: _loginResult!),
              ],
              if (_loginError != null) ...[
                const SizedBox(height: 16),
                _LoginErrorCard(
                  error: _loginError!,
                  friendlyMessage: _friendlyMessage(_loginError!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfigStatusCard extends StatelessWidget {
  final bool isConfigured;

  const _ConfigStatusCard({required this.isConfigured});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isConfigured ? Icons.check_circle : Icons.warning,
                  color: isConfigured ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  isConfigured ? 'Configured' : 'Not Configured',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isConfigured
                  ? 'SDK is ready to use'
                  : 'SDK needs configuration before login',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;

  const _StatusBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class _LoginSuccessCard extends StatelessWidget {
  final TelegramLoginResult result;

  const _LoginSuccessCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Login Successful',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'ID Token:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: SelectableText(
                result.idToken,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'IMPORTANT: Send this token to your backend server to verify and '
              'authenticate the user.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginErrorCard extends StatelessWidget {
  final TelegramLoginError error;
  final String friendlyMessage;

  const _LoginErrorCard({required this.error, required this.friendlyMessage});

  @override
  Widget build(BuildContext context) {
    final isCancelled = error.code == TelegramLoginErrorCode.cancelled;
    final accent = isCancelled ? Colors.orange : Colors.red;
    final background = isCancelled ? Colors.orange[50] : Colors.red[50];

    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCancelled ? Icons.info_outline : Icons.error,
                  color: accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    friendlyMessage,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isCancelled ? Colors.orange[800] : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Code: ${error.code.name}',
              style: TextStyle(
                color: Colors.grey[700],
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
