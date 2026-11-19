import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/domain/entities/market_entity.dart';
import 'package:cars_wheels_app/features/market/presentation/cubits/cubits.dart';

/// Segmento de banderas: dos insignias siempre visibles y un disco tenue que se desliza.
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
                  decoration: BoxDecoration(
                    color: AppColors.onDark.withValues(
                      alpha: MarketConfig.flagDiscOpacity,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.onDark.withValues(
                        alpha: MarketConfig.flagDiscRingOpacity,
                      ),
                      width: MarketConfig.flagDiscRingWidth,
                    ),
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
              child: _FlagBadge(flag: market.flag),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bandera recortada en círculo con un borde finísimo, como una insignia.
class _FlagBadge extends StatelessWidget {
  const _FlagBadge({required this.flag});

  final String flag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MarketConfig.flagBadgeSize,
      height: MarketConfig.flagBadgeSize,
      // El borde va por encima del recorte para no achicar la insignia.
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.onDark.withValues(
            alpha: MarketConfig.flagBadgeBorderOpacity,
          ),
          width: MarketConfig.flagBadgeBorderWidth,
        ),
      ),
      child: ClipOval(
        child: OverflowBox(
          maxWidth: double.infinity,
          maxHeight: double.infinity,
          child: Text(
            flag,
            softWrap: false,
            overflow: TextOverflow.visible,
            style: const TextStyle(fontSize: MarketConfig.flagFontSize),
          ),
        ),
      ),
    );
  }
}
