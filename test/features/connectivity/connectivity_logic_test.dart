import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeProbe implements ConnectionProbe {
  /// Respuestas en orden; la última se repite.
  List<bool> answers = [false];
  int calls = 0;

  @override
  Future<bool> isReachable() async {
    final index = calls < answers.length ? calls : answers.length - 1;
    calls++;
    return answers[index];
  }
}

ConnectivityCubit _cubit(NetworkSignals signals, ConnectionProbe probe) =>
    ConnectivityCubit(
      signals: signals,
      probe: probe,
      judge: ConnectionJudge(slowFailuresToGoOffline: 2),
      backoff: const ReconnectBackoff(
        initialDelay: Duration(seconds: 5),
        maxDelay: Duration(seconds: 20),
        factor: 2,
      ),
      restoredNoticeDuration: const Duration(seconds: 3),
    );

void main() {
  group('ConnectionJudge', () {
    test('sin red cuenta de inmediato; un tiempo agotado no', () {
      final judge = ConnectionJudge(slowFailuresToGoOffline: 2);
      expect(judge.isLostAfter(NetworkSignal.slow), isFalse);
      expect(judge.isLostAfter(NetworkSignal.unreachable), isTrue);
    });

    test('dos tiempos agotados seguidos dan por caída la conexión', () {
      final judge = ConnectionJudge(slowFailuresToGoOffline: 2);
      expect(judge.isLostAfter(NetworkSignal.slow), isFalse);
      expect(judge.isLostAfter(NetworkSignal.slow), isTrue);
    });

    test('una respuesta del servidor reinicia la cuenta', () {
      final judge = ConnectionJudge(slowFailuresToGoOffline: 2);
      judge.isLostAfter(NetworkSignal.slow);
      judge.isLostAfter(NetworkSignal.reachable);
      expect(judge.isLostAfter(NetworkSignal.slow), isFalse);
    });
  });

  group('NetworkSignals', () {
    DioException error(DioExceptionType type) =>
        DioException(requestOptions: RequestOptions(), type: type);

    test('las fallas reales de dio se traducen a señales', () {
      expect(
        NetworkSignals.fromException(error(DioExceptionType.connectionError)),
        NetworkSignal.unreachable,
      );
      expect(
        NetworkSignals.fromException(error(DioExceptionType.receiveTimeout)),
        NetworkSignal.slow,
      );
      expect(
        NetworkSignals.fromException(error(DioExceptionType.badResponse)),
        NetworkSignal.reachable,
      );
      expect(
        NetworkSignals.fromException(error(DioExceptionType.cancel)),
        isNull,
      );
    });
  });

  group('ReconnectBackoff', () {
    const backoff = ReconnectBackoff(
      initialDelay: Duration(seconds: 5),
      maxDelay: Duration(seconds: 20),
      factor: 2,
    );

    test('crece con cada intento y se detiene en el tope', () {
      expect(backoff.delayFor(0), const Duration(seconds: 5));
      expect(backoff.delayFor(1), const Duration(seconds: 10));
      expect(backoff.delayFor(2), const Duration(seconds: 20));
      expect(backoff.delayFor(9), const Duration(seconds: 20));
    });
  });

  group('RestoreOnceGate', () {
    test('cada restauración pasa una sola vez', () {
      final gate = RestoreOnceGate();
      expect(gate.take(1), isTrue);
      expect(gate.take(1), isFalse);
      expect(gate.take(2), isTrue);
      expect(gate.take(2), isFalse);
      // Un número viejo nunca vuelve a disparar.
      expect(gate.take(1), isFalse);
    });
  });

  group('ConnectivityCubit', () {
    test('sin red cae a sin conexión y la sonda crece con retroceso', () {
      fakeAsync((async) {
        final signals = NetworkSignals();
        final probe = _FakeProbe();
        final cubit = _cubit(signals, probe);
        signals.report(NetworkSignal.unreachable);
        async.flushMicrotasks();
        expect(cubit.state.phase, ConnectionPhase.offline);
        async.elapse(const Duration(seconds: 5));
        expect(probe.calls, 1);
        // Siguiente intento a los 10 s, no antes.
        async.elapse(const Duration(seconds: 9));
        expect(probe.calls, 1);
        async.elapse(const Duration(seconds: 1));
        expect(probe.calls, 2);
        cubit.close();
      });
    });

    test('al volver: "restablecida" con una restauración y luego en línea', () {
      fakeAsync((async) {
        final signals = NetworkSignals();
        final probe = _FakeProbe()..answers = [false, true];
        final cubit = _cubit(signals, probe);
        signals.report(NetworkSignal.unreachable);
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 5));
        expect(cubit.state.phase, ConnectionPhase.offline);
        async.elapse(const Duration(seconds: 10));
        expect(cubit.state.phase, ConnectionPhase.restored);
        expect(cubit.state.restoreEpoch, 1);
        async.elapse(const Duration(seconds: 3));
        expect(cubit.state.phase, ConnectionPhase.online);
        // Sin más sondas una vez en línea.
        final calls = probe.calls;
        async.elapse(const Duration(minutes: 5));
        expect(probe.calls, calls);
        cubit.close();
      });
    });

    test('una petición que responde también restablece la conexión', () {
      fakeAsync((async) {
        final signals = NetworkSignals();
        final cubit = _cubit(signals, _FakeProbe());
        signals.report(NetworkSignal.unreachable);
        async.flushMicrotasks();
        signals.report(NetworkSignal.reachable);
        async.flushMicrotasks();
        expect(cubit.state.phase, ConnectionPhase.restored);
        expect(cubit.state.restoreEpoch, 1);
        cubit.close();
      });
    });

    test(
      'en segundo plano no hay sondas y al volver se verifica al instante',
      () {
        fakeAsync((async) {
          final signals = NetworkSignals();
          final probe = _FakeProbe()..answers = [true];
          final cubit = _cubit(signals, probe);
          signals.report(NetworkSignal.unreachable);
          async.flushMicrotasks();
          cubit.setForeground(false);
          async.elapse(const Duration(minutes: 10));
          expect(probe.calls, 0);
          cubit.setForeground(true);
          async.elapse(Duration.zero);
          async.flushMicrotasks();
          expect(probe.calls, 1);
          expect(cubit.state.phase, ConnectionPhase.restored);
          cubit.close();
        });
      },
    );

    test(
      'las señales de una sola falla lenta no dan por caída la conexión',
      () {
        fakeAsync((async) {
          final signals = NetworkSignals();
          final cubit = _cubit(signals, _FakeProbe());
          signals.report(NetworkSignal.slow);
          async.flushMicrotasks();
          expect(cubit.state.phase, ConnectionPhase.online);
          cubit.close();
        });
      },
    );

    test(
      'verificar sin red avisa; con tope de frecuencia y una sola sonda',
      () {
        fakeAsync((async) {
          final signals = NetworkSignals();
          final probe = _FakeProbe()..answers = [true, false];
          DateTime now = DateTime(2026);
          final cubit = ConnectivityCubit(
            signals: signals,
            probe: probe,
            judge: ConnectionJudge(slowFailuresToGoOffline: 2),
            backoff: const ReconnectBackoff(
              initialDelay: Duration(minutes: 5),
              maxDelay: Duration(minutes: 5),
              factor: 1,
            ),
            restoredNoticeDuration: const Duration(seconds: 3),
            verifyMinInterval: const Duration(seconds: 30),
            clock: () => now,
          );
          cubit.verify();
          async.flushMicrotasks();
          expect(probe.calls, 1);
          expect(cubit.state.phase, ConnectionPhase.online);
          // Muy pronto: no hay otra sonda.
          now = now.add(const Duration(seconds: 10));
          cubit.verify();
          async.flushMicrotasks();
          expect(probe.calls, 1);
          // Pasado el tope, la sonda dice que no hay red.
          now = now.add(const Duration(seconds: 30));
          cubit.verify();
          async.flushMicrotasks();
          expect(probe.calls, 2);
          expect(cubit.state.phase, ConnectionPhase.offline);
          cubit.close();
        });
      },
    );

    test('cada caída y regreso sube la restauración en uno', () {
      fakeAsync((async) {
        final signals = NetworkSignals();
        final cubit = _cubit(signals, _FakeProbe());
        for (final round in [1, 2]) {
          signals.report(NetworkSignal.unreachable);
          async.flushMicrotasks();
          signals.report(NetworkSignal.reachable);
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 4));
          expect(cubit.state.restoreEpoch, round);
        }
        cubit.close();
      });
    });
  });
}
