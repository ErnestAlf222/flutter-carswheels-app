import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/domain/entities/market_entity.dart';
import 'package:cars_wheels_app/features/market/presentation/cubits/cubits.dart';

/// Control segmentado compacto "EE. UU." | "México".
class MarketSelectorWidget extends StatelessWidget {
  const MarketSelectorWidget({super.key});

  /// Texto de cada mercado.
  static String labelOf(Market market) => switch (market) {
    Market.unitedStates => AppTexts.marketUnitedStatesLabel,
    Market.mexico => AppTexts.marketMexicoLabel,
  };

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: AnimationConfig.dimDurationMilliseconds);
    return BlocSelector<MarketCubit, MarketState, Market>(
      selector: (state) => state.market,
      builder: (context, current) => Semantics(
        container: true,
        label: AppTexts.marketSelectorSemanticLabel,
        child: Container(
          height: MarketConfig.selectorHeight,
          padding: const EdgeInsets.all(MarketConfig.selectorPadding),
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final market in Market.values)
                _Segment(
                  market: market,
                  selected: market == current,
                  duration: duration,
                  onTap: () => context.read<MarketCubit>().select(market),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un segmento: el activo se eleva sobre el fondo; el resto queda liso.
class _Segment extends StatelessWidget {
  const _Segment({
    required this.market,
    required this.selected,
    required this.duration,
    required this.onTap,
  });

  final Market market;
  final bool selected;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = MarketSelectorWidget.labelOf(market);
    return Semantics(
      button: true,
      selected: selected,
      label: AppTexts.marketOptionSemanticLabel(label),
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          constraints: const BoxConstraints(
            minWidth: MarketConfig.selectorSegmentMinWidth,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: MarketConfig.selectorSegmentHorizontalPadding,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.card : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            boxShadow: selected ? AppShadows.soft : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: selected ? AppColors.ink : AppColors.subtle,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
