import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_grid_row_widget.dart';
import 'package:cars_wheels_app/features/compare/presentation/widgets/compare_slot_metrics.dart';

/// Banda fija con marca y modelo de cada columna, para saber cuál es cuál.
///
/// Mientras la tabla se desplaza queda pegada arriba, bajo el área segura.
class CompareTableBandDelegate extends SliverPersistentHeaderDelegate {
  const CompareTableBandDelegate({
    required this.slots,
    required this.topInset,
    required this.textScaler,
  });

  final List<CompareSlotEntity> slots;

  /// Área segura superior, ya medida por la pantalla.
  final double topInset;
  final TextScaler textScaler;

  double get _extent => CompareSlotMetrics.bandHeight(textScaler, topInset);

  @override
  double get maxExtent => _extent;

  @override
  double get minExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // El sliver da solo un tope de alto: se fija el alto exacto de la banda.
    return SizedBox(
      height: _extent,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(
            bottom: BorderSide(
              color: AppColors.outline,
              width: CompareConfig.bandBorderWidth,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            UiConfig.pageHorizontalPadding,
            topInset + CompareConfig.bandVerticalPadding,
            UiConfig.pageHorizontalPadding,
            CompareConfig.bandVerticalPadding,
          ),
          child: CompareGridRowWidget(
            cellBuilder: (index) {
              if (index >= slots.length) return const SizedBox.shrink();
              final slot = slots[index];
              final name = AppTexts.compareColumnHeaderLabel(
                slot.brand,
                slot.modelName,
              );
              return Semantics(
                label: name,
                excludeSemantics: true,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.compareBandName,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(CompareTableBandDelegate oldDelegate) =>
      slots != oldDelegate.slots ||
      topInset != oldDelegate.topInset ||
      textScaler != oldDelegate.textScaler;
}
