import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/brand_carousel_widget.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/year_selector_widget.dart';

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
    required this.onOlderYear,
    required this.onNewerYear,
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
  final VoidCallback onOlderYear;
  final VoidCallback onNewerYear;

  /// Necesario para animar el ajuste del encabezado flotante.
  @override
  final TickerProvider? vsync;

  @override
  double get maxExtent => UiConfig.headerExpandedHeight;

  @override
  double get minExtent => UiConfig.headerCompactHeight;

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
        _fading(opacity: fade, child: _compactContent()),
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
    final yearIndex = availableYears.indexOf(year);
    return YearSelectorWidget(
      year: year,
      canShowOlder: yearIndex < availableYears.length - 1,
      canShowNewer: yearIndex > 0,
      onOlder: onOlderYear,
      onNewer: onNewerYear,
    );
  }

  Widget _expandedContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.m,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppTexts.brandsSectionTitle,
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              _yearSelector(),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          const BrandCarouselWidget(),
        ],
      ),
    );
  }

  Widget _compactContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          BrandLogoWidget(
            brandName: brandName,
            size: UiConfig.headerCompactLogoSize,
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              brandName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.cardTitle,
            ),
          ),
          _yearSelector(),
        ],
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
        onOlderYear != oldDelegate.onOlderYear ||
        onNewerYear != oldDelegate.onNewerYear;
  }
}
