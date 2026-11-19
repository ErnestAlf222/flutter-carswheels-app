import 'package:flutter/widgets.dart';

/// Avisa una vez, tras el primer cuadro, que la pantalla de Inicio se mostró.
class HomeEntrySync extends StatefulWidget {
  const HomeEntrySync({super.key, required this.onEnter, required this.child});

  final void Function(BuildContext context) onEnter;
  final Widget child;

  @override
  State<HomeEntrySync> createState() => _HomeEntrySyncState();
}

// Sin campos propios: solo usa el ciclo de vida para avisar la entrada.
class _HomeEntrySyncState extends State<HomeEntrySync> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onEnter(context);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
