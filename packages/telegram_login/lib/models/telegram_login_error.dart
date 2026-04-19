import 'package:equatable/equatable.dart';

/// Error codes for Telegram Login failures.
enum TelegramLoginErrorCode {
  notConfigured,
  noAuthorizationCode,
  serverError,
  requestFailed,
  cancelled,
  networkError,
  platformError,
}

/// Error thrown when Telegram Login fails.
class TelegramLoginError extends Equatable {
  final TelegramLoginErrorCode code;
  final String? message;
  final int? statusCode;

  const TelegramLoginError({required this.code, this.message, this.statusCode});

  factory TelegramLoginError.notConfigured() => const TelegramLoginError(
    code: TelegramLoginErrorCode.notConfigured,
    message: 'TelegramLogin.configure() was not called before login()',
  );

  factory TelegramLoginError.noAuthorizationCode() => const TelegramLoginError(
    code: TelegramLoginErrorCode.noAuthorizationCode,
    message: 'The callback URL did not contain an authorization code',
  );

  factory TelegramLoginError.serverError([int? statusCode]) =>
      TelegramLoginError(
        code: TelegramLoginErrorCode.serverError,
        message: 'The server returned a non-200 HTTP status code',
        statusCode: statusCode,
      );

  factory TelegramLoginError.requestFailed([String? reason]) =>
      TelegramLoginError(
        code: TelegramLoginErrorCode.requestFailed,
        message: reason ?? 'A general request failure',
      );

  factory TelegramLoginError.cancelled() => const TelegramLoginError(
    code: TelegramLoginErrorCode.cancelled,
    message: 'The user cancelled the login',
  );

  factory TelegramLoginError.networkError([String? message]) =>
      TelegramLoginError(
        code: TelegramLoginErrorCode.networkError,
        message: message ?? 'Network connection lost while contacting Telegram',
      );

  factory TelegramLoginError.platformError(String message) =>
      TelegramLoginError(
        code: TelegramLoginErrorCode.platformError,
        message: message,
      );

  @override
  List<Object?> get props => [code, message, statusCode];

  @override
  String toString() => 'TelegramLoginError($code: $message)';
}
