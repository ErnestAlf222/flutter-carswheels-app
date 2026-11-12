import 'dart:async';

import 'package:cars_wheels_app/core/errors/errors.dart';

/// Espera una duración; se inyecta para que las pruebas no tarden.
typedef WaitFunction = Future<void> Function(Duration duration);

/// Ejecuta tareas una a la vez, en orden y con un ritmo mínimo entre inicios.
class RateLimitedQueue {
  RateLimitedQueue({
    required this.minInterval,
    required this.maxRetries,
    this.wait = _defaultWait,
  }) {
    _subscription = _controller.stream.asyncMap(_runPaced).listen(null);
  }

  static const String _closedMessage = 'La cola ya fue cerrada';

  static Future<void> _defaultWait(Duration duration) =>
      Future<void>.delayed(duration);

  /// Tiempo mínimo entre el inicio de una tarea y el de la siguiente.
  final Duration minInterval;
  final int maxRetries;
  final WaitFunction wait;
  final StreamController<Future<void> Function()> _controller =
      StreamController<Future<void> Function()>();
  // Recurso cancelable: procesa el flujo de tareas.
  late final StreamSubscription<void> _subscription;

  /// Encola la tarea; la reintenta si lanza RateLimitFailure.
  Future<T> enqueue<T>(Future<T> Function() task) {
    if (_controller.isClosed) {
      return Future<T>.error(StateError(_closedMessage));
    }
    final completer = Completer<T>();
    _controller.add(() => _complete(task, completer));
    return completer.future;
  }

  /// Deja de aceptar tareas y termina las pendientes.
  Future<void> close() async {
    await _controller.close();
    await _subscription.asFuture<void>();
    await _subscription.cancel();
  }

  // Ejecuta el trabajo y espera lo que falte del intervalo mínimo.
  Future<void> _runPaced(Future<void> Function() job) async {
    final stopwatch = Stopwatch()..start();
    await job();
    final remaining = minInterval - stopwatch.elapsed;
    if (remaining > Duration.zero) await wait(remaining);
  }

  // Resuelve el Completer con el resultado o el error de la tarea.
  Future<void> _complete<T>(
    Future<T> Function() task,
    Completer<T> completer,
  ) async {
    try {
      completer.complete(await _attempt(task, maxRetries));
    } on Object catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    }
  }

  // Intenta la tarea y, si hay límite de tasa, espera y reintenta.
  Future<T> _attempt<T>(Future<T> Function() task, int retriesLeft) async {
    try {
      return await task();
    } on RateLimitFailure catch (failure) {
      if (retriesLeft <= 0) rethrow;
      await wait(Duration(seconds: failure.retryAfterSeconds));
      return _attempt(task, retriesLeft - 1);
    }
  }
}
