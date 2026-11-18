import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/domain.dart';
import 'package:cars_wheels_app/features/vehicle_specs/presentation/cubits/cubits.dart';

/// Insignia de motorización: un ícono por tipo presente del grupo (máx. 3).
class EngineBadgeWidget extends StatelessWidget {
  const EngineBadgeWidget({
    super.key,
    required this.brand,
    required this.groupName,
    required this.year,
  });

  final String brand;
  final String groupName;
  final int year;

  @override
  Widget build(BuildContext context) {
    final key = context.read<SummariesCubit>().keyFor(brand, groupName, year);
    return BlocSelector<SummariesCubit, SummariesState, List<EngineKind>>(
      selector: (state) {
        final slot = state.slots[key];
        if (slot is! SummaryFound) return const [];
        return slot.summary.engineKinds
            .take(ModelGridConfig.maxEngineBadges)
            .toList();
      },
      builder: (context, kinds) {
        if (kinds.isEmpty) return const SizedBox.shrink();
        final labels = [
          for (final kind in kinds) ?AppTexts.engineKindLabels[kind.name],
        ];
        return Semantics(
          label: AppTexts.engineBadgeSemanticLabel(labels),
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int index = 0; index < kinds.length; index++) ...[
                if (index > 0) const SizedBox(width: ModelGridConfig.badgeGap),
                _BouncingIcon(kind: kinds[index]),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Círculo con el ícono del tipo; al aparecer salta una sola vez.
class _BouncingIcon extends StatelessWidget {
  const _BouncingIcon({required this.kind});

  final EngineKind kind;

  @override
  Widget build(BuildContext context) {
    final style = EngineKindStyles.forName(kind.name);
    final circle = Container(
      width: ModelGridConfig.badgeSize,
      height: ModelGridConfig.badgeSize,
      decoration: const BoxDecoration(
        color: AppColors.engineBadgeBackground,
        shape: BoxShape.circle,
        boxShadow: AppShadows.soft,
      ),
      child: Icon(
        style.icon,
        size: ModelGridConfig.badgeIconSize,
        color: style.color,
      ),
    );
    if (MediaQuery.of(context).disableAnimations) return circle;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(
        milliseconds: ModelGridConfig.badgeBounceMilliseconds,
      ),
      builder: (context, progress, child) => Transform.scale(
        // Sube y baja una sola vez: 1 → 1 + pico → 1.
        scale:
            1 + ModelGridConfig.badgeBouncePeak * math.sin(math.pi * progress),
        child: child,
      ),
      child: circle,
    );
  }
}
