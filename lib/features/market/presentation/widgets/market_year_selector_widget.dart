import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/presentation/widgets/market_selector_layout.dart';
import 'package:cars_wheels_app/features/market/presentation/widgets/market_switch_widget.dart';
import 'package:cars_wheels_app/features/market/presentation/widgets/market_year_pill_widget.dart';

/// Interruptor de país y, aparte, la píldora del año; apilados o en fila.
class MarketYearSelectorWidget extends StatelessWidget {
  const MarketYearSelectorWidget({
    super.key,
    required this.onYearSelected,
    this.years = const [],
    this.year,
    this.onLight = false,
    this.layout = MarketSelectorLayout.stacked,
  });

  /// Sobre fondo claro (barra compacta): la píldora de año va en tinta.
  final bool onLight;

  /// Apilada (banderas arriba, año debajo) o en fila (barra compacta).
  final MarketSelectorLayout layout;

  /// Años del mercado activo, del más reciente al más antiguo.
  final List<int> years;

  /// Año activo; nulo mientras el catálogo recarga: solo se ve el interruptor.
  final int? year;

  final ValueChanged<int> onYearSelected;

  @override
  Widget build(BuildContext context) {
    final activeYear = year;
    final stacked = layout == MarketSelectorLayout.stacked;
    final gap = stacked
        ? const SizedBox(height: MarketConfig.stackedGap)
        : const SizedBox(width: MarketConfig.selectorGap);
    final children = [
      const MarketSwitchWidget(),
      if (activeYear != null && years.isNotEmpty) ...[
        gap,
        MarketYearPillWidget(
          years: years,
          year: activeYear,
          onYearSelected: onYearSelected,
          onLight: onLight,
        ),
      ],
    ];
    return stacked
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: children,
          )
        : Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
