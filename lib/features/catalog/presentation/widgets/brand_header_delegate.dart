import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/brand_carousel_widget.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/brand_compact_bar_widget.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// Encabezado fijo y flotante: se encoge de la fila de marcas a una barra.
class BrandHeaderDelegate extends SliverPersistentHeaderDelegate {
  const BrandHeaderDelegate({
    required this.year,
    required this.availableYears,
    required this.brandCount,
    required this.selectedIndex,
    required this.windowStart,
    required this.brandName,
    required this.isRefreshing,
    required this.snapDuration,
    required this.onYearSelected,
    this.topInset = 0,
    this.vsync,
  });

  final int year;
  final List<int> availableYears;
  final int brandCount;
  final int selectedIndex;
  final int windowStart;
  final String brandName;
  final bool isRefreshing;
  final Duration snapDuration;
  final ValueChanged<int> onYearSelected;

  /// Área segura superior: la barra compacta queda por debajo de ella.
  final double topInset;

  /// Necesario para animar el ajuste del encabezado flotante.
  @override
  final TickerProvider? vsync;

  @override
  double get maxExtent => UiConfig.headerExpandedHeight;

  @override
  double get minExtent => UiConfig.headerCompactHeight + topInset;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration =>
      FloatingHeaderSnapConfiguration(
        curve: AppCurves.reboundCurve,
        duration: snapDuration,
      );

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final fade =
        ((t - AnimationConfig.headerContentFadeStart) /
                (AnimationConfig.headerContentFadeEnd -
                    AnimationConfig.headerContentFadeStart))
            .clamp(0.0, 1.0);
    final expandedOpacity = 1.0 - fade;
    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: t,
          child: const DecoratedBox(
            decoration: BoxDecoration(boxShadow: AppShadows.headerBottom),
          ),
        ),
        // Fondo sólido: al fijarse tapa el contenido que pasa por debajo.
        const ColoredBox(color: AppColors.background),
        _fading(
          opacity: expandedOpacity,
          child: ClipRect(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              minHeight: maxExtent,
              maxHeight: maxExtent,
              child: _expandedContent(),
            ),
          ),
        ),
        // La barra compacta solo existe cuando el encabezado de Inicio ya salió.
        if (fade > 0) _fading(opacity: fade, child: _compactContent()),
      ],
    );
  }

  // Capa con opacidad que no recibe toques cuando es invisible.
  Widget _fading({required double opacity, required Widget child}) {
    return IgnorePointer(
      ignoring: opacity <= 0.0,
      child: Opacity(opacity: opacity, child: child),
    );
  }

  Widget _yearSelector() {
    return MarketYearSelectorWidget(
      years: availableYears,
      year: year,
      onYearSelected: onYearSelected,
      tone: MarketSelectorTone.onLight,
    );
  }

  Widget _expandedContent() {
    return Padding(
      padding: const EdgeInsets.only(
        top: CatalogConfig.brandsHeaderTopPadding,
        bottom: AppSpacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sin selector: el del encabezado de Inicio sigue a la vista.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              AppTexts.brandsSectionTitle,
              style: AppTextStyles.sectionTitle,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          // A todo el ancho: los logos se desvanecen en los bordes de la pantalla.
          const BrandCarouselWidget(),
        ],
      ),
    );
  }

  Widget _compactContent() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        UiConfig.pageHorizontalPadding,
        topInset,
        UiConfig.pageHorizontalPadding,
        0,
      ),
      child: BrandCompactBarWidget(
        brandName: brandName,
        logo: BrandLogoWidget(
          brandName: brandName,
          size: UiConfig.headerCompactLogoSize,
        ),
        selector: _yearSelector(),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant BrandHeaderDelegate oldDelegate) {
    return year != oldDelegate.year ||
        !listEquals(availableYears, oldDelegate.availableYears) ||
        brandCount != oldDelegate.brandCount ||
        selectedIndex != oldDelegate.selectedIndex ||
        windowStart != oldDelegate.windowStart ||
        brandName != oldDelegate.brandName ||
        isRefreshing != oldDelegate.isRefreshing ||
        snapDuration != oldDelegate.snapDuration ||
        onYearSelected != oldDelegate.onYearSelected ||
        topInset != oldDelegate.topInset;
  }
}
