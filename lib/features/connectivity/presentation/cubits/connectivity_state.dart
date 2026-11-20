import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/connectivity/domain/domain.dart';

/// Estado de la conexión a nivel de app.
class ConnectivityState extends Equatable {
  const ConnectivityState({
    this.phase = ConnectionPhase.online,
    this.restoreEpoch = 0,
  });

  final ConnectionPhase phase;

  /// Sube en uno cada vez que vuelve la conexión; sirve para recargar una sola vez.
  final int restoreEpoch;

  bool get isOffline => phase == ConnectionPhase.offline;

  @override
  List<Object?> get props => [phase, restoreEpoch];
}
