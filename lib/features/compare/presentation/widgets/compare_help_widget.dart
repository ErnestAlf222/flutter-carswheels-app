import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Ayuda con menos de 2 vehículos: texto y el botón principal de la pantalla.
class CompareHelpWidget extends StatelessWidget {
  const CompareHelpWidget({
    super.key,
    required this.isEmpty,
    required this.onAdd,
  });

  /// Sin ningún vehículo se muestra el estado vacío completo.
  final bool isEmpty;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isEmpty) ...[
          Container(
            width: CompareConfig.emptyIconDisc,
            height: CompareConfig.emptyIconDisc,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.chipBackground,
            ),
            child: const Icon(
              Symbols.compare_arrows,
              size: CompareConfig.emptyIconSize,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            AppTexts.compareEmptyTitle(CompareConfig.maxSlots),
            textAlign: TextAlign.center,
            style: AppTextStyles.cardTitle,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Text(
          isEmpty ? AppTexts.compareEmptyBody : AppTexts.compareOneVehicleBody,
          textAlign: TextAlign.center,
          style: AppTextStyles.infoLabel,
        ),
        const SizedBox(height: CompareConfig.helpButtonGap),
        SizedBox(
          width: double.infinity,
          child: AccentButton(
            label: AppTexts.compareAddVehicleLabel,
            onPressed: onAdd,
          ),
        ),
      ],
    );
  }
}
