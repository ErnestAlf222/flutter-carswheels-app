import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Aviso discreto del modo comparar: entra, se queda unos segundos y se pliega.
///
/// Se pliega solo, al cambiar [query], al hacer scroll el usuario o con la "x".
/// Una vez plegado no vuelve mientras el widget siga en el árbol.
class ComparePickerHintWidget extends StatefulWidget {
  const ComparePickerHintWidget({super.key, required this.query});

  /// Texto de búsqueda; cualquier cambio cuenta como que el usuario ya empezó.
  final String query;

  @override
  State<ComparePickerHintWidget> createState() =>
      _ComparePickerHintWidgetState();
}

class _ComparePickerHintWidgetState extends State<ComparePickerHintWidget> {
  // Recursos del framework y estado de visibilidad del aviso.
  Timer? _timer;
  ScrollPosition? _position;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(milliseconds: CompareConfig.pickerHintVisibleMilliseconds),
      _dismiss,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final position = Scrollable.maybeOf(context)?.position;
    if (identical(position, _position)) return;
    _position?.removeListener(_onScroll);
    _position = position?..addListener(_onScroll);
  }

  @override
  void didUpdateWidget(ComparePickerHintWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) _dismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _position?.removeListener(_onScroll);
    super.dispose();
  }

  // Solo el gesto del usuario pliega; restaurar la posición no cuenta.
  void _onScroll() {
    if (_position?.userScrollDirection != ScrollDirection.idle) _dismiss();
  }

  void _dismiss() {
    _timer?.cancel();
    if (!mounted || !_visible) return;
    setState(() => _visible = false);
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.of(context).disableAnimations;
    final content = _visible
        ? _Enter(
            still: still,
            child: _Hint(onClose: _dismiss),
          )
        : const SizedBox(width: double.infinity);
    // Sin animaciones aparece y desaparece de golpe, sin AnimatedSize.
    if (still) return content;
    return AnimatedSize(
      duration: const Duration(
        milliseconds: CompareConfig.pickerHintCollapseMilliseconds,
      ),
      curve: AppMotion.enter,
      alignment: Alignment.topCenter,
      child: content,
    );
  }
}

/// Entrada corta: fundido y desplazamiento leve desde arriba.
class _Enter extends StatelessWidget {
  const _Enter({required this.still, required this.child});

  final bool still;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (still) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(
        milliseconds: CompareConfig.pickerHintEnterMilliseconds,
      ),
      curve: AppMotion.enter,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: FractionalTranslation(
          translation: Offset(
            0,
            -CompareConfig.pickerHintSlideOffset * (1 - value),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        UiConfig.pageHorizontalPadding,
        AppSpacing.xs,
        UiConfig.pageHorizontalPadding,
        0,
      ),
      child: Semantics(
        liveRegion: true,
        container: true,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
            borderRadius: BorderRadius.circular(AppRadii.tile),
          ),
          child: Padding(
            padding: const EdgeInsets.only(
              left: CompareConfig.noticeHorizontalPadding,
              top: CompareConfig.noticeVerticalPadding / 2,
              bottom: CompareConfig.noticeVerticalPadding / 2,
            ),
            child: Row(
              children: [
                const Icon(
                  Symbols.info,
                  size: CompareConfig.noticeIconSize,
                  color: AppColors.ink,
                ),
                const SizedBox(width: CompareConfig.noticeIconGap),
                Expanded(
                  child: Text(
                    AppTexts.comparePickerHint,
                    style: AppTextStyles.caption.copyWith(color: AppColors.ink),
                  ),
                ),
                Semantics(
                  button: true,
                  label: AppTexts.comparePickerHintDismissSemanticLabel,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                    child: const SizedBox(
                      width: CompareConfig.pickerHintCloseSize,
                      height: CompareConfig.pickerHintCloseSize,
                      child: Icon(
                        Symbols.close,
                        size: CompareConfig.pickerHintCloseIconSize,
                        color: AppColors.ink,
                      ),
                    ),
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
