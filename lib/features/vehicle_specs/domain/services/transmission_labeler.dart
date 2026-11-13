import 'package:cars_wheels_app/core/core.dart';

/// Traduce el campo trany de FuelEconomy a un texto corto en español.
class TransmissionLabeler {
  const TransmissionLabeler({this.onUntranslated});

  /// Se llama con el texto original cuando no se reconoce el tipo.
  final void Function(String original)? onUntranslated;

  static final RegExp _manual = RegExp(
    TransmissionConfig.manualPrefixPattern,
    caseSensitive: false,
  );
  static final RegExp _automatic = RegExp(
    TransmissionConfig.automaticPrefixPattern,
    caseSensitive: false,
  );
  static final RegExp _cvtCode = RegExp(TransmissionConfig.cvtCodePattern);
  static final RegExp _speedsWithDash = RegExp(
    TransmissionConfig.speedsWithDashPattern,
  );
  static final RegExp _speedsCode = RegExp(
    TransmissionConfig.speedsCodePattern,
  );

  /// Nulo si no hay texto; un tipo desconocido se devuelve tal cual.
  String? labelFor(String? trany) {
    if (trany == null || trany.trim().isEmpty) return null;
    final text = trany.trim();
    final String kind;
    if (_manual.hasMatch(text)) {
      kind = AppTexts.transmissionManualLabel;
    } else if (_automatic.hasMatch(text)) {
      kind = _isCvt(text)
          ? '${AppTexts.transmissionAutomaticLabel} '
                '${AppTexts.transmissionCvtLabel}'
          : AppTexts.transmissionAutomaticLabel;
    } else {
      onUntranslated?.call(text);
      return text;
    }
    final speeds = _speedsOf(text);
    return speeds == null
        ? kind
        : '$kind ${AppTexts.transmissionSpeedsLabel(speeds)}';
  }

  bool _isCvt(String text) =>
      text.toLowerCase().contains(TransmissionConfig.cvtKeyword) ||
      _cvtCode.hasMatch(text);

  int? _speedsOf(String text) {
    final match =
        _speedsWithDash.firstMatch(text) ?? _speedsCode.firstMatch(text);
    return match == null ? null : int.tryParse(match.group(1)!);
  }
}
