import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_band_style.dart';
import 'package:cars_wheels_app/features/search/presentation/widgets/search_field_widget.dart';

/// Encabezado compacto de la búsqueda dentro de una hoja: asa, título con
/// cierre y el campo fijo. Sin selector de mercado ni año.
class SearchCompactHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SearchCompactHeaderDelegate({
    required this.title,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    this.fadingText = false,
    this.onClose,
    this.style,
  });

  final String title;

  /// Con valor, la banda cambia de identidad (color, campo y contador).
  final SearchBandStyle? style;

  /// Con valor, muestra el botón de cerrar junto al título.
  final VoidCallback? onClose;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  /// El texto del campo se desvanece antes de vaciarse.
  final bool fadingText;

  // Alto fijo: asa, título, campo y sus separaciones.
  static const double extent =
      SearchConfig.compactHeaderTopPadding +
      UiConfig.detailSheetHandleHeight +
      SearchConfig.compactHeaderGap +
      SearchConfig.headerTitleRowHeight +
      SearchConfig.compactHeaderGap +
      SearchConfig.fieldHeight +
      SearchConfig.compactHeaderBottomPadding;

  // Con contador, la banda crece una línea.
  double get _extent => style?.counter == null
      ? extent
      : extent +
            SearchConfig.compactCounterRowHeight +
            SearchConfig.compactHeaderGap / 2;

  @override
  double get maxExtent => _extent;

  @override
  double get minExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final counter = style?.counter;
    final band = SizedBox(
      height: _extent,
      child: HeroHeaderWidget(
        color: style?.color ?? AppColors.ink,
        padding: const EdgeInsets.only(
          top: SearchConfig.compactHeaderTopPadding,
          bottom: SearchConfig.compactHeaderBottomPadding,
        ),
        child: Column(
          children: [
            Container(
              width: UiConfig.detailSheetHandleWidth,
              height: UiConfig.detailSheetHandleHeight,
              decoration: BoxDecoration(
                color: AppColors.mutedOnDark,
                borderRadius: BorderRadius.circular(
                  UiConfig.detailSheetHandleHeight,
                ),
              ),
            ),
            const SizedBox(height: SearchConfig.compactHeaderGap),
            SizedBox(
              height: SearchConfig.headerTitleRowHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: UiConfig.pageHorizontalPadding,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          maxLines: 1,
                          style: AppTextStyles.onDarkScreenTitle,
                        ),
                      ),
                    ),
                    if (onClose != null) _CloseButton(onTap: onClose!),
                  ],
                ),
              ),
            ),
            if (counter != null)
              SizedBox(
                height:
                    SearchConfig.compactCounterRowHeight +
                    SearchConfig.compactHeaderGap / 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UiConfig.pageHorizontalPadding,
                    ),
                    child: FittedBox(fit: BoxFit.scaleDown, child: counter),
                  ),
                ),
              ),
            const SizedBox(height: SearchConfig.compactHeaderGap),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: UiConfig.pageHorizontalPadding,
              ),
              child: SearchFieldWidget(
                palette: style?.field,
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                onClear: onClear,
                fadingText: fadingText,
              ),
            ),
          ],
        ),
      ),
    );
    // Íconos claros de la barra de estado sobre la banda tinta.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.lightStatusBar,
      child: band,
    );
  }

  // onSubmitted se omite: llega como cierre nuevo en cada build y hace lo mismo.
  @override
  bool shouldRebuild(SearchCompactHeaderDelegate oldDelegate) =>
      title != oldDelegate.title ||
      style != oldDelegate.style ||
      onClose != oldDelegate.onClose ||
      controller != oldDelegate.controller ||
      focusNode != oldDelegate.focusNode ||
      onChanged != oldDelegate.onChanged ||
      fadingText != oldDelegate.fadingText ||
      onClear != oldDelegate.onClear;
}

/// Botón circular de cerrar sobre la banda tinta.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppTexts.comparePickerCloseSemanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: SearchConfig.headerBackButtonSize,
          height: SearchConfig.headerBackButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.onDark.withValues(
              alpha: SearchConfig.headerBackButtonFillOpacity,
            ),
          ),
          child: const Icon(
            Symbols.close,
            size: UiConfig.iconSize,
            color: AppColors.onDark,
          ),
        ),
      ),
    );
  }
}
