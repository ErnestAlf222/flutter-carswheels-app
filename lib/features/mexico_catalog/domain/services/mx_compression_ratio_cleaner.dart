import 'package:cars_wheels_app/core/core.dart';

/// Limpia la relación de compresión; nulo si no tiene la forma número:1.
class MxCompressionRatioCleaner {
  const MxCompressionRatioCleaner();

  static final RegExp _ratio = RegExp(ConueeConfig.compressionRatioPattern);

  /// "10.5 : 1" → "10.5:1"; "11.8", "0" y "sin dato" → nulo.
  String? clean(String? raw) {
    final match = _ratio.firstMatch(raw?.trim() ?? '');
    if (match == null) return null;
    final value = double.parse(match.group(1)!);
    if (value <= 0) return null;
    return '${match.group(1)}${ConueeConfig.compressionRatioSuffix}';
  }
}
