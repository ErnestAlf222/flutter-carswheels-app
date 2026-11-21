import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_band_style.dart';

/// Campo de búsqueda blanco y grande con lupa, botón para limpiar y acción "buscar".
class SearchFieldWidget extends StatelessWidget {
  const SearchFieldWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.palette,
    this.fadingText = false,
  });

  /// El texto se desvanece (justo antes de vaciar el campo con la "x").
  final bool fadingText;

  /// Sin paleta, el campo es blanco con sombra suave.
  final SearchFieldPalette? palette;

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: AppTexts.searchFieldSemanticLabel,
      child: Container(
        height: SearchConfig.fieldHeight,
        decoration: BoxDecoration(
          color: palette?.fill ?? AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.fromBorderSide(
            BorderSide(
              color: palette?.border ?? AppColors.outline,
              width: UiConfig.cardBorderWidth,
            ),
          ),
          boxShadow: palette == null ? AppShadows.soft : null,
        ),
        padding: const EdgeInsets.only(left: AppSpacing.m),
        child: Row(
          children: [
            Icon(
              Symbols.search,
              size: SearchConfig.fieldIconSize,
              color: palette?.icon ?? AppColors.ink,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: AnimatedOpacity(
                opacity: fadingText ? 0 : 1,
                duration: AppMotion.of(
                  AppMotion.fast,
                  reduced: MediaQuery.of(context).disableAnimations,
                ),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  textInputAction: TextInputAction.search,
                  style: AppTextStyles.body.copyWith(color: palette?.text),
                  cursorColor: palette?.text ?? AppColors.ink,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: AppTexts.searchFieldHint,
                    hintStyle: AppTextStyles.body.copyWith(
                      color: palette?.hint ?? AppColors.mutedText,
                    ),
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) => value.text.isEmpty
                  ? const SizedBox(width: AppSpacing.m)
                  : IconButton(
                      onPressed: onClear,
                      tooltip: AppTexts.searchClearSemanticLabel,
                      icon: Icon(
                        Symbols.close,
                        size: SearchConfig.fieldIconSize,
                        color: palette?.icon ?? AppColors.ink,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
