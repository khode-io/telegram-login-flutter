import 'package:equatable/equatable.dart';

/// Configuration for Telegram Login.
class TelegramLoginConfiguration extends Equatable {
  final String clientId;
  final String redirectUri;
  final List<String> scopes;
  final String? fallbackScheme;

  const TelegramLoginConfiguration({
    required this.clientId,
    required this.redirectUri,
    required this.scopes,
    this.fallbackScheme,
  });

  factory TelegramLoginConfiguration.fromMap(Map<String, dynamic> map) =>
      TelegramLoginConfiguration(
        clientId: map['clientId'] as String,
        redirectUri: map['redirectUri'] as String,
        scopes: List<String>.from(map['scopes'] as List),
        fallbackScheme: map['fallbackScheme'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'clientId': clientId,
    'redirectUri': redirectUri,
    'scopes': scopes,
    if (fallbackScheme != null) 'fallbackScheme': fallbackScheme,
  };

  @override
  List<Object?> get props => [clientId, redirectUri, scopes, fallbackScheme];

  @override
  String toString() =>
      'TelegramLoginConfiguration(clientId: $clientId, redirectUri: $redirectUri, scopes: $scopes, fallbackScheme: $fallbackScheme)';
}
