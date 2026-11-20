import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Botón flotante de filtros, apilado encima del de subir; va dentro de un Stack.
class SearchFilterButton extends StatefulWidget {
  const SearchFilterButton({
    super.key,
    required this.activeCount,
    required this.visible,
    required this.onTap,
  });

  /// Filtros activos; con alguno se muestra la insignia con el número.
  final int activeCount;

  /// Hay resultados en pantalla o filtros activos.
  final bool visible;
  final VoidCallback onTap;

  @override
  State<SearchFilterButton> createState() => _SearchFilterButtonState();
}

class _SearchFilterButtonState extends State<SearchFilterButton>
    with WidgetsBindingObserver {
  // Único estado: si el teclado está abierto (lo avisa el observador del framework).
  final ValueNotifier<bool> _keyboardOpen = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _readKeyboard();
  }

  @override
  void didChangeMetrics() => _readKeyboard();

  // La vista real: el Scaffold de la pantalla quita el teclado del MediaQuery.
  void _readKeyboard() {
    if (!mounted) return;
    _keyboardOpen.value = View.of(context).viewInsets.bottom > 0;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _keyboardOpen.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _keyboardOpen,
      builder: (context, keyboardOpen, _) =>
          _buildButton(context, keyboardOpen),
    );
  }

  Widget _buildButton(BuildContext context, bool keyboardOpen) {
    final shown = widget.visible && !keyboardOpen;
    final activeCount = widget.activeCount;
    final onTap = widget.onTap;
    final fade = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: ScrollConfig.topButtonFadeMilliseconds);
    return Positioned(
      right: ScrollConfig.topButtonRightMargin,
      // Encima del botón de subir: su base más su tamaño y la separación.
      bottom:
          NavConfig.footprint +
          MediaQuery.paddingOf(context).bottom +
          ScrollConfig.topButtonNavGap +
          ScrollConfig.topButtonSize +
          ScrollConfig.filterButtonStackGap,
      child: IgnorePointer(
        ignoring: !shown,
        child: AnimatedOpacity(
          key: const ValueKey('search-filter-button-fade'),
          opacity: shown ? 1.0 : 0.0,
          duration: fade,
          child: Semantics(
            button: true,
            label: AppTexts.searchFiltersButtonSemanticLabel(activeCount),
            excludeSemantics: true,
            onTap: onTap,
            child: GestureDetector(
              key: const ValueKey('search-filter-button'),
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: SizedBox(
                width: ScrollConfig.filterButtonSize,
                height: ScrollConfig.filterButtonSize,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.ink,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.soft,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Symbols.tune,
                        size: ScrollConfig.filterButtonIconSize,
                        color: AppColors.onDark,
                      ),
                    ),
                    if (activeCount > 0)
                      Positioned(
                        top: SearchConfig.filterBadgeTopOffset,
                        right: SearchConfig.filterBadgeRightOffset,
                        child: _Badge(count: activeCount),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cápsula amarilla con el número de filtros activos; entra con un golpe de escala.
class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: still ? 1.0 : SearchConfig.filterBadgeStartScale,
        end: 1.0,
      ),
      duration: still
          ? Duration.zero
          : const Duration(
              milliseconds: SearchConfig.filterBadgePopMilliseconds,
            ),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Container(
        key: const ValueKey('search-filter-badge'),
        constraints: const BoxConstraints(
          minWidth: SearchConfig.filterBadgeMinWidth,
          minHeight: SearchConfig.filterBadgeHeight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: SearchConfig.filterBadgeHorizontalPadding,
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
            color: AppColors.surface,
            width: SearchConfig.filterBadgeBorderWidth,
          ),
        ),
        child: Text(
          AppTexts.searchFilterNumberLabel(count),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
            fontSize: SearchConfig.filterBadgeFontSize,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}
