import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Botón de la tarjeta en el selector: agrega al comparador o indica que ya está.
///
/// Con [isAdded] es una pastilla neutra deshabilitada; sin él, un botón amarillo.
class ComparePickerButtonWidget extends StatelessWidget {
  const ComparePickerButtonWidget({
    super.key,
    required this.vehicleName,
    required this.isAdded,
    this.onTap,
  });

  /// Nombre del vehículo, para la etiqueta accesible.
  final String vehicleName;
  final bool isAdded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // La fila de la tarjeta tiene alto fijo: la escala del texto se acota.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: CompareConfig.pickerButtonMaxTextScale,
      child: isAdded
          ? const _AddedPill()
          : _AddButton(name: vehicleName, onTap: onTap),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.name, required this.onTap});

  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.pill);
    return Semantics(
      button: true,
      label: AppTexts.comparePickerAddSemanticLabel(name),
      excludeSemantics: true,
      child: Material(
        color: AppColors.accent,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: SizedBox(
            height: CompareConfig.pickerButtonHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CompareConfig.pickerButtonHorizontalPadding,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Symbols.add,
                    size: CompareConfig.pickerButtonIconSize,
                    color: AppColors.ink,
                  ),
                  const SizedBox(width: CompareConfig.pickerButtonIconGap),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppTexts.comparePickerAddLabel,
                        maxLines: 1,
                        style: AppTextStyles.comparePickerButton,
                      ),
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

/// Pastilla neutra sin acción: el vehículo ya está en la comparación.
class _AddedPill extends StatelessWidget {
  const _AddedPill();

  @override
  Widget build(BuildContext context) {
    // Absorbe el toque: tocar la pastilla no abre Detalle ni hace nada.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: Semantics(
        label: AppTexts.comparePickerAddedLabel,
        excludeSemantics: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: const Border.fromBorderSide(
              BorderSide(
                color: AppColors.outline,
                width: CompareConfig.pickerButtonBorderWidth,
              ),
            ),
          ),
          child: SizedBox(
            height: CompareConfig.pickerButtonHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CompareConfig.pickerButtonHorizontalPadding,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Symbols.check,
                    size: CompareConfig.pickerButtonIconSize,
                    color: AppColors.mutedText,
                  ),
                  const SizedBox(width: CompareConfig.pickerButtonIconGap),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppTexts.comparePickerAddedLabel,
                        maxLines: 1,
                        style: AppTextStyles.comparePickerButton.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
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
