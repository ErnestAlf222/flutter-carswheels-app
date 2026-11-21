import 'package:flutter/widgets.dart';

/// Colores propios del campo cuando la banda no es la tinta de Buscar.
class SearchFieldPalette {
  const SearchFieldPalette({
    required this.fill,
    required this.border,
    required this.text,
    required this.hint,
    required this.icon,
  });

  final Color fill;
  final Color border;
  final Color text;
  final Color hint;
  final Color icon;
}

/// Identidad propia de la banda del selector: color, campo y contador.
class SearchBandStyle {
  const SearchBandStyle({
    required this.color,
    required this.field,
    this.counter,
  });

  /// Color de la banda superior.
  final Color color;

  /// Colores del campo, que toma el tono de la banda.
  final SearchFieldPalette field;

  /// Línea bajo el título (por ejemplo "Llevas 1 de 3"); la arma la capa app.
  final Widget? counter;
}
