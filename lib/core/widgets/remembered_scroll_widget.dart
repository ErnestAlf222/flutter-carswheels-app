import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/widgets/scroll_offset_store.dart';

/// Entrega un ScrollController que recuerda su posición entre visitas.
///
/// Si [contextKey] cambia (otro mercado o año) el contenido es nuevo: vuelve al inicio.
class RememberedScroll extends StatefulWidget {
  const RememberedScroll({
    super.key,
    required this.store,
    required this.sectionKey,
    required this.contextKey,
    required this.builder,
  });

  final ScrollOffsetStore store;
  final String sectionKey;
  final String contextKey;
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  @override
  State<RememberedScroll> createState() => _RememberedScrollState();
}

class _RememberedScrollState extends State<RememberedScroll> {
  // Único estado: el controlador (recurso del framework).
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _create(
      widget.store.offsetFor(widget.sectionKey, widget.contextKey),
    );
  }

  ScrollController _create(double offset) =>
      ScrollController(initialScrollOffset: offset)..addListener(_save);

  void _save() {
    if (!_controller.hasClients) return;
    widget.store.save(widget.sectionKey, widget.contextKey, _controller.offset);
  }

  @override
  void didUpdateWidget(RememberedScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contextKey == widget.contextKey) return;
    // Contenido nuevo: controlador nuevo en 0; el viejo se suelta tras el cuadro.
    widget.store.clear(widget.sectionKey);
    final old = _controller..removeListener(_save);
    _controller = _create(0);
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _controller);
}
