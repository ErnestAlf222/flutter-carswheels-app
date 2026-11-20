import 'package:cars_wheels_app/app/compare/compare_group_details_loader.dart';
import 'package:cars_wheels_app/app/compare/compare_version_labeler.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Datos comparables de un vehículo, con los casos de uso de Detalle y el catálogo.
class MarketCompareVehicleSource implements CompareVehicleSource {
  const MarketCompareVehicleSource({
    required this.loader,
    required this.versionLabeler,
    required this.classTranslator,
    required this.fuelTypeLabeler,
    required this.driveLabeler,
    required this.transmissionLabeler,
  });

  final CompareGroupDetailsLoader loader;
  final CompareVersionLabeler versionLabeler;
  final VehicleClassTranslator classTranslator;
  final FuelTypeLabeler fuelTypeLabeler;
  final DriveLabeler driveLabeler;
  final TransmissionLabeler transmissionLabeler;

  @override
  Future<CompareVehicleDetailEntity?> detailOf(CompareSlotEntity slot) async {
    final details = await loader.load(slot);
    if (details == null || details.versions.isEmpty) return null;
    final byKey = details.versions
        .where((version) => version.variantName == slot.versionKey)
        .firstOrNull;
    final version = byKey ?? details.versions[details.defaultIndex];
    final detail = version.detail;
    final isMexico = slot.marketCode == MarketConfig.mexicoCode;
    final power = detail.powerText;
    final torque = detail.torqueText;
    final cylinders = detail.cylinders;
    return CompareVehicleDetailEntity(
      versionLabel: versionLabeler.labelOf(version),
      engineKind: _engineKindOf(detail),
      combinedKmPerLiter: detail.combinedKmPerLiter,
      cityKmPerLiter: detail.cityKmPerLiter,
      highwayKmPerLiter: detail.highwayKmPerLiter,
      co2GramsPerKilometer: detail.co2GramsPerKilometer,
      // En México el combustible ya viene en español, sin clase ni tracción.
      fuelLabel: isMexico
          ? detail.fuelType
          : fuelTypeLabeler.labelFor(detail.fuelType),
      cylindersLabel: isMexico
          ? detail.cylindersLabel
          : (cylinders == null ? null : AppTexts.cylindersLabel(cylinders)),
      transmissionLabel: isMexico
          ? detail.transmission
          : transmissionLabeler.labelFor(detail.transmission),
      driveLabel: isMexico ? null : driveLabeler.labelFor(detail.drive),
      classLabel: isMexico
          ? null
          : classTranslator.labelFor(detail.vehicleClass),
      annualFuelCostUsd: isMexico ? null : detail.annualFuelCostUsd,
      powerLabel: !isMexico || power == null
          ? null
          : AppTexts.peakFigure(power, AppTexts.horsepowerUnit),
      torqueLabel: !isMexico || torque == null
          ? null
          : AppTexts.peakFigure(torque, AppTexts.newtonMetersUnit),
      compressionLabel: isMexico ? detail.compressionRatioText : null,
    );
  }

  // Con la clasificación existente: primero el tipo fino, si no la motorización.
  CompareEngineKind? _engineKindOf(VehicleDetailEntity detail) {
    final kind = detail.engineKind;
    if (kind != null) {
      return switch (kind) {
        EngineKind.electric => CompareEngineKind.electric,
        EngineKind.pluginHybrid => CompareEngineKind.pluginHybrid,
        EngineKind.hybrid => CompareEngineKind.hybrid,
        EngineKind.hydrogen => CompareEngineKind.hydrogen,
        EngineKind.diesel ||
        EngineKind.gasoline ||
        EngineKind.flexFuel => CompareEngineKind.combustion,
      };
    }
    return switch (detail.powertrain) {
      Powertrain.electric => CompareEngineKind.electric,
      Powertrain.pluginHybrid => CompareEngineKind.pluginHybrid,
      Powertrain.fuelCell => CompareEngineKind.hydrogen,
      Powertrain.combustion => CompareEngineKind.combustion,
      Powertrain.other => null,
    };
  }
}
