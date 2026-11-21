import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/market/presentation/widgets/market_selector_tone.dart';

/// Segmento del año dentro de la píldora unida; abre el panel de años.
class MarketYearSegmentWidget extends StatefulWidget {
  const MarketYearSegmentWidget({
    super.key,
    required this.years,
    required this.year,
    required this.onYearSelected,
    this.tone = MarketSelectorTone.onDark,
  });

  /// Años del mercado activo, del más reciente al más antiguo.
  final List<int> years;

  /// Año activo.
  final int year;

  final ValueChanged<int> onYearSelected;

  /// Fondo donde se coloca: define el color del año y del chevron.
  final MarketSelectorTone tone;

  @override
  State<MarketYearSegmentWidget> createState() =>
      _MarketYearSegmentWidgetState();
}

class _MarketYearSegmentWidgetState extends State<MarketYearSegmentWidget> {
  // Recursos del framework y notificador del panel abierto (sin campos mutables).
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final ValueNotifier<bool> _open = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _open.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_open.value) {
      _close();
    } else {
      _open.value = true;
      _portal.show();
    }
  }

  void _close() {
    if (!_open.value) return;
    _open.value = false;
    _portal.hide();
  }

  void _pick(int year) {
    _close();
    widget.onYearSelected(year);
  }

  Duration _duration(BuildContext context) =>
      MediaQuery.of(context).disableAnimations
      ? Duration.zero
      : const Duration(milliseconds: AnimationConfig.yearPanelMilliseconds);

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        child: _YearZone(
          year: widget.year,
          open: _open,
          duration: _duration(context),
          onTap: _toggle,
          color: MarketSelectorColors.of(widget.tone).foreground,
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) => _close(),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _close,
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: CompositedTransformFollower(
              link: _link,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, MarketConfig.yearPanelGap),
              child: _YearPanel(
                years: widget.years,
                year: widget.year,
                duration: _duration(context),
                onPick: _pick,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Zona del año: el año activo y un chevron que gira al abrir el panel.
class _YearZone extends StatelessWidget {
  const _YearZone({
    required this.year,
    required this.open,
    required this.duration,
    required this.onTap,
    required this.color,
  });

  final int year;
  final ValueNotifier<bool> open;
  final Duration duration;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppTexts.pickYearLabel,
      value: year.toString(),
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: MarketConfig.yearTouchMinWidth,
            minHeight: MarketConfig.flagTouchSize,
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: MarketConfig.yearZoneHorizontalPadding,
              right: MarketConfig.yearZoneHorizontalPadding / 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  year.toString(),
                  style: AppTextStyles.bodyStrong.copyWith(color: color),
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: open,
                  builder: (context, isOpen, child) => AnimatedRotation(
                    turns: isOpen ? 0.5 : 0,
                    duration: duration,
                    child: child,
                  ),
                  child: Icon(
                    Symbols.keyboard_arrow_down,
                    size: MarketConfig.chevronSize,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Panel tinta con los años; el activo va en amarillo con texto tinta.
class _YearPanel extends StatelessWidget {
  const _YearPanel({
    required this.years,
    required this.year,
    required this.duration,
    required this.onPick,
  });

  final List<int> years;
  final int? year;
  final Duration duration;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadii.tile);
    final panel = Semantics(
      container: true,
      label: AppTexts.pickYearLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: AppShadows.soft,
        ),
        child: Material(
          color: AppColors.inkSoft,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: MarketConfig.yearPanelMaxHeight,
            ),
            child: SizedBox(
              width: MarketConfig.yearPanelWidth,
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(
                  MarketConfig.yearPanelVerticalPadding,
                ),
                itemCount: years.length,
                itemBuilder: (context, index) => _YearItem(
                  year: years[index],
                  active: years[index] == year,
                  onTap: () => onPick(years[index]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (duration == Duration.zero) return panel;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: duration,
      curve: AppMotion.enter,
      child: panel,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(
          scale:
              MarketConfig.yearPanelScaleBegin +
              (1 - MarketConfig.yearPanelScaleBegin) * t,
          alignment: Alignment.topRight,
          child: child,
        ),
      ),
    );
  }
}

/// Un año de la lista; el activo se rellena de amarillo.
class _YearItem extends StatelessWidget {
  const _YearItem({
    required this.year,
    required this.active,
    required this.onTap,
  });

  final int year;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(MarketConfig.yearPanelItemRadius);
    return Semantics(
      button: true,
      selected: active,
      label: year.toString(),
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: active ? AppColors.accent : Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Container(
            height: MarketConfig.yearPanelItemHeight,
            alignment: Alignment.center,
            child: Text(
              year.toString(),
              style: AppTextStyles.bodyStrong.copyWith(
                color: active ? AppColors.ink : AppColors.onDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
