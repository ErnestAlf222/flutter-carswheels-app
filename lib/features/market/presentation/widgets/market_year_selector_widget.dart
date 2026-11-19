import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/presentation/widgets/market_switch_widget.dart';
import 'package:cars_wheels_app/features/market/presentation/widgets/market_year_pill_widget.dart';

/// Interruptor de país y, aparte, la píldora del año: [MX US] [2025 v].
class MarketYearSelectorWidget extends StatelessWidget {
  const MarketYearSelectorWidget({
    super.key,
    required this.onYearSelected,
    this.years = const [],
    this.year,
    this.onLight = false,
  });

  /// Sobre fondo claro (barra compacta): la píldora de año va en tinta.
  final bool onLight;

  /// Años del mercado activo, del más reciente al más antiguo.
  final List<int> years;

  /// Año activo; nulo mientras el catálogo recarga: solo se ve el interruptor.
  final int? year;

  final ValueChanged<int> onYearSelected;

  @override
  Widget build(BuildContext context) {
    final activeYear = year;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MarketSwitchWidget(),
        if (activeYear != null && years.isNotEmpty) ...[
          const SizedBox(width: MarketConfig.selectorGap),
          MarketYearPillWidget(
            years: years,
            year: activeYear,
            onYearSelected: onYearSelected,
            onLight: onLight,
          ),
        ],
      ],
    );
  }
}
