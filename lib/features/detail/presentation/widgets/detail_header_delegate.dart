import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_circle_button_widget.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_photo_carousel_widget.dart';

/// Encabezado fijo de Detalle: la foto se contrae con parallax hasta una barra.
class DetailHeaderDelegate extends SliverPersistentHeaderDelegate {
  const DetailHeaderDelegate({
    required this.brandName,
    required this.groupName,
    required this.heroTag,
    required this.topInset,
  });

  final String brandName;
  final String groupName;

  /// Etiqueta del Hero desde la lista; nulo si no hay vuelo.
  final String? heroTag;

  /// Área segura superior de la pantalla.
  final double topInset;

  // Banda tinta (área segura + barra) y debajo la foto.
  double get _bandHeight => topInset + UiConfig.detailCollapsedBarHeight;

  @override
  double get maxExtent => _bandHeight + UiConfig.detailPhotoHeight;

  @override
  double get minExtent => _bandHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final titleOpacity =
        ((t - UiConfig.detailTitleFadeStart) /
                (1.0 - UiConfig.detailTitleFadeStart))
            .clamp(0.0, 1.0);
    const buttonTop =
        (UiConfig.detailCollapsedBarHeight - UiConfig.detailCircleButtonSize) /
        2;
    return Stack(
      fit: StackFit.expand,
      children: [
        // La foto queda bajo la banda; se contrae con parallax y esquinas abajo.
        Positioned.fill(
          top: _bandHeight,
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(HeaderConfig.bottomRadius),
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned(
                  top: -shrinkOffset * UiConfig.detailParallaxFactor,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    ignoring: t >= 1.0,
                    child: Opacity(
                      opacity: 1.0 - t,
                      child: DetailPhotoCarouselWidget(
                        brandName: brandName,
                        heroTag: heroTag,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Banda tinta sólida: es la barra fija al terminar de contraer.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: _bandHeight,
          child: const ColoredBox(color: AppColors.ink),
        ),
        Positioned(
          top: topInset,
          left:
              UiConfig.detailCircleButtonInset +
              UiConfig.detailCircleButtonSize +
              UiConfig.detailBarTitleGap,
          right: AppSpacing.m,
          height: UiConfig.detailCollapsedBarHeight,
          child: IgnorePointer(
            child: Opacity(
              opacity: titleOpacity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.onDarkCompactTitle,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: topInset + buttonTop,
          left: UiConfig.detailCircleButtonInset,
          child: DetailCircleButtonWidget(
            icon: Symbols.chevron_left,
            size: UiConfig.detailCircleButtonSize,
            iconSize: UiConfig.iconSize,
            semanticLabel: AppTexts.backLabel,
            onPhoto: true,
            onTap: () => context.pop(),
          ),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant DetailHeaderDelegate oldDelegate) {
    return brandName != oldDelegate.brandName ||
        groupName != oldDelegate.groupName ||
        heroTag != oldDelegate.heroTag ||
        topInset != oldDelegate.topInset;
  }
}
