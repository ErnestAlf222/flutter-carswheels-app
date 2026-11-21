import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/domain/entities/spec_entry_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Arma la ficha técnica de una versión con los campos que ya se parsean.
///
/// Un dato nulo no genera fila; sin ningún dato, la lista queda vacía.
class VehicleSpecSheetBuilder {
  const VehicleSpecSheetBuilder({
    required this.transmissionLabeler,
    required this.fuelTypeLabeler,
    required this.driveLabeler,
  });

  final TransmissionLabeler transmissionLabeler;
  final FuelTypeLabeler fuelTypeLabeler;
  final DriveLabeler driveLabeler;

  List<SpecEntryEntity> build(
    VehicleDetailEntity detail, {
    required bool isMexico,
  }) {
    final values = isMexico ? _mexico(detail) : _unitedStates(detail);
    return [
      for (final (label, value) in values)
        if (value != null && value.trim().isNotEmpty)
          SpecEntryEntity(label: label, value: value),
    ];
  }

  // EE. UU. (FuelEconomy): motor, transmisión, tracción, combustible y eléctricos.
  List<(String, String?)> _unitedStates(VehicleDetailEntity detail) {
    final cylinders = detail.cylinders;
    final liters = detail.displacementLiters;
    final electricRange = detail.electricRangeKilometers;
    final totalRange = detail.totalRangeKilometers;
    final consumption = detail.electricConsumptionKwhPer100Kilometers;
    return [
      (AppTexts.detailFuelRowLabel, fuelTypeLabeler.labelFor(detail.fuelType)),
      (
        AppTexts.detailCylindersRowLabel,
        cylinders == null ? null : AppTexts.cylindersLabel(cylinders),
      ),
      (
        AppTexts.detailDisplacementRowLabel,
        liters == null ? null : AppTexts.displacementLabel(liters),
      ),
      (
        AppTexts.detailTransmissionRowLabel,
        transmissionLabeler.labelFor(detail.transmission),
      ),
      (AppTexts.detailDriveRowLabel, driveLabeler.labelFor(detail.drive)),
      (
        AppTexts.electricRangeLabel,
        electricRange == null ? null : AppTexts.kilometersFigure(electricRange),
      ),
      (
        AppTexts.totalRangeLabel,
        totalRange == null ? null : AppTexts.kilometersFigure(totalRange),
      ),
      (
        AppTexts.electricConsumptionLabel,
        consumption == null ? null : AppTexts.kwhPer100KmFigure(consumption),
      ),
    ];
  }

  // México (CONUEE): combustible, motor, transmisión, potencia, torque y compresión.
  List<(String, String?)> _mexico(VehicleDetailEntity detail) {
    final cubicCentimeters = detail.displacementCubicCentimeters;
    final liters = detail.displacementLiters;
    final power = detail.powerText;
    final torque = detail.torqueText;
    return [
      (AppTexts.detailFuelRowLabel, detail.fuelType),
      (AppTexts.detailCylindersRowLabel, detail.cylindersLabel),
      (
        AppTexts.detailDisplacementRowLabel,
        cubicCentimeters == null || liters == null
            ? null
            : AppTexts.displacementCubicCentimetersLabel(
                cubicCentimeters,
                liters,
              ),
      ),
      (AppTexts.detailTransmissionRowLabel, detail.transmission),
      (
        AppTexts.detailPowerRowLabel,
        power == null
            ? null
            : AppTexts.peakWithRpm(power, AppTexts.horsepowerUnit),
      ),
      (
        AppTexts.detailTorqueRowLabel,
        torque == null
            ? null
            : AppTexts.peakWithRpm(torque, AppTexts.newtonMetersUnit),
      ),
      (AppTexts.detailCompressionRowLabel, detail.compressionRatioText),
    ];
  }
}
