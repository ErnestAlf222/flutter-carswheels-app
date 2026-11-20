import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/brand_tile_widget.dart';

/// Fila con flechas y una lista horizontal de marcas que se arrastra con el dedo.
class BrandCarouselWidget extends StatelessWidget {
  const BrandCarouselWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogCubit, CatalogState>(
      builder: (context, state) {
        if (state is! CatalogLoaded) return const SizedBox.shrink();
        // La entrada es de la fila completa y ocurre solo al aparecer.
        return AnimatedEntryWidget(
          index: 0,
          child: _BrandCarouselBody(state: state),
        );
      },
    );
  }
}

/// Dueño del desplazamiento: la lista y las flechas comparten el controlador.
class _BrandCarouselBody extends StatefulWidget {
  const _BrandCarouselBody({required this.state});

  final CatalogLoaded state;

  @override
  State<_BrandCarouselBody> createState() => _BrandCarouselBodyState();
}

class _BrandCarouselBodyState extends State<_BrandCarouselBody> {
  ScrollController? _controller;
  double _extent = 0;

  // Inicio de ventana que esta lista ya informó al cubit.
  int? _reportedStart;

  int get _count => widget.state.brands.length;

  int get _visible => math.min(CarouselConfig.visibleBrandCount, _count);

  // Sin más marcas que las visibles no hay nada que recorrer ni dar la vuelta.
  bool get _scrollable => _count > CarouselConfig.visibleBrandCount;

  double _offsetOf(int start) =>
      (_scrollable ? CircularIndex.initialPage(start, _count) : 0) * _extent;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_BrandCarouselBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final controller = _controller;
    if (controller == null || !controller.hasClients) return;
    final next = widget.state;
    final reloaded =
        next.year != oldWidget.state.year ||
        next.brands.length != oldWidget.state.brands.length;
    if (reloaded) {
      // Otro año o mercado: la lista es nueva y arranca en su ventana.
      _reportedStart = next.windowStart;
      controller.jumpTo(_offsetOf(next.windowStart));
      return;
    }
    if (next.windowStart != oldWidget.state.windowStart &&
        next.windowStart != _reportedStart) {
      _scrollTo(_offsetOf(next.windowStart));
    }
  }

  // Ajusta el controlador cuando cambia el ancho (giro de pantalla).
  void _syncExtent(double extent) {
    if (_extent == extent) return;
    final hadExtent = _extent > 0;
    _extent = extent;
    final controller = _controller;
    if (hadExtent && controller != null && controller.hasClients) {
      final start = widget.state.windowStart;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && controller.hasClients) {
          controller.jumpTo(_offsetOf(start));
        }
      });
    }
  }

  void _scrollTo(double offset) {
    final controller = _controller;
    if (controller == null || !controller.hasClients) return;
    if (MediaQuery.of(context).disableAnimations) {
      controller.jumpTo(offset);
      _report(offset);
      return;
    }
    controller.animateTo(
      offset,
      duration: const Duration(
        milliseconds: CarouselConfig.pageScrollMilliseconds,
      ),
      curve: Curves.easeOutCubic,
    );
  }

  // Las flechas avanzan o retroceden una página de marcas.
  void _page(int direction) {
    final controller = _controller;
    if (controller == null || !controller.hasClients || _extent <= 0) return;
    final current = (controller.offset / _extent).round();
    _scrollTo((current + direction * _visible) * _extent);
  }

  // Informa al cubit la primera marca visible; el redondeo la deja entera.
  void _report(double offset) {
    if (_extent <= 0) return;
    final start = CircularIndex.wrap((offset / _extent).round(), _count);
    if (start == widget.state.windowStart) return;
    _reportedStart = start;
    context.read<CatalogCubit>().showBrandsFrom(start);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final cubit = context.read<CatalogCubit>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ArrowButton(
          icon: Symbols.chevron_left,
          label: AppTexts.previousBrandsLabel,
          onPressed: () => _page(-1),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              _syncExtent(constraints.maxWidth / _visible);
              _reportedStart ??= state.windowStart;
              final controller = _controller ??= ScrollController(
                initialScrollOffset: _offsetOf(state.windowStart),
              );
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.axis != Axis.horizontal) {
                    return false;
                  }
                  if (notification is ScrollEndNotification) {
                    _report(notification.metrics.pixels);
                  }
                  // El menú flotante y la paginación solo atienden lo vertical.
                  return true;
                },
                child: SizedBox(
                  height: _rowHeight(context),
                  child: ListView.builder(
                    controller: controller,
                    scrollDirection: Axis.horizontal,
                    // Rebote suave, aunque quepan todas las marcas.
                    physics: _scrollable
                        ? const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics(),
                          )
                        : const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      vertical: CarouselConfig.shadowRoom,
                    ),
                    // Solo las marcas a la vista.
                    scrollCacheExtent: const ScrollCacheExtent.pixels(0),
                    itemExtent: _extent,
                    itemCount: _scrollable ? null : _count,
                    itemBuilder: (context, position) {
                      final index = CircularIndex.wrap(position, _count);
                      return Center(
                        child: BrandTileWidget(
                          brandName: state.brands[index].name,
                          selected: index == state.selectedIndex,
                          onTap: () => cubit.selectBrand(index),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        _ArrowButton(
          icon: Symbols.chevron_right,
          label: AppTexts.nextBrandsLabel,
          onPressed: () => _page(1),
        ),
      ],
    );
  }

  // Alto de la marca: aro, tarjeta, hueco y una línea del nombre con la escala de texto.
  double _rowHeight(BuildContext context) {
    final captionSize = AppTextStyles.caption.fontSize!;
    final name =
        MediaQuery.textScalerOf(context).scale(captionSize) *
        CarouselConfig.brandNameLineHeightFactor;
    return CarouselConfig.brandTileSize +
        AppSpacing.xs +
        name +
        2 * CarouselConfig.shadowRoom;
  }
}

/// Botón circular de flecha.
class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onPressed,
      child: SizedBox(
        width: CarouselConfig.arrowTouchTargetSize,
        height: CarouselConfig.arrowTouchTargetSize,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Center(
              child: Container(
                width: CarouselConfig.arrowButtonSize,
                height: CarouselConfig.arrowButtonSize,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(
                    BorderSide(
                      color: AppColors.outline,
                      width: UiConfig.cardBorderWidth,
                    ),
                  ),
                  boxShadow: AppShadows.soft,
                ),
                child: Icon(
                  icon,
                  size: CarouselConfig.arrowIconSize,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
