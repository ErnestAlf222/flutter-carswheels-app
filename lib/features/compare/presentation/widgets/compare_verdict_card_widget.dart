import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';

/// Tarjeta "¿quién ahorra más?": cambia con la métrica y usa solo datos reales.
///
/// Cada veredicto nuevo entra con fundido y un desplazamiento corto.
class CompareVerdictCardWidget extends StatelessWidget {
  const CompareVerdictCardWidget({
    super.key,
    required this.metric,
    required this.names,
    this.builder = const CompareVerdictBuilder(),
  });

  final CompareChartMetricEntity metric;

  /// Marca y modelo de cada vehículo, por su posición en la selección.
  final List<String> names;
  final CompareVerdictBuilder builder;

  @override
  Widget build(BuildContext context) {
    final verdict = builder.build(metric);
    if (verdict == null) return const SizedBox.shrink();
    final still = MediaQuery.of(context).disableAnimations;
    final switcher = AnimatedSwitcher(
      duration: AppMotion.of(AppMotion.medium, reduced: still),
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.enter,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, CompareConfig.verdictSlideOffset),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      child: _VerdictCard(
        key: ValueKey(verdict),
        verdict: verdict,
        names: names,
      ),
    );
    // AnimatedSize no admite duración cero: sin animaciones se omite.
    if (still) return switcher;
    return AnimatedSize(
      duration: AppMotion.medium,
      curve: AppMotion.enter,
      alignment: Alignment.topCenter,
      child: switcher,
    );
  }
}

class _VerdictCard extends StatelessWidget {
  const _VerdictCard({super.key, required this.verdict, required this.names});

  final CompareVerdictEntity verdict;
  final List<String> names;

  String _nameAt(int index) => index < names.length ? names[index] : '';

  // Frase como partes: lo normal y los nombres en negrita.
  List<(String, bool)> _parts() {
    switch (verdict.outcome) {
      case CompareVerdictOutcome.winner:
        final winner = _nameAt(verdict.leaders.single);
        final other = _nameAt(verdict.runnerUp!);
        return [
          (AppTexts.compareVerdictLead, false),
          (winner, true),
          (_winnerTail(other), false),
        ];
      case CompareVerdictOutcome.tie:
        return [
          (
            AppTexts.compareVerdictNames([
              for (final index in verdict.leaders) _nameAt(index),
            ]),
            true,
          ),
          (_tieTail(), false),
        ];
      case CompareVerdictOutcome.missingData:
        return [
          (_missingLead(), false),
          (
            AppTexts.compareVerdictNames([
              for (final index in verdict.missing) _nameAt(index),
            ]),
            true,
          ),
        ];
    }
  }

  String _winnerTail(String other) {
    final difference = verdict.difference!;
    final percent = verdict.percent;
    return switch (verdict.kind) {
      CompareRowKind.combinedConsumption =>
        AppTexts.compareVerdictConsumptionTail(
          AppTexts.kmPerLiterFigure(difference),
          percent,
          other,
        ),
      CompareRowKind.co2 => AppTexts.compareVerdictCo2Tail(
        difference.round().toString(),
        percent,
        other,
      ),
      CompareRowKind.annualCost => AppTexts.compareVerdictCostTail(
        AppTexts.annualCostLabel(difference.round()),
        percent,
        other,
      ),
      _ => AppTexts.compareVerdictSafetyTail(
        AppTexts.compareStarsValue(verdict.winnerValue!.round()),
        AppTexts.compareStarsValue(verdict.runnerUpValue!.round()),
        other,
      ),
    };
  }

  String _tieTail() => switch (verdict.kind) {
    CompareRowKind.combinedConsumption => AppTexts.compareVerdictConsumptionTie,
    CompareRowKind.co2 => AppTexts.compareVerdictCo2Tie,
    CompareRowKind.annualCost => AppTexts.compareVerdictCostTie,
    _ => AppTexts.compareVerdictSafetyTie,
  };

  String _missingLead() => switch (verdict.kind) {
    CompareRowKind.combinedConsumption =>
      AppTexts.compareVerdictConsumptionMissing,
    CompareRowKind.co2 => AppTexts.compareVerdictCo2Missing,
    CompareRowKind.annualCost => AppTexts.compareVerdictCostMissing,
    _ => AppTexts.compareVerdictSafetyMissing,
  };

  @override
  Widget build(BuildContext context) {
    final parts = _parts();
    final hasWinner = verdict.outcome == CompareVerdictOutcome.winner;
    return Semantics(
      container: true,
      label: parts.map((part) => part.$1).join(),
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(CompareConfig.verdictCardRadius),
          border: const Border.fromBorderSide(
            BorderSide(
              color: AppColors.outline,
              width: CompareConfig.verdictBorderWidth,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(CompareConfig.verdictCardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Medal(highlighted: hasWinner),
              const SizedBox(width: CompareConfig.verdictIconGap),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      for (final part in parts)
                        TextSpan(
                          text: part.$1,
                          style: part.$2
                              ? AppTextStyles.verdictName
                              : AppTextStyles.body,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Medalla: relleno amarillo con ícono tinta si hay ganador; neutra si no.
class _Medal extends StatelessWidget {
  const _Medal({required this.highlighted});

  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: CompareConfig.verdictMedalSize,
      height: CompareConfig.verdictMedalSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: highlighted ? AppColors.accent : AppColors.chipBackground,
      ),
      child: Icon(
        highlighted ? Symbols.emoji_events : Symbols.info,
        size: CompareConfig.verdictMedalIconSize,
        color: AppColors.ink,
      ),
    );
  }
}
