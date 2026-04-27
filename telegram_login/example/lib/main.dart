import 'package:flutter/material.dart';
import 'package:telegram_login/telegram_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _telegramLogin = TelegramLogin();
  bool _isConfigured = false;
  bool _isLoading = false;
  String? _idToken;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _configure();
  }

  Future<void> _configure() async {
    await _telegramLogin.configure(
      const TelegramLoginConfiguration(
        clientId: '8688840891',
        redirectUri: 'https://app1953914688-login.tg.dev',
        scopes: ['profile'],
      ),
    );
    setState(() {
      _isConfigured = _telegramLogin.isConfigured;
    });
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _idToken = null;
      _errorMessage = null;
    });

    try {
      final result = await _telegramLogin.login();
      setState(() {
        _idToken = result.idToken;
      });
    } on TelegramLoginError catch (e) {
      setState(() {
        _errorMessage = '${e.code.name}: ${e.message}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _cancel() async {
    final cancelled = await _telegramLogin.cancelLogin();
    if (cancelled) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Login cancelled by user';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Telegram Login Example')),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Configured: $_isConfigured',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _isConfigured ? _login : null,
                    child: const Text('Login with Telegram'),
                  ),
                const SizedBox(height: 12),
                if (_isLoading)
                  TextButton(onPressed: _cancel, child: const Text('Cancel')),
                const SizedBox(height: 24),
                if (_idToken != null)
                  Text(
                    'ID Token:\n$_idToken',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.green),
                  ),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
