import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/connectivity/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/connectivity/presentation/widgets/connectivity_band_widget.dart';

/// Estado de error que, sin conexión, lo dice con claridad en vez de un error crudo.
class ConnectivityErrorStateWidget extends StatelessWidget {
  const ConnectivityErrorStateWidget({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final cubit = ConnectivityScope.maybeOf(context);
    if (cubit == null) return ErrorStateWidget(onRetry: onRetry);
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      bloc: cubit,
      buildWhen: (previous, current) => previous.isOffline != current.isOffline,
      builder: (context, state) =>
          ErrorStateWidget(onRetry: onRetry, offline: state.isOffline),
    );
  }
}
