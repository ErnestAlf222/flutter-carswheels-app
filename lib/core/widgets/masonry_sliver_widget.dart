import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/algorithms/masonry_layout.dart';
import 'package:cars_wheels_app/core/theme/app_motion.dart';

/// Mosaico de columnas de alturas variables dentro de un sliver, sin paquetes.
///
/// Cada tarjeta mide lo que dice [heightOf] para el ancho de su columna y va en
/// la columna más corta. Al cambiar la lista las tarjetas que siguen se
/// reacomodan con movimiento, las nuevas entran con fundido y las que salen se
/// desvanecen donde estaban. Se construyen todas a la vez: está pensado para
/// listas de decenas de tarjetas, cada una con su propia capa de pintado.
class MasonrySliverWidget<T> extends StatefulWidget {
  const MasonrySliverWidget({
    super.key,
    required this.items,
    required this.keyOf,
    required this.heightOf,
    required this.itemBuilder,
    required this.columns,
    required this.spacing,
  });

  final List<T> items;

  /// Identidad estable de cada elemento; conserva su estado al reacomodarse.
  final String Function(T item) keyOf;

  /// Alto del elemento para el ancho de columna dado.
  final double Function(T item, double columnWidth) heightOf;

  /// Arma la tarjeta; [index] es su posición en la lista.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  final int columns;
  final double spacing;

  @override
  State<MasonrySliverWidget<T>> createState() => _MasonrySliverWidgetState<T>();
}

// Posición de una tarjeta ya colocada.
typedef _Rect = ({double left, double top, double width, double height});

// Tarjeta que salió de la lista y se desvanece donde estaba.
typedef _Leaving<T> = ({T item, int index, _Rect rect});

class _MasonrySliverWidgetState<T> extends State<MasonrySliverWidget<T>> {
  // Recursos propios: las posiciones previas, las que salen y su temporizador.
  Map<String, _Rect> _lastRects = {};
  final Map<String, _Leaving<T>> _leaving = {};
  final Set<String> _seen = {};
  Timer? _leaveTimer;
  bool _firstBuild = true;

  @override
  void didUpdateWidget(MasonrySliverWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final currentKeys = {for (final item in widget.items) widget.keyOf(item)};
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    // Lo que volvió a la lista (Deshacer) deja de desvanecerse.
    _leaving.removeWhere((key, _) => currentKeys.contains(key));
    if (reduced) return;
    for (final (index, item) in oldWidget.items.indexed) {
      final key = widget.keyOf(item);
      final rect = _lastRects[key];
      if (!currentKeys.contains(key) && rect != null) {
        _leaving[key] = (item: item, index: index, rect: rect);
      }
    }
    _leaveTimer?.cancel();
    if (_leaving.isNotEmpty) {
      _leaveTimer = Timer(AppMotion.fast, () {
        if (mounted) setState(_leaving.clear);
      });
    }
  }

  @override
  void dispose() {
    _leaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.crossAxisExtent;
        final columnWidth =
            (width - widget.spacing * (widget.columns - 1)) / widget.columns;
        final layout = MasonryLayout.place(
          heights: [
            for (final item in widget.items) widget.heightOf(item, columnWidth),
          ],
          columns: widget.columns,
          spacing: widget.spacing,
        );
        final rects = <String, _Rect>{};
        for (final (index, item) in widget.items.indexed) {
          final slot = layout.slots[index];
          rects[widget.keyOf(item)] = (
            left: slot.column * (columnWidth + widget.spacing),
            top: slot.top,
            width: columnWidth,
            height: widget.heightOf(item, columnWidth),
          );
        }
        _lastRects = rects;
        final reduced = MediaQuery.disableAnimationsOf(context);
        final duration = reduced ? Duration.zero : AppMotion.medium;
        final animateInsert = !_firstBuild && !reduced;
        final children = <Widget>[
          for (final (index, item) in widget.items.indexed)
            _positioned(
              item,
              index,
              rects[widget.keyOf(item)]!,
              duration,
              fadeIn: animateInsert && !_seen.contains(widget.keyOf(item)),
            ),
          for (final entry in _leaving.entries)
            _leavingTile(entry.key, entry.value, context),
        ];
        _seen
          ..clear()
          ..addAll(rects.keys);
        _firstBuild = false;
        return SliverToBoxAdapter(
          child: AnimatedContainer(
            duration: duration,
            curve: AppMotion.change,
            height: layout.height,
            child: Stack(clipBehavior: Clip.none, children: children),
          ),
        );
      },
    );
  }

  Widget _positioned(
    T item,
    int index,
    _Rect rect,
    Duration duration, {
    required bool fadeIn,
  }) {
    final child = RepaintBoundary(
      child: widget.itemBuilder(context, item, index),
    );
    return AnimatedPositioned(
      key: ValueKey(widget.keyOf(item)),
      duration: duration,
      curve: AppMotion.change,
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: fadeIn
          ? TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: AppMotion.fast,
              curve: AppMotion.enter,
              builder: (context, opacity, child) =>
                  Opacity(opacity: opacity, child: child),
              child: child,
            )
          : child,
    );
  }

  Widget _leavingTile(String key, _Leaving<T> leaving, BuildContext context) {
    final rect = leaving.rect;
    return Positioned(
      key: ValueKey('leaving-$key'),
      left: rect.left,
      top: rect.top,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 1, end: 0),
          duration: AppMotion.fast,
          curve: AppMotion.change,
          builder: (context, opacity, child) =>
              Opacity(opacity: opacity, child: child),
          child: widget.itemBuilder(context, leaving.item, leaving.index),
        ),
      ),
    );
  }
}
