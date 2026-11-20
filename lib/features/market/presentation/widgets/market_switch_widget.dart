import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/domain/entities/market_entity.dart';
import 'package:cars_wheels_app/features/market/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/market/presentation/widgets/market_selector_tone.dart';

/// Segmento de banderas: dos insignias a color y un aro fino que se desliza.
class MarketSwitchWidget extends StatelessWidget {
  const MarketSwitchWidget({super.key, this.tone = MarketSelectorTone.onDark});

  final MarketSelectorTone tone;

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
    final colors = MarketSelectorColors.of(tone);
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
                key: const ValueKey('market-switch-ring'),
                duration: duration,
                curve: Curves.easeOut,
                left:
                    stride * activeIndex +
                    (slot - MarketConfig.flagRingSize) / 2,
                top: (slot - MarketConfig.flagRingSize) / 2,
                child: Container(
                  width: MarketConfig.flagRingSize,
                  height: MarketConfig.flagRingSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.ring,
                      width: MarketConfig.flagRingWidth,
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
                      borderColor: colors.flagBorder,
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
    required this.borderColor,
    required this.onTap,
  });

  final Market market;
  final bool active;
  final Duration duration;
  final Color borderColor;
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
              child: _FlagBadge(flag: market.flag, borderColor: borderColor),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bandera recortada en círculo con un borde finísimo, como una insignia.
class _FlagBadge extends StatelessWidget {
  const _FlagBadge({required this.flag, required this.borderColor});

  final String flag;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MarketConfig.flagBadgeSize,
      height: MarketConfig.flagBadgeSize,
      // El borde va por encima del recorte para no achicar la insignia.
      foregroundDecoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
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
