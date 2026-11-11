import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';

/// Mensaje discreto en una fila con una acción de texto.
class InlineMessageWidget extends StatelessWidget {
  const InlineMessageWidget({
    super.key,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        Expanded(child: Text(message, style: AppTextStyles.caption)),
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.link,
            minimumSize: const Size(0, CarouselConfig.arrowTouchTargetSize),
          ),
          child: Text(
            actionLabel,
            style: AppTextStyles.caption.copyWith(color: AppColors.link),
          ),
        ),
      ],
    );
    if (MediaQuery.of(context).disableAnimations) return row;
    return FadeIn(
      duration: const Duration(
        milliseconds: AnimationConfig.fadeDurationMilliseconds,
      ),
      child: row,
    );
  }
}
