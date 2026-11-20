import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_sheet_frame_widget.dart';

/// Abre la hoja con los pasos para usar el comparador.
Future<void> showCompareHelpSheet(BuildContext context) =>
    showCompareSheet<void>(
      context,
      builder: (_) => const CompareHelpSheetWidget(),
    );

/// Cuatro pasos cortos y numerados, y una nota sobre "Limpiar".
class CompareHelpSheetWidget extends StatelessWidget {
  const CompareHelpSheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CompareSheetFrameWidget(
      title: AppTexts.compareHelpSheetTitle,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.xs,
          AppSpacing.l,
          AppSpacing.xl + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (index, step) in AppTexts.compareHelpSteps.indexed) ...[
              if (index > 0) const SizedBox(height: CompareConfig.helpStepGap),
              _Step(number: index + 1, text: step),
            ],
            const SizedBox(height: AppSpacing.m),
            Text(AppTexts.compareHelpFootnote, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

/// Un paso: número en círculo neutro y su texto.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: CompareConfig.helpStepCircleSize,
          height: CompareConfig.helpStepCircleSize,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.chipBackground,
          ),
          child: Text(
            AppTexts.compareHelpStepNumber(number),
            style: AppTextStyles.compareHelpStepNumber,
          ),
        ),
        const SizedBox(width: CompareConfig.helpStepGap),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs / 2),
            child: Text(text, style: AppTextStyles.body),
          ),
        ),
      ],
    );
  }
}
