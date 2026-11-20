import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_grid_row_widget.dart';

/// Carga o error de cada columna, justo debajo de la banda de columnas.
///
/// Cada vehículo carga por su cuenta: el loader o el error ocupan solo su
/// columna y las demás no se mueven.
class CompareColumnStatusWidget extends StatelessWidget {
  const CompareColumnStatusWidget({
    super.key,
    required this.slots,
    required this.table,
    required this.onRetry,
  });

  final List<CompareSlotEntity> slots;
  final CompareTableState table;
  final ValueChanged<CompareSlotEntity> onRetry;

  /// Hay algo que mostrar: alguna columna carga o falló.
  static bool isNeeded(
    List<CompareSlotEntity> slots,
    CompareTableState table,
  ) => slots.any((slot) => table.of(slot) is! CompareColumnLoaded);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: CompareConfig.statusMinHeight,
      ),
      child: CompareGridRowWidget(
        crossAxisAlignment: CrossAxisAlignment.center,
        cellBuilder: (index) {
          if (index >= slots.length) return const SizedBox.shrink();
          final slot = slots[index];
          return switch (table.of(slot)) {
            CompareColumnLoading() => const Center(
              child: AppLoader(compact: true),
            ),
            CompareColumnFailed() => _Failed(onRetry: () => onRetry(slot)),
            CompareColumnLoaded() => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}

/// "No se pudo cargar" con la acción de texto para reintentar.
class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppTexts.compareColumnLoadFailed,
          textAlign: TextAlign.center,
          style: AppTextStyles.compareValue,
        ),
        const SizedBox(height: CompareConfig.statusMessageGap),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.ink,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            minimumSize: const Size(0, CompareConfig.removeTouchSize),
          ),
          child: Text(
            AppTexts.retryButtonLabel,
            style: AppTextStyles.bodyStrong,
          ),
        ),
      ],
    );
  }
}
