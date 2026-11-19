import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/domain/entities/market_entity.dart';
import 'package:cars_wheels_app/features/market/presentation/cubits/cubits.dart';

/// Segmento de banderas: dos banderas siempre visibles y un disco amarillo que se desliza.
class MarketSwitchWidget extends StatelessWidget {
  const MarketSwitchWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final order = [
      for (final code in MarketConfig.switchOrderCodes) ?Market.fromCode(code),
    ];
    final duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(
            milliseconds: AnimationConfig.marketSwitchMilliseconds,
          );
    return BlocSelector<MarketCubit, MarketState, Market>(
      selector: (state) => state.market,
      builder: (context, active) {
        const slot = MarketConfig.flagTouchSize;
        const stride = slot + MarketConfig.flagGap;
        final activeIndex = order.indexOf(active);
        return SizedBox(
          width:
              slot * order.length + MarketConfig.flagGap * (order.length - 1),
          height: slot,
          child: Stack(
            children: [
              AnimatedPositioned(
                key: const ValueKey('market-switch-disc'),
                duration: duration,
                curve: Curves.easeOut,
                left:
                    stride * activeIndex +
                    (slot - MarketConfig.flagDiscSize) / 2,
                top: (slot - MarketConfig.flagDiscSize) / 2,
                child: Container(
                  width: MarketConfig.flagDiscSize,
                  height: MarketConfig.flagDiscSize,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Row(
                children: [
                  for (final (index, market) in order.indexed) ...[
                    if (index > 0) const SizedBox(width: MarketConfig.flagGap),
                    _FlagSlot(
                      market: market,
                      active: market == active,
                      duration: duration,
                      onTap: () => context.read<MarketCubit>().select(market),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Una posición del interruptor; solo la inactiva responde al toque.
class _FlagSlot extends StatelessWidget {
  const _FlagSlot({
    required this.market,
    required this.active,
    required this.duration,
    required this.onTap,
  });

  final Market market;
  final bool active;
  final Duration duration;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMexico = market == Market.mexico;
    return Semantics(
      button: true,
      selected: active,
      label: isMexico
          ? AppTexts.marketMexicoName
          : AppTexts.marketUnitedStatesName,
      hint: active
          ? null
          : (isMexico
                ? AppTexts.switchToMexicoLabel
                : AppTexts.switchToUnitedStatesLabel),
      excludeSemantics: true,
      onTap: active ? null : onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: active ? null : onTap,
        child: SizedBox(
          width: MarketConfig.flagTouchSize,
          height: MarketConfig.flagTouchSize,
          child: Center(
            child: AnimatedOpacity(
              opacity: active ? 1.0 : MarketConfig.inactiveFlagOpacity,
              duration: duration,
              child: Text(
                market.flag,
                style: const TextStyle(fontSize: MarketConfig.flagFontSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
