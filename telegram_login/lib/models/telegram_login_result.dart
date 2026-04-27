import 'package:equatable/equatable.dart';

/// Result of a successful Telegram login.
class TelegramLoginResult extends Equatable {
  final String idToken;

  const TelegramLoginResult({required this.idToken});

  factory TelegramLoginResult.fromMap(Map<String, dynamic> map) =>
      TelegramLoginResult(idToken: map['idToken'] as String);

  Map<String, dynamic> toMap() => {'idToken': idToken};

  @override
  List<Object?> get props => [idToken];

  @override
  String toString() => 'TelegramLoginResult(idToken: $idToken)';
}
