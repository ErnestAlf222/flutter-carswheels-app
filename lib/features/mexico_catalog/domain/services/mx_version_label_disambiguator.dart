import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_version_entity.dart';

/// Da a cada versión de un grupo una etiqueta distinta cuando los nombres coinciden.
class MxVersionLabelDisambiguator {
  const MxVersionLabelDisambiguator();

  /// Mismo orden que [versions]; solo se toca lo repetido.
  List<String> labelsFor(List<MxVersionEntity> versions) {
    final labels = [for (final version in versions) version.label];
    final indexesByKey = <String, List<int>>{};
    for (final (index, label) in labels.indexed) {
      indexesByKey
          .putIfAbsent(TextNormalizer.normalize(label), () => [])
          .add(index);
    }
    final result = [...labels];
    for (final indexes in indexesByKey.values) {
      if (indexes.length < 2) continue;
      _disambiguate(versions, indexes, result);
    }
    return result;
  }

  // Prueba transmisión, luego cilindrada y al final ambas; se queda con la primera que separa.
  static void _disambiguate(
    List<MxVersionEntity> versions,
    List<int> indexes,
    List<String> result,
  ) {
    final attempts = <List<String?> Function(MxVersionEntity)>[
      (version) => [version.vehicle.transmission],
      (version) => [_displacement(version)],
      (version) => [version.vehicle.transmission, _displacement(version)],
      // Último recurso para filas casi idénticas: la potencia declarada.
      (version) => [
        version.vehicle.transmission,
        _displacement(version),
        _power(version),
      ],
    ];
    for (final attempt in attempts) {
      final candidates = [
        for (final index in indexes) _compose(versions[index], attempt),
      ];
      if (candidates.toSet().length == candidates.length) {
        for (final (position, index) in indexes.indexed) {
          result[index] = candidates[position];
        }
        return;
      }
    }
    // Sin forma de separarlas, se conserva la combinación más completa.
    for (final index in indexes) {
      result[index] = _compose(versions[index], attempts.last);
    }
  }

  static String _compose(
    MxVersionEntity version,
    List<String?> Function(MxVersionEntity) extras,
  ) => AppTexts.versionLabelWith(version.label, [
    ...extras(version).whereType<String>(),
  ]);

  static String? _power(MxVersionEntity version) {
    final power = version.vehicle.power;
    return power == null
        ? null
        : AppTexts.peakFigure(power, AppTexts.horsepowerUnit);
  }

  static String? _displacement(MxVersionEntity version) {
    final cc = version.vehicle.displacementCubicCentimeters;
    return cc == null
        ? null
        : AppTexts.displacementLabel(cc / UnitsConfig.cubicCentimetersPerLiter);
  }
}
