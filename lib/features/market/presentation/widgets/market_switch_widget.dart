import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/domain/entities/market_entity.dart';
import 'package:cars_wheels_app/features/market/presentation/cubits/cubits.dart';
import 'package:cars_wheels_app/features/market/presentation/widgets/market_selector_tone.dart';

/// Control segmentado de mercado: bandera y código, con una pastilla que se desliza.
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
        : AppMotion.medium;
    final colors = MarketSelectorColors.of(tone);
    // Una opción mide lo que su contenido: así el control no ocupa de más.
    final scaler = MediaQuery.textScalerOf(context)
        .clamp(maxScaleFactor: MarketConfig.codeMaxTextScale);
    final widths = [for (final market in order) _optionWidth(market, scaler)];
    return BlocSelector<MarketCubit, MarketState, Market>(
      selector: (state) => state.market,
      builder: (context, active) {
        final activeIndex = order.indexOf(active);
        final pillLeft = widths
            .take(activeIndex)
            .fold<double>(0, (sum, w) => sum + w);
        return SizedBox(
          width: widths.fold<double>(0, (sum, width) => sum + width),
          height: MarketConfig.flagTouchSize,
          child: Stack(
            children: [
              AnimatedPositioned(
                key: const ValueKey('market-switch-pill'),
                duration: duration,
                curve: AppMotion.change,
                left: pillLeft,
                width: widths[activeIndex],
                top: 0,
                bottom: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: MarketConfig.pillInsetVertical,
                    horizontal: MarketConfig.pillInsetHorizontal,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.pill,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  for (final (index, market) in order.indexed)
                    SizedBox(
                      width: widths[index],
                      child: _MarketOption(
                        market: market,
                        active: market == active,
                        duration: duration,
                        colors: colors,
                        scaler: scaler,
                        onTap: () => context.read<MarketCubit>().select(market),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Ancho de la opción: relleno, bandera, hueco y el código medido con su estilo.
  double _optionWidth(Market market, TextScaler scaler) {
    final painter = TextPainter(
      text: TextSpan(
        text: AppTexts.marketCodeLabelOf(market.code),
        style: AppTextStyles.marketCode,
      ),
      textDirection: TextDirection.ltr,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    final text = painter.width.ceilToDouble();
    painter.dispose();
    final content =
        2 * MarketConfig.optionHorizontalPadding +
        MarketConfig.flagBadgeSize +
        MarketConfig.optionFlagGap +
        text;
    return content < MarketConfig.flagTouchSize
        ? MarketConfig.flagTouchSize
        : content;
  }
}

/// Una opción del control; solo la inactiva responde al toque.
class _MarketOption extends StatelessWidget {
  const _MarketOption({
    required this.market,
    required this.active,
    required this.duration,
    required this.colors,
    required this.scaler,
    required this.onTap,
  });

  final Market market;
  final bool active;
  final Duration duration;
  final MarketSelectorColors colors;
  final TextScaler scaler;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMexico = market == Market.mexico;
    final code = market.code;
    return Semantics(
      button: true,
      selected: active,
      label: AppTexts.marketOptionSemanticLabel(code, selected: active),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: MarketConfig.flagTouchSize,
            minHeight: MarketConfig.flagTouchSize,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: MarketConfig.optionHorizontalPadding,
            ),
            // Si la tipografía mide distinto a lo calculado, se ajusta sin desbordar.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _FlagBadge(flag: market.flag, borderColor: colors.flagBorder),
                  const SizedBox(width: MarketConfig.optionFlagGap),
                  AnimatedDefaultTextStyle(
                    duration: duration,
                    curve: AppMotion.change,
                    style: AppTextStyles.marketCode.copyWith(
                      color: active ? colors.activeText : colors.inactiveText,
                    ),
                    child: Text(
                      AppTexts.marketCodeLabelOf(code),
                      maxLines: 1,
                      softWrap: false,
                      // Control compacto: el código crece poco con la escala de texto.
                      textScaler: MediaQuery.textScalerOf(context)
                          .clamp(maxScaleFactor: MarketConfig.codeMaxTextScale),
                    ),
                  ),
                ],
              ),
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
            textScaler: TextScaler.noScaling,
            style: const TextStyle(fontSize: MarketConfig.flagFontSize),
          ),
        ),
      ),
    );
  }
}
