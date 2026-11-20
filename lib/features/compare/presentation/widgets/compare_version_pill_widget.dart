import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Pastilla con la versión actual de un vehículo; abre la hoja de versiones.
///
/// Etiqueta "Versión" arriba, el valor en una línea y un chevron en un círculo.
/// Mientras la hoja está abierta el borde pasa a tinta y el chevron se invierte.
class CompareVersionPillWidget extends StatefulWidget {
  const CompareVersionPillWidget({
    super.key,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    this.isLoading = false,
  });

  final String label;
  final String semanticLabel;

  /// Abre la hoja; la pastilla queda "abierta" hasta que la hoja se cierre.
  final Future<void> Function() onTap;

  /// Los datos de la versión aún cargan: el valor va atenuado.
  final bool isLoading;

  @override
  State<CompareVersionPillWidget> createState() =>
      _CompareVersionPillWidgetState();
}

class _CompareVersionPillWidgetState extends State<CompareVersionPillWidget> {
  // Único estado: si la hoja de esta pastilla está abierta.
  bool _isOpen = false;

  Future<void> _open() async {
    setState(() => _isOpen = true);
    await widget.onTap();
    if (mounted) setState(() => _isOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.pill);
    final value = widget.isLoading
        ? AppTexts.compareVersionPillLoadingValue
        : widget.label;
    return Semantics(
      button: true,
      label: widget.semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: _isOpen ? AppColors.ink : AppColors.outline,
            width: _isOpen
                ? CompareConfig.versionPillOpenBorderWidth
                : UiConfig.cardBorderWidth,
          ),
        ),
        child: InkWell(
          onTap: () => unawaited(_open()),
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: CompareConfig.removeTouchSize,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CompareConfig.versionPillHorizontalPadding,
                vertical: CompareConfig.versionPillVerticalPadding,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTexts.compareVersionPillOverline.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.compareVersionOverline,
                        ),
                        const SizedBox(
                          height: CompareConfig.versionPillOverlineGap,
                        ),
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: widget.isLoading
                              ? AppTextStyles.compareVersionPill.copyWith(
                                  color: AppColors.mutedText,
                                )
                              : AppTextStyles.compareVersionPill,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: CompareConfig.versionPillIconGap),
                  Container(
                    width: CompareConfig.versionPillCircleSize,
                    height: CompareConfig.versionPillCircleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isOpen ? AppColors.ink : AppColors.chipBackground,
                    ),
                    child: Icon(
                      _isOpen ? Symbols.expand_less : Symbols.expand_more,
                      size: CompareConfig.versionPillChevronSize,
                      color: _isOpen ? AppColors.onDark : AppColors.ink,
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
