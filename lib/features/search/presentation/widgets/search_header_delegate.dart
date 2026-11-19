import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_field_widget.dart';

/// Encabezado de Buscar: el título y el selector se van con el scroll y la banda tinta con el campo queda fija.
class SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SearchHeaderDelegate({
    required this.topInset,
    required this.selectorBuilder,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  /// Área segura superior, ya medida por la pantalla.
  final double topInset;
  final WidgetBuilder selectorBuilder;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  // Alto del contenido sobre el campo: área segura, relleno y fila del título.
  double get _titleBottom =>
      topInset +
      HeaderConfig.contentTopPadding +
      SearchConfig.headerTitleRowHeight;

  // Banda curva al pie de la banda tinta: el campo nunca la toca.
  static const double _amplitude = WaveConfig.searchHeaderAmplitude;

  @override
  double get maxExtent =>
      _titleBottom +
      HeaderConfig.contentBottomPadding +
      2 * SearchConfig.fieldOverlap;

  @override
  double get minExtent =>
      topInset +
      2 * SearchConfig.pinnedBandPadding +
      SearchConfig.fieldHeight +
      _amplitude;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final range = maxExtent - minExtent;
    final double progress = range <= 0
        ? 1.0
        : math.min(shrinkOffset / range, 1.0);
    final extent = math.max(maxExtent - shrinkOffset, minExtent);
    // La banda cubre todo el alto menos lo que el campo sobresale por abajo.
    final bandHeight = extent - SearchConfig.fieldOverlap * (1 - progress);
    final animate = !MediaQuery.of(context).disableAnimations;
    final double titleOpacity = animate
        ? 1 - math.min(shrinkOffset / SearchConfig.headerTitleRowHeight, 1.0)
        : 1.0;
    // El sliver da solo un tope de alto: se fija el alto exacto del encabezado.
    return SizedBox(
      height: extent,
      child: Stack(
        children: [
          HeroHeaderWidget(
            padding: EdgeInsets.zero,
            shape: WaveConfig.searchHeaderWave,
            child: SizedBox(
              width: double.infinity,
              // La amplitud de la curva ya la suma el encabezado.
              height: bandHeight - _amplitude,
              child: Stack(
                children: [
                  Positioned(
                    top:
                        topInset +
                        HeaderConfig.contentTopPadding -
                        shrinkOffset,
                    left: 0,
                    right: 0,
                    height: SearchConfig.headerTitleRowHeight,
                    child: IgnorePointer(
                      ignoring: titleOpacity <= 0,
                      child: Opacity(
                        opacity: titleOpacity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: UiConfig.pageHorizontalPadding,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  AppTexts.searchPageTitle,
                                  style: AppTextStyles.onDarkScreenTitle,
                                ),
                              ),
                              selectorBuilder(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: (SearchConfig.pinnedBandPadding + _amplitude) * progress,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiConfig.pageHorizontalPadding,
              ),
              child: SearchFieldWidget(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                onClear: onClear,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // onSubmitted se omite: llega como cierre nuevo en cada build y hace lo mismo.
  @override
  bool shouldRebuild(SearchHeaderDelegate oldDelegate) =>
      topInset != oldDelegate.topInset ||
      selectorBuilder != oldDelegate.selectorBuilder ||
      controller != oldDelegate.controller ||
      focusNode != oldDelegate.focusNode ||
      onChanged != oldDelegate.onChanged ||
      onClear != oldDelegate.onClear;
}
