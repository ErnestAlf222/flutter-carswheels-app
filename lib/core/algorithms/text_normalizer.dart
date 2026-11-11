import 'package:cars_wheels_app/core/config/config.dart';

// Espacios en blanco y guiones que se eliminan.
final RegExp _separators = RegExp(r'[\s-]');

/// Normaliza texto para comparaciones y búsquedas.
class TextNormalizer {
  const TextNormalizer._();

  /// Minúsculas, sin acentos, sin espacios ni guiones.
  static String normalize(String text) {
    final unaccented = text
        .toLowerCase()
        .split('')
        .map((char) => TextConfig.accentReplacements[char] ?? char)
        .join();
    return unaccented.replaceAll(_separators, '');
  }
}
