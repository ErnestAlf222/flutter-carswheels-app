import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Botón flotante circular de la gráfica; va dentro de un Stack.
///
/// Usa la misma huella que los botones flotantes de Buscar y se oculta mientras
/// el teclado está abierto.
class CompareChartButtonWidget extends StatelessWidget {
  const CompareChartButtonWidget({
    super.key,
    required this.visible,
    required this.keyboardOpen,
    required this.onTap,
  });

  /// Hay al menos una métrica con datos en 2 o más vehículos.
  final bool visible;
  final bool keyboardOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final shown = visible && !keyboardOpen;
    final fade = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: ScrollConfig.topButtonFadeMilliseconds);
    return Positioned(
      right: ScrollConfig.topButtonRightMargin,
      bottom:
          NavConfig.footprint +
          MediaQuery.paddingOf(context).bottom +
          ScrollConfig.topButtonNavGap,
      child: IgnorePointer(
        ignoring: !shown,
        child: AnimatedOpacity(
          opacity: shown ? 1.0 : 0.0,
          duration: fade,
          child: Semantics(
            button: true,
            label: AppTexts.compareChartButtonSemanticLabel,
            excludeSemantics: true,
            onTap: onTap,
            child: GestureDetector(
              key: const ValueKey('compare-chart-button'),
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Container(
                width: CompareConfig.chartButtonSize,
                height: CompareConfig.chartButtonSize,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.ink,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.soft,
                ),
                child: const Icon(
                  Symbols.bar_chart,
                  size: CompareConfig.chartButtonIconSize,
                  color: AppColors.onDark,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
