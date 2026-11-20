import 'package:flutter/widgets.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/domain/domain.dart';

/// Entrega el nombre legible de la versión de un espacio a su [builder].
///
/// Sin versión elegida es "Predeterminada" al instante. Con una, muestra "—"
/// mientras se resuelve; si no se puede resolver, queda el nombre guardado.
class CompareVersionLabelBuilder extends StatefulWidget {
  const CompareVersionLabelBuilder({
    super.key,
    required this.slot,
    required this.labeler,
    required this.builder,
  });

  final CompareSlotEntity slot;
  final CompareVersionLabeler labeler;
  final Widget Function(BuildContext context, String label) builder;

  @override
  State<CompareVersionLabelBuilder> createState() =>
      _CompareVersionLabelBuilderState();
}

class _CompareVersionLabelBuilderState
    extends State<CompareVersionLabelBuilder> {
  // Etiqueta resuelta para la versión actual; nula mientras se espera.
  String? _label;

  @override
  void initState() {
    super.initState();
    _resolve();
  }

  @override
  void didUpdateWidget(CompareVersionLabelBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slot.identity != widget.slot.identity) {
      _label = null;
      _resolve();
    }
  }

  Future<void> _resolve() async {
    final slot = widget.slot;
    final key = slot.versionKey;
    if (key == null) return;
    String label;
    try {
      label = await widget.labeler.labelOf(slot) ?? key;
    } catch (_) {
      // Sin catálogo no hay nombre legible: queda el guardado.
      label = key;
    }
    if (!mounted || widget.slot.identity != slot.identity) return;
    setState(() => _label = label);
  }

  @override
  Widget build(BuildContext context) {
    final String label;
    if (widget.slot.versionKey == null) {
      label = AppTexts.compareVersionDefaultLabel;
    } else {
      label = _label ?? AppTexts.missingValueLabel;
    }
    return widget.builder(context, label);
  }
}
