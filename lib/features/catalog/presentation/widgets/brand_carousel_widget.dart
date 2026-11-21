import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/domain.dart';
import 'package:cars_wheels_app/features/catalog/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/brand_tile_widget.dart';

/// Carrusel de marcas a todo el ancho con flechas superpuestas y bordes difuminados.
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

  int get _visible => BrandCarouselFocus.visibleOf(_count);

  // Sin más marcas que las visibles no hay nada que recorrer ni dar la vuelta.
  bool get _scrollable => BrandCarouselFocus.isScrollable(_count);

  // Al abrir, la marca activa queda en el centro de la ventana.
  int get _centeredStart =>
      BrandCarouselFocus.windowStartFor(widget.state.selectedIndex, _count);

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
    final moved =
        next.windowStart != oldWidget.state.windowStart &&
        next.windowStart != _reportedStart;
    if (reloaded || moved) {
      // Otro mercado o una marca elegida: la activa vuelve al centro, animada.
      _reportedStart = next.windowStart;
      _centerOn(next.windowStart);
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

  // Lleva la ventana a [start] por el camino más corto de la vuelta.
  void _centerOn(int start) {
    final controller = _controller;
    if (controller == null || !controller.hasClients || _extent <= 0) return;
    if (!_scrollable) return;
    final current = (controller.offset / _extent).round();
    final target = BrandCarouselFocus.nearestPosition(
      current: current,
      target: start,
      count: _count,
    );
    _scrollTo(target * _extent);
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
      curve: AppMotion.enter,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        // Cuatro marcas completas y media más asomando; con pocas, repartidas.
        _syncExtent(
          _scrollable
              ? width /
                    (CarouselConfig.visibleBrandCount +
                        CarouselConfig.peekFraction)
              : width / _visible,
        );
        // La ventana guardada manda al abrir; si la activa no está al centro,
        // el cubit la recentra y la lista se desplaza sola hasta ella.
        _reportedStart ??= state.windowStart;
        final created = _controller == null;
        final controller = _controller ??= ScrollController(
          initialScrollOffset: _offsetOf(state.windowStart),
        );
        if (created && state.windowStart != _centeredStart) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) cubit.showBrandsFrom(_centeredStart);
          });
        }
        return SizedBox(
          height: _rowHeight(context),
          child: Stack(
            children: [
              Positioned.fill(
                child: _EdgeFade(
                  width: width,
                  child: NotificationListener<ScrollNotification>(
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
                    child: ListView.builder(
                      controller: controller,
                      scrollDirection: Axis.horizontal,
                      // Física nativa de la plataforma; sin recorrido, no se desplaza.
                      physics: _scrollable
                          ? null
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
                ),
              ),
              _ArrowButton(
                alignment: Alignment.centerLeft,
                icon: Symbols.chevron_left,
                label: AppTexts.previousBrandsLabel,
                visible: BrandCarouselFocus.hasMore(_count),
                onPressed: () => _page(-1),
              ),
              _ArrowButton(
                alignment: Alignment.centerRight,
                icon: Symbols.chevron_right,
                label: AppTexts.nextBrandsLabel,
                visible: BrandCarouselFocus.hasMore(_count),
                onPressed: () => _page(1),
              ),
            ],
          ),
        );
      },
    );
  }

  // Alto de la marca: aro, tarjeta, hueco y una línea del nombre con la escala de texto.
  double _rowHeight(BuildContext context) {
    final labelSize = AppTextStyles.brandLabel.fontSize!;
    final name =
        MediaQuery.textScalerOf(context).scale(labelSize) *
        CarouselConfig.brandNameLineHeightFactor;
    return CarouselConfig.brandTileSize +
        AppSpacing.xs +
        name +
        2 * CarouselConfig.shadowRoom;
  }
}

/// Desvanece los logos hacia los bordes con un degradado de ancho fijo.
class _EdgeFade extends StatelessWidget {
  const _EdgeFade({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final fraction = width <= 0
        ? 0.0
        : (CarouselConfig.edgeFadeWidth / width).clamp(0.0, 0.5);
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (bounds) => LinearGradient(
        stops: [0, fraction, 1 - fraction, 1],
        colors: const [
          AppColors.transparent,
          AppColors.ink,
          AppColors.ink,
          AppColors.transparent,
        ],
      ).createShader(bounds),
      child: child,
    );
  }
}

/// Botón circular de flecha superpuesto; solo se ve si hay más marcas hacia allá.
class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.alignment,
    required this.icon,
    required this.label,
    required this.visible,
    required this.onPressed,
  });

  final Alignment alignment;
  final IconData icon;
  final String label;
  final bool visible;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : AppMotion.fast;
    // Centrada en la tarjeta de la marca, no en la fila con su nombre.
    return Positioned(
      left: alignment == Alignment.centerLeft
          ? CarouselConfig.arrowEdgeInset
          : null,
      right: alignment == Alignment.centerRight
          ? CarouselConfig.arrowEdgeInset
          : null,
      top:
          CarouselConfig.shadowRoom +
          (CarouselConfig.brandTileSize - CarouselConfig.arrowTouchTargetSize) /
              2,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: duration,
          curve: AppMotion.enter,
          child: Semantics(
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
          ),
        ),
      ),
    );
  }
}
