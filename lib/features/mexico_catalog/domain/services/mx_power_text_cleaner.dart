import 'package:cars_wheels_app/core/core.dart';

/// Limpia el texto de potencia o torque; nulo si el patrón no es inequívoco.
class MxPowerTextCleaner {
  const MxPowerTextCleaner();

  static final RegExp _valueOnly = RegExp(ConueeConfig.powerValueOnlyPattern);
  static final RegExp _marker = RegExp(
    ConueeConfig.powerMarkerPattern,
    caseSensitive: false,
  );
  static final RegExp _withRpm = RegExp(ConueeConfig.powerRpmPattern);

  /// "190@6000" → "190 @ 6000"; "46.9@ MAX" → "46.9"; "135±5 @ PEAK" → nulo.
  String? clean(String? raw) {
    final cleaned = _clean(raw);
    if (cleaned == null) return null;
    // Un 0 inicial ("0@0") es relleno de CONUEE, no una potencia real.
    final value = double.tryParse(
      cleaned.split(ConueeConfig.powerSeparator).first,
    );
    return value == null || value <= 0 ? null : cleaned;
  }

  String? _clean(String? raw) {
    final text = raw?.trim() ?? '';
    final valueOnly = _valueOnly.firstMatch(text);
    if (valueOnly != null) return valueOnly.group(1);
    final marker = _marker.firstMatch(text);
    if (marker != null) return marker.group(1);
    final withRpm = _withRpm.firstMatch(text);
    if (withRpm == null) return null;
    final start = _digitsOnly(withRpm.group(2)!);
    final end = withRpm.group(3);
    final rpm = end == null
        ? start
        : '$start${ConueeConfig.rpmRangeSeparator}${_digitsOnly(end)}';
    return '${withRpm.group(1)}${ConueeConfig.powerSeparator}$rpm';
  }

  static String _digitsOnly(String text) =>
      text.replaceAll(ConueeConfig.rpmThousandsSeparator, '');
}
