import 'dart:async';
import 'dart:collection';

import 'package:cars_wheels_app/core/errors/errors.dart';

/// Tarea en espera o en curso: cómo ejecutarla y cómo cancelarla.
class _QueuedTask {
  _QueuedTask({required this.run, required this.cancel});

  final Future<void> Function() run;
  final void Function() cancel;
  final Completer<void> done = Completer<void>();
}

/// Ejecuta hasta maxConcurrent tareas a la vez, iniciándolas en orden de llegada.
class ConcurrencyLimitedQueue {
  ConcurrencyLimitedQueue({required this.maxConcurrent})
    : assert(maxConcurrent > 0);

  static const String _closedMessage = 'La cola ya fue cerrada';
  static const String _cancelledMessage = 'La tarea fue cancelada';

  final int maxConcurrent;
  final Queue<_QueuedTask> _pending = Queue<_QueuedTask>();
  final Set<_QueuedTask> _running = <_QueuedTask>{};
  final Set<_QueuedTask> _outstanding = <_QueuedTask>{};
  final Completer<void> _closedSignal = Completer<void>();

  /// Encola la tarea; arranca de inmediato si hay lugar.
  Future<T> enqueue<T>(Future<T> Function() task) {
    if (_closedSignal.isCompleted) {
      return Future<T>.error(StateError(_closedMessage));
    }
    final completer = Completer<T>();
    final queued = _QueuedTask(
      run: () async {
        try {
          completer.complete(await task());
        } on Object catch (error, stackTrace) {
          completer.completeError(error, stackTrace);
        }
      },
      cancel: () =>
          completer.completeError(const CancelledFailure(_cancelledMessage)),
    );
    _pending.add(queued);
    _outstanding.add(queued);
    _startAvailable();
    return completer.future;
  }

  /// Cancela las tareas que no empezaron; las que corren terminan.
  void cancelPending() {
    while (_pending.isNotEmpty) {
      final queued = _pending.removeFirst();
      queued.cancel();
      _finish(queued);
    }
  }

  /// Deja de aceptar tareas y espera a que terminen las que quedaron.
  Future<void> close() async {
    if (!_closedSignal.isCompleted) _closedSignal.complete();
    await Future.wait(_outstanding.map((queued) => queued.done.future));
  }

  // Inicia tareas mientras haya lugar, en orden de llegada.
  void _startAvailable() {
    while (_running.length < maxConcurrent && _pending.isNotEmpty) {
      final queued = _pending.removeFirst();
      _running.add(queued);
      unawaited(_run(queued));
    }
  }

  Future<void> _run(_QueuedTask queued) async {
    await queued.run();
    _running.remove(queued);
    _finish(queued);
    _startAvailable();
  }

  void _finish(_QueuedTask queued) {
    _outstanding.remove(queued);
    queued.done.complete();
  }
}
