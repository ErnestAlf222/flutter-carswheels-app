import 'package:equatable/equatable.dart';

/// Registro de los logos cuya precarga ya se pidió en esta sesión.
class LogoPrecacheState extends Equatable {
  const LogoPrecacheState({this.requestedUrls = const {}});

  final Set<String> requestedUrls;

  @override
  List<Object?> get props => [requestedUrls];
}
