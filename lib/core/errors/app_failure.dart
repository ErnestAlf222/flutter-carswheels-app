import 'package:equatable/equatable.dart';

/// Falla de la app; el mensaje es técnico, no para el usuario.
sealed class AppFailure extends Equatable implements Exception {
  const AppFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Sin conexión o tiempo de espera agotado.
class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

/// El servidor respondió con un error HTTP.
class ServerFailure extends AppFailure {
  const ServerFailure(super.message);
}

/// El servidor pidió esperar antes de reintentar (HTTP 429).
class RateLimitFailure extends AppFailure {
  const RateLimitFailure(super.message, {required this.retryAfterSeconds});

  final int retryAfterSeconds;

  @override
  List<Object?> get props => [message, retryAfterSeconds];
}

/// La respuesta no tiene la forma esperada.
class ParsingFailure extends AppFailure {
  const ParsingFailure(super.message);
}

/// Cualquier otra falla.
class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message);
}
