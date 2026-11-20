import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/features/connectivity/domain/domain.dart';
import 'package:cars_wheels_app/features/connectivity/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/connectivity/presentation/widgets/connectivity_band_widget.dart';

/// Llama a [onRestored] una sola vez cada vez que vuelve la conexión.
///
/// Sin cubit de conexión (por ejemplo en una prueba) no hace nada.
class ConnectivityRestoreListener extends StatefulWidget {
  const ConnectivityRestoreListener({
    super.key,
    required this.onRestored,
    required this.child,
  });

  final VoidCallback onRestored;
  final Widget child;

  @override
  State<ConnectivityRestoreListener> createState() =>
      _ConnectivityRestoreListenerState();
}

class _ConnectivityRestoreListenerState
    extends State<ConnectivityRestoreListener> {
  // Cada restauración se atiende una vez, aunque el estado se emita de nuevo.
  final RestoreOnceGate _gate = RestoreOnceGate();

  @override
  Widget build(BuildContext context) {
    final cubit = ConnectivityScope.maybeOf(context);
    if (cubit == null) return widget.child;
    return BlocListener<ConnectivityCubit, ConnectivityState>(
      bloc: cubit,
      listenWhen: (previous, current) =>
          current.phase == ConnectionPhase.restored &&
          previous.restoreEpoch != current.restoreEpoch,
      listener: (context, state) {
        if (_gate.take(state.restoreEpoch)) widget.onRestored();
      },
      child: widget.child,
    );
  }
}
