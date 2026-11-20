import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/features/connectivity/presentation/cubits/cubits.dart';

/// Avisa al cubit de conexión si la app está en primer o en segundo plano.
class ConnectivityLifecycleHost extends StatefulWidget {
  const ConnectivityLifecycleHost({
    super.key,
    required this.cubit,
    required this.child,
  });

  final ConnectivityCubit cubit;
  final Widget child;

  @override
  State<ConnectivityLifecycleHost> createState() =>
      _ConnectivityLifecycleHostState();
}

class _ConnectivityLifecycleHostState extends State<ConnectivityLifecycleHost>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.cubit.setForeground(state == AppLifecycleState.resumed);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
