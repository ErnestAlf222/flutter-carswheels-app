import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_circle_button_widget.dart';

/// Barra fija inferior con el corazón y el botón de comparar.
class DetailBottomBarWidget extends StatelessWidget {
  const DetailBottomBarWidget({super.key, required this.onCompare});

  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(UiConfig.detailBottomBarInset),
        child: Row(
          children: [
            const DetailCircleButtonWidget(
              icon: Symbols.favorite,
              size: UiConfig.detailBottomBarHeight,
              iconSize: UiConfig.iconSize,
              semanticLabel: AppTexts.addToFavoritesLabel,
            ),
            const SizedBox(width: UiConfig.detailBottomBarGap),
            Expanded(
              child: GradientButton(
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
