import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _noWait(Duration duration) async {}

RateLimitedQueue _queue({
  Duration minInterval = Duration.zero,
  int maxRetries = 2,
  WaitFunction wait = _noWait,
}) => RateLimitedQueue(
  minInterval: minInterval,
  maxRetries: maxRetries,
  wait: wait,
);

void main() {
  test('ejecuta las tareas en orden de llegada', () async {
    final queue = _queue();
    final order = <int>[];
    final futures = [
      for (final id in [1, 2, 3])
        queue.enqueue(() async {
          order.add(id);
          return id;
        }),
    ];
    expect(await Future.wait(futures), [1, 2, 3]);
    expect(order, [1, 2, 3]);
    await queue.close();
  });

  test('nunca ejecuta dos tareas a la vez', () async {
    final queue = _queue();
    final running = <int>[0];
    final maxSeen = <int>[0];
    Future<void> task() async {
      running[0]++;
      if (running[0] > maxSeen[0]) maxSeen[0] = running[0];
      await Future<void>.delayed(const Duration(milliseconds: 5));
      running[0]--;
    }

    await Future.wait([
      for (final _ in List<int>.filled(4, 0)) queue.enqueue(task),
    ]);
    expect(maxSeen[0], 1);
    await queue.close();
  });

  test('respeta el intervalo mínimo entre inicios', () async {
    const interval = Duration(milliseconds: 60);
    final queue = RateLimitedQueue(minInterval: interval, maxRetries: 0);
    final stopwatch = Stopwatch()..start();
    final starts = <Duration>[];
    await Future.wait([
      for (final _ in List<int>.filled(3, 0))
        queue.enqueue(() async => starts.add(stopwatch.elapsed)),
    ]);
    for (final index in [1, 2]) {
      final gap = starts[index] - starts[index - 1];
      // Tolerancia por la precisión de los temporizadores.
      expect(gap.inMilliseconds, greaterThanOrEqualTo(50));
    }
    await queue.close();
  });

  test('reintenta tras RateLimitFailure y espera retry-after', () async {
    final waits = <Duration>[];
    final queue = _queue(
      minInterval: Duration.zero,
      wait: (duration) async => waits.add(duration),
    );
    final attempts = <int>[0];
    final result = await queue.enqueue(() async {
      attempts[0]++;
      if (attempts[0] == 1) {
        throw const RateLimitFailure('429', retryAfterSeconds: 18);
      }
      return 'ok';
    });
    expect(result, 'ok');
    expect(attempts[0], 2);
    expect(waits, [const Duration(seconds: 18)]);
    await queue.close();
  });

  test('se rinde tras el máximo de reintentos y relanza', () async {
    final queue = _queue(maxRetries: 2);
    final attempts = <int>[0];
    final future = queue.enqueue<void>(() async {
      attempts[0]++;
      throw const RateLimitFailure('429', retryAfterSeconds: 1);
    });
    await expectLater(
      future,
      throwsA(const RateLimitFailure('429', retryAfterSeconds: 1)),
    );
    expect(attempts[0], 3);
    await queue.close();
  });

  test('otro error no se reintenta', () async {
    final queue = _queue();
    final attempts = <int>[0];
    final future = queue.enqueue<void>(() async {
      attempts[0]++;
      throw const ServerFailure('500');
    });
    await expectLater(future, throwsA(const ServerFailure('500')));
    expect(attempts[0], 1);
    await queue.close();
  });

  test('una tarea fallida no detiene la siguiente', () async {
    final queue = _queue();
    final failing = queue.enqueue<void>(() async {
      throw const NetworkFailure('x');
    });
    final next = queue.enqueue(() async => 'sigue');
    await expectLater(failing, throwsA(isA<NetworkFailure>()));
    expect(await next, 'sigue');
    await queue.close();
  });

  test('close termina las pendientes y rechaza tareas nuevas', () async {
    final queue = _queue();
    final pending = queue.enqueue(() async => 1);
    await queue.close();
    expect(await pending, 1);
    await expectLater(queue.enqueue(() async => 2), throwsA(isA<StateError>()));
  });
  test(
    'cancelPending cancela las pendientes y deja terminar la actual',
    () async {
      final queue = _queue();
      final release = Completer<void>();
      final started = <String>[];
      final running = queue.enqueue(() async {
        started.add('actual');
        await release.future;
        return 'actual';
      });
      final waiting = queue.enqueue(() async {
        started.add('pendiente');
        return 'pendiente';
      });
      final waitingResult = waiting.then<Object?>((v) => v, onError: (e) => e);
      await Future<void>.delayed(Duration.zero);
      queue.cancelPending();
      release.complete();
      expect(await running, 'actual');
      expect(await waitingResult, isA<CancelledFailure>());
      expect(started, ['actual']);
      await queue.close();
    },
  );

  test('tras cancelPending la cola sigue aceptando tareas', () async {
    final queue = _queue();
    queue.cancelPending();
    expect(await queue.enqueue(() async => 7), 7);
    await queue.close();
  });
}
