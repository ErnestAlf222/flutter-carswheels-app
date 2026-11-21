import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/domain/domain.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/detail_info_row_widget.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/spec_icon_mapper.dart';

/// Burbuja flotante de la ficha técnica y su panel con los datos de la versión.
///
/// Sin datos no dibuja nada. Se coloca sobre la barra inferior de Detalle; el
/// panel crece desde la burbuja y se cierra con toque fuera, con la X o
/// arrastrando hacia abajo.
class DetailSpecBubbleWidget extends StatefulWidget {
  const DetailSpecBubbleWidget({
    super.key,
    required this.entries,
    required this.subtitle,
  });

  /// Filas de la versión elegida; vacío oculta la burbuja.
  final List<SpecEntryEntity> entries;

  /// Nombre de la versión que se ve en el panel.
  final String subtitle;

  @override
  State<DetailSpecBubbleWidget> createState() => _DetailSpecBubbleWidgetState();
}

class _DetailSpecBubbleWidgetState extends State<DetailSpecBubbleWidget>
    with SingleTickerProviderStateMixin {
  // Recurso del framework: 0 es la burbuja cerrada y 1 el panel abierto.
  late final AnimationController _controller;

  // Arrastre vertical del panel y si el dedo sigue abajo.
  double _drag = 0;
  bool _dragging = false;

  bool get _hasData => widget.entries.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppMotion.medium);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : AppMotion.medium;
  }

  @override
  void didUpdateWidget(DetailSpecBubbleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Una versión sin datos cierra el panel junto con la burbuja.
    if (!_hasData && _controller.value > 0) _controller.value = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open() => _controller.forward();

  void _close() {
    setState(() => _drag = 0);
    _controller.reverse();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragging = true;
      _drag = (_drag + details.delta.dy).clamp(0.0, double.infinity);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final fast =
        (details.primaryVelocity ?? 0) > UiConfig.specDragCloseVelocity;
    _dragging = false;
    if (_drag > UiConfig.specDragCloseDistance || fast) {
      _close();
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasData) return const SizedBox.shrink();
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final bottom =
        UiConfig.detailBottomBarHeight +
        2 * UiConfig.detailBottomBarInset +
        safeBottom +
        UiConfig.specBubbleGap;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = AppMotion.enter.transform(_controller.value);
        final open = _controller.value > 0;
        return Stack(
          children: [
            if (open)
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _close,
                  child: ColoredBox(
                    color: AppColors.ink.withValues(
                      alpha: UiConfig.specScrimOpacity * progress,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: UiConfig.specBubbleRightMargin,
              bottom: bottom,
              child: IgnorePointer(
                ignoring: open,
                child: Opacity(opacity: 1 - progress, child: _bubble()),
              ),
            ),
            if (open)
              Positioned(
                right: UiConfig.specBubbleRightMargin,
                left: UiConfig.specBubbleRightMargin,
                bottom: bottom,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Opacity(
                    opacity: progress,
                    child: Transform.scale(
                      alignment: Alignment.bottomRight,
                      scale:
                          UiConfig.specPanelStartScale +
                          (1 - UiConfig.specPanelStartScale) * progress,
                      child: _panel(context),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Círculo de tinta con el ícono amarillo; no es un botón principal.
  Widget _bubble() {
    return Semantics(
      button: true,
      label: AppTexts.specSheetOpenLabel,
      excludeSemantics: true,
      onTap: _open,
      child: GestureDetector(
        onTap: _open,
        child: Container(
          width: UiConfig.specBubbleSize,
          height: UiConfig.specBubbleSize,
          decoration: const BoxDecoration(
            color: AppColors.ink,
            shape: BoxShape.circle,
            boxShadow: AppShadows.navBar,
          ),
          child: const Icon(
            Symbols.list_alt,
            size: UiConfig.specBubbleIconSize,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }

  // Filas con el título de su sección; solo hay secciones con datos.
  List<Widget> _rows() {
    return [
      for (final (index, entry) in widget.entries.indexed) ...[
        if (index == 0 || widget.entries[index - 1].section != entry.section)
          Padding(
            padding: EdgeInsets.only(
              top: index == 0
                  ? UiConfig.specSectionTopGap / 2
                  : UiConfig.specSectionTopGap,
            ),
            child: Semantics(
              header: true,
              child: Text(
                SpecIconMapper.titleFor(entry.section),
                style: AppTextStyles.specSectionTitle,
              ),
            ),
          ),
        DetailInfoRowWidget(
          label: entry.label,
          value: entry.value,
          icon: SpecIconMapper.iconFor(entry),
        ),
      ],
    ];
  }

  Widget _panel(BuildContext context) {
    final maxHeight =
        MediaQuery.sizeOf(context).height * UiConfig.specPanelMaxHeightFraction;
    return GestureDetector(
      onVerticalDragUpdate: _onDragUpdate,
      onVerticalDragEnd: _onDragEnd,
      child: AnimatedContainer(
        duration: _dragging ? Duration.zero : AppMotion.fast,
        curve: AppMotion.enter,
        transform: Matrix4.translationValues(0, _drag, 0),
        constraints: BoxConstraints(
          maxWidth: UiConfig.specPanelMaxWidth,
          maxHeight: maxHeight,
        ),
        padding: const EdgeInsets.all(UiConfig.specPanelPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(UiConfig.specPanelRadius),
          border: Border.all(
            color: AppColors.outline,
            width: UiConfig.detailCardBorderWidth,
          ),
          boxShadow: AppShadows.soft,
        ),
        child: Semantics(
          container: true,
          label: AppTexts.specSheetTitle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTexts.specSheetTitle,
                          style: AppTextStyles.cardTitle,
                        ),
                        if (widget.subtitle.isNotEmpty)
                          Text(
                            widget.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.caption,
                          ),
                      ],
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: AppTexts.specSheetCloseLabel,
                    excludeSemantics: true,
                    onTap: _close,
                    child: IconButton(
                      onPressed: _close,
                      constraints: const BoxConstraints(
                        minWidth: UiConfig.specCloseButtonSize,
                        minHeight: UiConfig.specCloseButtonSize,
                      ),
                      icon: const Icon(
                        Symbols.close,
                        size: UiConfig.iconSize,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _rows(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
