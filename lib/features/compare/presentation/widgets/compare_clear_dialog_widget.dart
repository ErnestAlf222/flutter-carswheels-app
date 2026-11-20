import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Pide confirmar antes de vaciar la comparación; verdadero si se confirma.
Future<bool> showCompareClearDialog(BuildContext context, int count) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => CompareClearDialogWidget(count: count),
  );
  return confirmed ?? false;
}

/// Diálogo mínimo: título, cuántos vehículos se quitarán y dos acciones de texto.
class CompareClearDialogWidget extends StatelessWidget {
  const CompareClearDialogWidget({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: AppColors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.tile),
      ),
      title: Text(
        AppTexts.compareClearDialogTitle,
        style: AppTextStyles.sectionTitle,
      ),
      content: Text(
        AppTexts.compareClearDialogBody(count),
        style: AppTextStyles.body,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.mutedText,
            minimumSize: const Size(0, CompareConfig.removeTouchSize),
          ),
          child: Text(AppTexts.cancelLabel, style: AppTextStyles.bodyStrong),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.ink,
            minimumSize: const Size(0, CompareConfig.removeTouchSize),
          ),
          child: Text(
            AppTexts.compareClearLabel,
            style: AppTextStyles.bodyStrong,
          ),
        ),
      ],
    );
  }
}
