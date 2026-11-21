import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Una fila de dato con su línea punteada debajo.
class DetailInfoRowWidget extends StatelessWidget {
  const DetailInfoRowWidget({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String? value;

  /// Ícono sutil a la izquierda del título; sin él la fila queda como siempre.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: UiConfig.detailInfoRowVerticalPadding,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: UiConfig.specRowIconSize,
                  color: AppColors.mutedText,
                ),
                const SizedBox(width: AppSpacing.s),
              ],
              icon == null
                  ? Text(label, style: AppTextStyles.infoLabel)
                  : Flexible(
                      child: Text(label, style: AppTextStyles.infoLabel),
                    ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Text(
                  value ?? AppTexts.noDataLabel,
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.infoValue,
                ),
              ),
            ],
          ),
        ),
        const DashedDividerWidget(),
      ],
    );
  }
}
