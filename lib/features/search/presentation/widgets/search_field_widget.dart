import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Campo de búsqueda blanco y grande con lupa, botón para limpiar y acción "buscar".
class SearchFieldWidget extends StatelessWidget {
  const SearchFieldWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: const Border.fromBorderSide(
            BorderSide(
              color: AppColors.outline,
              width: UiConfig.cardBorderWidth,
            ),
          ),
          boxShadow: AppShadows.soft,
        ),
        padding: const EdgeInsets.only(left: AppSpacing.m),
        child: Row(
          children: [
            const Icon(
              Symbols.search,
              size: SearchConfig.fieldIconSize,
              color: AppColors.ink,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                style: AppTextStyles.body,
                cursorColor: AppColors.ink,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: AppTexts.searchFieldHint,
                  hintStyle: AppTextStyles.body.copyWith(
                    color: AppColors.mutedText,
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
                      icon: const Icon(
                        Symbols.close,
                        size: SearchConfig.fieldIconSize,
                        color: AppColors.ink,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
