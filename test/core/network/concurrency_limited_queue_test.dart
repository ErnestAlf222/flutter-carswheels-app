import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tarea controlada: registra su inicio y termina cuando la prueba lo decide.
class _ControlledTask {
  _ControlledTask(this.name, this.log, this.running);

  final String name;
  final List<String> log;
  final Set<String> running;
  final Completer<String> completer = Completer<String>();

  Future<String> call() {
    log.add(name);
    running.add(name);
    return completer.future.whenComplete(() => running.remove(name));
  }
}

void main() {
  late List<String> startOrder;
  late Set<String> running;

  _ControlledTask task(String name) =>
      _ControlledTask(name, startOrder, running);

  setUp(() {
    startOrder = [];
    running = {};
  });

  test('nunca ejecuta más tareas a la vez que el límite', () async {
    final queue = ConcurrencyLimitedQueue(maxConcurrent: 2);
    final tasks = List.generate(5, (index) => task('t$index'));
    final results = tasks.map((t) => queue.enqueue(t.call)).toList();
    final peak = [0];
    for (final current in tasks) {
      await Future<void>.delayed(Duration.zero);
      if (running.length > peak[0]) peak[0] = running.length;
      expect(running.length, lessThanOrEqualTo(2));
      current.completer.complete(current.name);
      await Future<void>.delayed(Duration.zero);
    }
    expect(await Future.wait(results), ['t0', 't1', 't2', 't3', 't4']);
    expect(peak[0], 2);
  });

  test('inicia las tareas en orden de llegada', () async {
    final queue = ConcurrencyLimitedQueue(maxConcurrent: 1);
    final tasks = List.generate(4, (index) => task('t$index'));
    final results = tasks.map((t) => queue.enqueue(t.call)).toList();
    for (final current in tasks) {
      await Future<void>.delayed(Duration.zero);
      current.completer.complete(current.name);
    }
    await Future.wait(results);
    expect(startOrder, ['t0', 't1', 't2', 't3']);
  });

  test(
    'cancelPending falla las que no empezaron y deja terminar las demás',
    () async {
      final queue = ConcurrencyLimitedQueue(maxConcurrent: 1);
      final first = task('t0');
      final second = task('t1');
      final firstResult = queue.enqueue(first.call);
      final secondResult = queue.enqueue(second.call);
      final secondExpectation = expectLater(
        secondResult,
        throwsA(isA<CancelledFailure>()),
      );
      queue.cancelPending();
      await secondExpectation;
      first.completer.complete('listo');
      expect(await firstResult, 'listo');
      expect(startOrder, ['t0']);
    },
  );

  test('después de cancelPending la cola sigue aceptando tareas', () async {
    final queue = ConcurrencyLimitedQueue(maxConcurrent: 1);
    queue.cancelPending();
    expect(await queue.enqueue(() async => 'nueva'), 'nueva');
  });

  test('un error no detiene a las demás', () async {
    final queue = ConcurrencyLimitedQueue(maxConcurrent: 1);
    final failing = queue.enqueue<String>(
      () async => throw const NetworkFailure('sin red'),
    );
    final next = queue.enqueue(() async => 'bien');
    await expectLater(failing, throwsA(isA<NetworkFailure>()));
    expect(await next, 'bien');
  });

  test('close espera las tareas y rechaza las nuevas', () async {
    final queue = ConcurrencyLimitedQueue(maxConcurrent: 1);
    final active = task('t0');
    final result = queue.enqueue(active.call);
    final closed = [false];
    final closing = queue.close().then((_) => closed[0] = true);
    await Future<void>.delayed(Duration.zero);
    expect(closed[0], isFalse);
    await expectLater(
      queue.enqueue(() async => 'tarde'),
      throwsA(isA<StateError>()),
    );
    active.completer.complete('fin');
    await closing;
    expect(await result, 'fin');
    expect(closed[0], isTrue);
  });
}
