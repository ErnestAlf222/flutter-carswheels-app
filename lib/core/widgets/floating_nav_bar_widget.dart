import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';
import 'package:cars_wheels_app/core/widgets/floating_nav_item_model.dart';

/// Menú flotante de botones cuadrados que se oculta al desplazar.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelected,
    required this.visible,
  });

  final List<FloatingNavItemModel> items;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final bool still = MediaQuery.of(context).disableAnimations;
    final Duration moveDuration = still
        ? Duration.zero
        : const Duration(milliseconds: NavConfig.hideDurationMilliseconds);
    final Duration fadeDuration = still
        ? Duration.zero
        : const Duration(milliseconds: NavConfig.hideFadeMilliseconds);
    const Offset hiddenOffset = Offset(
      0,
      NavConfig.hideOffsetY / NavConfig.buttonSize,
    );
    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: fadeDuration,
        child: AnimatedSlide(
          offset: visible ? Offset.zero : hiddenOffset,
          duration: moveDuration,
          curve: AppCurves.reboundCurve,
          child: AnimatedScale(
            scale: visible ? 1.0 : NavConfig.hideScale,
            duration: moveDuration,
            curve: AppCurves.reboundCurve,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: NavConfig.buttonGap,
              children: [
                for (int i = 0; i < items.length; i++)
                  _NavButton(
                    item: items[i],
                    active: i == currentIndex,
                    onTap: () => onSelected(i),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final FloatingNavItemModel item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(AppRadii.navButton);
    return Semantics(
      button: true,
      selected: active,
      label: item.label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: active ? null : AppColors.card,
          gradient: active ? AppGradients.primary : null,
          borderRadius: radius,
          boxShadow: active ? AppShadows.accent : AppShadows.soft,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: SizedBox(
              width: NavConfig.buttonSize,
              height: NavConfig.buttonSize,
              child: Icon(
                item.icon,
                size: UiConfig.iconSize,
                fill: active ? 1.0 : 0.0,
                color: active ? AppColors.onGradient : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
