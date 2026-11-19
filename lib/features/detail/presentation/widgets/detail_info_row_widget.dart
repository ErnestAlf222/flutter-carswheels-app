import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Una fila de dato con su línea punteada debajo.
class DetailInfoRowWidget extends StatelessWidget {
  const DetailInfoRowWidget({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

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
              Text(label, style: AppTextStyles.infoLabel),
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
