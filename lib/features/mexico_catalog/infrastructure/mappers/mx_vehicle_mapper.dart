import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_vehicle_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/services/mx_fuel_classifier.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/services/mx_model_name_cleaner.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/services/mx_power_text_cleaner.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/services/mx_table_labeler.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Fila limpia y si se le descartó algún km/l por no ser plausible.
typedef MxMappedRow = ({MxVehicleEntity vehicle, bool droppedKmPerLiter});

/// Convierte una fila cruda del datastore en una fila limpia.
class MxVehicleMapper {
  const MxVehicleMapper({
    this.fuelClassifier = const MxFuelClassifier(),
    this.cylindersLabeler = const MxTableLabeler(
      labels: ConueeConfig.cylinderLabels,
    ),
    this.transmissionLabeler = const MxTableLabeler(
      labels: ConueeConfig.transmissionLabels,
    ),
    this.powerCleaner = const MxPowerTextCleaner(),
    this.nameCleaner = const MxModelNameCleaner(),
  });

  final MxFuelClassifier fuelClassifier;
  final MxTableLabeler cylindersLabeler;
  final MxTableLabeler transmissionLabeler;
  final MxPowerTextCleaner powerCleaner;
  final MxModelNameCleaner nameCleaner;

  /// Nulo si la fila no trae marca o modelo.
  MxMappedRow? map(int id, Map<String, dynamic> row) {
    final brand = _text(row[ConueeConfig.brandKey]);
    final rawModel = _text(row[ConueeConfig.modelKey]);
    if (brand == null || rawModel == null) return null;
    final fuelType = _text(row[ConueeConfig.fuelTypeKey]);
    final kind = fuelClassifier.classify(fuelType, rawModel);
    final km = [
      _kmPerLiter(row[ConueeConfig.cityKmPerLiterKey], kind),
      _kmPerLiter(row[ConueeConfig.highwayKmPerLiterKey], kind),
      _kmPerLiter(row[ConueeConfig.combinedKmPerLiterKey], kind),
    ];
    final displacement = _number(row[ConueeConfig.displacementKey]);
    return (
      vehicle: MxVehicleEntity(
        id: id,
        brand: brand,
        rawModel: rawModel,
        model: nameCleaner.clean(brand, rawModel),
        engineKind: kind,
        fuelType: fuelType,
        cityKmPerLiter: km[0].value,
        highwayKmPerLiter: km[1].value,
        combinedKmPerLiter: km[2].value,
        cityCo2GramsPerKilometer: _co2(row[ConueeConfig.cityCo2Key], kind),
        highwayCo2GramsPerKilometer: _co2(
          row[ConueeConfig.highwayCo2Key],
          kind,
        ),
        combinedCo2GramsPerKilometer: _co2(
          row[ConueeConfig.combinedCo2Key],
          kind,
        ),
        cylinders: cylindersLabeler.label(
          _text(row[ConueeConfig.cylindersKey]),
        ),
        displacementCubicCentimeters: displacement != null && displacement > 0
            ? displacement.round()
            : null,
        transmission: transmissionLabeler.label(
          _text(row[ConueeConfig.transmissionKey]),
        ),
        power: powerCleaner.clean(_text(row[ConueeConfig.powerKey])),
        torque: powerCleaner.clean(_text(row[ConueeConfig.torqueKey])),
      ),
      droppedKmPerLiter: km.any((entry) => entry.dropped),
    );
  }

  // Eléctricos: 0 y 1.0 son relleno. Enchufables: no comparable. Resto: rango plausible.
  static ({double? value, bool dropped}) _kmPerLiter(
    Object? raw,
    EngineKind? kind,
  ) {
    final value = _number(raw);
    if (value == null) return (value: null, dropped: false);
    if (kind == EngineKind.electric) {
      return (value: _filler(value) ? null : value, dropped: false);
    }
    if (kind == EngineKind.pluginHybrid) return (value: null, dropped: false);
    final plausible =
        value >= ConueeConfig.minPlausibleKmPerLiter &&
        value <= ConueeConfig.maxPlausibleKmPerLiter;
    return (value: plausible ? value : null, dropped: !plausible);
  }

  static double? _co2(Object? raw, EngineKind? kind) {
    final value = _number(raw);
    if (value == null) return null;
    return kind == EngineKind.electric && _filler(value) ? null : value;
  }

  static bool _filler(double value) =>
      ConueeConfig.electricFillerValues.contains(value);

  static double? _number(Object? raw) {
    if (raw is num) return raw.toDouble();
    if (raw is String) return double.tryParse(raw.trim());
    return null;
  }

  static String? _text(Object? raw) {
    if (raw is! String) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
