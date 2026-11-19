import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/config/config.dart';
import 'package:cars_wheels_app/core/l10n/app_texts.dart';
import 'package:cars_wheels_app/core/theme/theme.dart';

/// Botón circular traslúcido para volver al inicio; va dentro de un Stack a pantalla completa.
class ScrollToTopButton extends StatefulWidget {
  const ScrollToTopButton({super.key, required this.controller});

  final ScrollController controller;

  @override
  State<ScrollToTopButton> createState() => _ScrollToTopButtonState();
}

class _ScrollToTopButtonState extends State<ScrollToTopButton> {
  // Único estado: si el scroll pasó el umbral.
  final ValueNotifier<bool> _past = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_update);
    // Al restaurar la posición no hay notificación de scroll: se evalúa tras el primer cuadro.
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void didUpdateWidget(ScrollToTopButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_update);
    widget.controller.addListener(_update);
    _past.value = false;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_update);
    _past.dispose();
    super.dispose();
  }

  void _update() {
    if (!mounted) return;
    final controller = widget.controller;
    _past.value =
        controller.hasClients &&
        controller.offset > ScrollConfig.topButtonShowThreshold;
  }

  void _scrollToTop() {
    final controller = widget.controller;
    if (!controller.hasClients) return;
    if (MediaQuery.of(context).disableAnimations) {
      controller.jumpTo(0);
      return;
    }
    controller.animateTo(
      0,
      duration: const Duration(
        milliseconds: ScrollConfig.scrollToTopMilliseconds,
      ),
      curve: ScrollConfig.scrollToTopCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    // La vista real: el Scaffold de la pantalla quita el teclado del MediaQuery.
    final keyboardOpen = View.of(context).viewInsets.bottom > 0;
    final fade = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: ScrollConfig.topButtonFadeMilliseconds);
    return Positioned(
      right: ScrollConfig.topButtonRightMargin,
      bottom:
          NavConfig.footprint +
          MediaQuery.paddingOf(context).bottom +
          ScrollConfig.topButtonNavGap,
      child: ValueListenableBuilder<bool>(
        valueListenable: _past,
        builder: (context, past, _) {
          final visible = past && !keyboardOpen;
          return IgnorePointer(
            ignoring: !visible,
            child: AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: fade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hueco para apilar encima un botón flotante de filtros.
                  const SizedBox(
                    height: ScrollConfig.futureStackedButtonSlotHeight,
                  ),
                  Semantics(
                    button: true,
                    label: AppTexts.scrollToTopLabel,
                    excludeSemantics: true,
                    onTap: _scrollToTop,
                    child: GestureDetector(
                      key: const ValueKey('scroll-to-top-button'),
                      behavior: HitTestBehavior.opaque,
                      onTap: _scrollToTop,
                      child: Container(
                        width: ScrollConfig.topButtonSize,
                        height: ScrollConfig.topButtonSize,
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(
                            alpha: ScrollConfig.topButtonOpacity,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.mutedOnDark,
                            width: ScrollConfig.topButtonBorderWidth,
                          ),
                        ),
                        child: const Icon(
                          Symbols.arrow_upward,
                          size: ScrollConfig.topButtonIconSize,
                          color: AppColors.onDark,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
