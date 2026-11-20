import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/config/network_config.dart';
import 'package:cars_wheels_app/core/network/network_signals.dart';
import 'package:cars_wheels_app/features/connectivity/domain/domain.dart';
import 'package:cars_wheels_app/features/connectivity/presentation/cubits/connectivity_state.dart';

/// Sabe si hay conexión: usa las fallas reales de las peticiones y, ya sin red,
/// una sonda ligera con retroceso para detectar el regreso.
class ConnectivityCubit extends Cubit<ConnectivityState> {
  ConnectivityCubit({
    required NetworkSignals signals,
    required this.probe,
    required this.judge,
    required this.backoff,
    required this.restoredNoticeDuration,
    this.verifyMinInterval = const Duration(
      seconds: ConnectivityConfig.verifyMinIntervalSeconds,
    ),
    this.clock = DateTime.now,
  }) : super(const ConnectivityState()) {
    _subscription = signals.stream.listen(_onSignal);
  }

  final ConnectionProbe probe;
  final ConnectionJudge judge;
  final ReconnectBackoff backoff;
  final Duration restoredNoticeDuration;

  /// Tiempo mínimo entre verificaciones; evita sondas en cada cambio de pantalla.
  final Duration verifyMinInterval;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;

  // Recursos cancelables y banderas de la sonda.
  StreamSubscription<NetworkSignal>? _subscription;
  Timer? _probeTimer;
  Timer? _restoredTimer;
  bool _foreground = true;
  bool _probing = false;
  int _attempt = 0;
  DateTime? _lastVerified;

  /// La app pasa a primer plano o a segundo; en segundo plano no hay sondas.
  void setForeground(bool foreground) {
    if (_foreground == foreground) return;
    _foreground = foreground;
    if (!foreground) {
      _probeTimer?.cancel();
      return;
    }
    // Al volver con la conexión en línea, una verificación ligera.
    if (!state.isOffline) {
      unawaited(verify());
      return;
    }
    // Al volver con la conexión caída se verifica de inmediato.
    if (state.isOffline) {
      _attempt = 0;
      _scheduleProbe(Duration.zero);
    }
  }

  /// Comprueba con una sonda ligera que la conexión sigue ahí.
  ///
  /// Una pantalla sin peticiones no se enteraría de que se cayó la red; esto la
  /// avisa. Se omite si ya está caída, si hay una en curso o si es muy pronto.
  Future<void> verify() async {
    if (isClosed || state.isOffline || _probing || !_foreground) return;
    final now = clock();
    final last = _lastVerified;
    if (last != null && now.difference(last) < verifyMinInterval) return;
    _lastVerified = now;
    _probing = true;
    bool reachable;
    try {
      reachable = await probe.isReachable();
    } on Object {
      reachable = false;
    }
    _probing = false;
    if (!isClosed && !reachable) _goOffline();
  }

  void _onSignal(NetworkSignal signal) {
    if (isClosed) return;
    if (judge.isLostAfter(signal)) {
      _goOffline();
    } else if (signal == NetworkSignal.reachable && state.isOffline) {
      _restore();
    }
  }

  void _goOffline() {
    _restoredTimer?.cancel();
    if (state.isOffline) return;
    emit(
      ConnectivityState(
        phase: ConnectionPhase.offline,
        restoreEpoch: state.restoreEpoch,
      ),
    );
    _attempt = 0;
    if (_foreground) _scheduleProbe(backoff.delayFor(_attempt));
  }

  void _scheduleProbe(Duration delay) {
    _probeTimer?.cancel();
    _probeTimer = Timer(delay, _runProbe);
  }

  Future<void> _runProbe() async {
    if (_probing || isClosed || !state.isOffline || !_foreground) return;
    _probing = true;
    bool reachable;
    try {
      reachable = await probe.isReachable();
    } on Object {
      reachable = false;
    }
    _probing = false;
    if (isClosed || !state.isOffline) return;
    if (reachable) {
      _restore();
    } else {
      _attempt++;
      if (_foreground) _scheduleProbe(backoff.delayFor(_attempt));
    }
  }

  void _restore() {
    _probeTimer?.cancel();
    judge.reset();
    emit(
      ConnectivityState(
        phase: ConnectionPhase.restored,
        restoreEpoch: state.restoreEpoch + 1,
      ),
    );
    _restoredTimer?.cancel();
    _restoredTimer = Timer(restoredNoticeDuration, () {
      if (isClosed || state.phase != ConnectionPhase.restored) return;
      emit(ConnectivityState(restoreEpoch: state.restoreEpoch));
    });
  }

  @override
  Future<void> close() async {
    _probeTimer?.cancel();
    _restoredTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
