import 'package:cars_wheels_app/core/network/network_signals.dart';

/// Decide cuándo las fallas de red cuentan como "sin conexión".
class ConnectionJudge {
  ConnectionJudge({required this.slowFailuresToGoOffline});

  /// Fallas seguidas por tiempo de espera para dar por caída la conexión.
  final int slowFailuresToGoOffline;

  int _slowInARow = 0;

  /// Registra la señal; verdadero si con ella la conexión se da por perdida.
  bool isLostAfter(NetworkSignal signal) {
    switch (signal) {
      case NetworkSignal.reachable:
        _slowInARow = 0;
        return false;
      case NetworkSignal.unreachable:
        return true;
      case NetworkSignal.slow:
        _slowInARow++;
        return _slowInARow >= slowFailuresToGoOffline;
    }
  }

  /// Olvida las fallas contadas (al recuperar la conexión).
  void reset() => _slowInARow = 0;
}
