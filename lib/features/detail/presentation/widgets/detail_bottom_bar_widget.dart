import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_circle_button_widget.dart';

/// Barra de acciones de Detalle: tinta sólida con el corazón y comparar.
///
/// Cubre la parte lisa de la ola; la banda curva queda detrás del contenido.
class DetailBottomBarWidget extends StatelessWidget {
  const DetailBottomBarWidget({super.key, required this.onCompare});

  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return ColoredBox(
      color: AppColors.ink,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          UiConfig.detailBottomBarInset,
          UiConfig.detailBottomBarInset,
          UiConfig.detailBottomBarInset,
          UiConfig.detailBottomBarInset + safeBottom,
        ),
        child: Row(
          children: [
            const DetailCircleButtonWidget(
              icon: Symbols.favorite,
              size: UiConfig.detailBottomBarHeight,
              iconSize: UiConfig.iconSize,
              semanticLabel: AppTexts.addToFavoritesLabel,
              onDark: true,
            ),
            const SizedBox(width: UiConfig.detailBottomBarGap),
            Expanded(
              child: AccentButton(
                label: AppTexts.compareWithOtherLabel,
                onPressed: onCompare,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
