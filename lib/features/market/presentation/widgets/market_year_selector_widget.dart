import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/presentation/widgets/market_selector_tone.dart';
import 'package:cars_wheels_app/features/market/presentation/widgets/market_switch_widget.dart';
import 'package:cars_wheels_app/features/market/presentation/widgets/market_year_segment_widget.dart';

/// Píldora única y sutil: banderas, raya fina y año con su panel, en una fila.
class MarketYearSelectorWidget extends StatelessWidget {
  const MarketYearSelectorWidget({
    super.key,
    required this.onYearSelected,
    this.years = const [],
    this.year,
    this.tone = MarketSelectorTone.onDark,
  });

  /// Años del mercado activo, del más reciente al más antiguo.
  final List<int> years;

  /// Año activo; nulo mientras el catálogo recarga: solo se ven las banderas.
  final int? year;

  final ValueChanged<int> onYearSelected;

  /// Fondo donde se coloca: encabezado tinta o fondo blanco.
  final MarketSelectorTone tone;

  @override
  Widget build(BuildContext context) {
    final activeYear = year;
    final colors = MarketSelectorColors.of(tone);
    return Container(
      height: MarketConfig.selectorHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: MarketConfig.selectorInnerPadding,
      ),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: colors.border,
          width: MarketConfig.selectorBorderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          MarketSwitchWidget(tone: tone),
          if (activeYear != null && years.isNotEmpty) ...[
            const SizedBox(width: MarketConfig.dividerGap),
            Container(
              width: MarketConfig.dividerWidth,
              height: MarketConfig.dividerHeight,
              color: colors.divider,
            ),
            const SizedBox(width: MarketConfig.dividerGap),
            MarketYearSegmentWidget(
              years: years,
              year: activeYear,
              onYearSelected: onYearSelected,
              tone: tone,
            ),
          ],
        ],
      ),
    );
  }
}
