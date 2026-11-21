import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/domain/entities/spec_entry_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Arma la ficha técnica de una versión con los campos que ya se parsean.
///
/// Un dato nulo no genera fila; sin ningún dato, la lista queda vacía. Las
/// filas salen agrupadas por sección en el orden en que se muestran.
class VehicleSpecSheetBuilder {
  const VehicleSpecSheetBuilder({
    required this.transmissionLabeler,
    required this.fuelTypeLabeler,
    required this.driveLabeler,
    this.vehicleClassTranslator = const VehicleClassTranslator(),
  });

  final TransmissionLabeler transmissionLabeler;
  final FuelTypeLabeler fuelTypeLabeler;
  final DriveLabeler driveLabeler;
  final VehicleClassTranslator vehicleClassTranslator;

  // Orden fijo de las secciones en el panel.
  static const List<SpecSection> _sectionOrder = [
    SpecSection.engine,
    SpecSection.consumption,
    SpecSection.energy,
    SpecSection.body,
  ];

  List<SpecEntryEntity> build(
    VehicleDetailEntity detail, {
    required bool isMexico,
  }) {
    final rows = isMexico ? _mexico(detail) : _unitedStates(detail);
    final entries = [
      for (final row in rows)
        if (row.value != null && row.value!.trim().isNotEmpty)
          SpecEntryEntity(
            label: row.label,
            value: row.value!,
            kind: row.kind,
            section: row.section,
            engineKindName: row.kind == SpecKind.fuel
                ? detail.engineKind?.name
                : null,
          ),
    ];
    return [
      for (final section in _sectionOrder)
        ...entries.where((entry) => entry.section == section),
    ];
  }

  _Row _row(SpecSection section, SpecKind kind, String label, String? value) =>
      _Row(section, kind, label, value);

  // EE. UU. (FuelEconomy): motor, consumo, energía y carrocería.
  List<_Row> _unitedStates(VehicleDetailEntity detail) {
    final cylinders = detail.cylinders;
    final liters = detail.displacementLiters;
    final electricRange = detail.electricRangeKilometers;
    final totalRange = detail.totalRangeKilometers;
    final consumption = detail.electricConsumptionKwhPer100Kilometers;
    final cost = detail.annualFuelCostUsd;
    final co2 = detail.co2GramsPerKilometer;
    final passengers = detail.passengerVolumeLiters;
    final cargo = detail.cargoVolumeLiters;
    final charge240 = detail.chargeHours240;
    final charge120 = detail.chargeHours120;
    return [
      _row(
        SpecSection.engine,
        SpecKind.cylinders,
        AppTexts.detailCylindersRowLabel,
        cylinders == null ? null : AppTexts.cylindersLabel(cylinders),
      ),
      _row(
        SpecSection.engine,
        SpecKind.displacement,
        AppTexts.detailDisplacementRowLabel,
        liters == null ? null : AppTexts.displacementLabel(liters),
      ),
      _row(
        SpecSection.engine,
        SpecKind.aspiration,
        AppTexts.detailAspirationRowLabel,
        _aspirationLabel(detail),
      ),
      _row(
        SpecSection.engine,
        SpecKind.transmission,
        AppTexts.detailTransmissionRowLabel,
        transmissionLabeler.labelFor(detail.transmission),
      ),
      _row(
        SpecSection.engine,
        SpecKind.drive,
        AppTexts.detailDriveRowLabel,
        driveLabeler.labelFor(detail.drive),
      ),
      _row(
        SpecSection.engine,
        SpecKind.startStop,
        SpecSheetTexts.startStop,
        switch (detail.hasStartStop) {
          true => SpecSheetTexts.yes,
          false => SpecSheetTexts.no,
          null => null,
        },
      ),
      _consumptionRow(
        SpecKind.cityConsumption,
        SpecSheetTexts.cityConsumption,
        detail.cityKmPerLiter,
        withMpg: true,
      ),
      _consumptionRow(
        SpecKind.highwayConsumption,
        SpecSheetTexts.highwayConsumption,
        detail.highwayKmPerLiter,
        withMpg: true,
      ),
      _consumptionRow(
        SpecKind.combinedConsumption,
        SpecSheetTexts.combinedConsumption,
        detail.combinedKmPerLiter,
        withMpg: true,
      ),
      _consumptionRow(
        SpecKind.hybridGasConsumption,
        AppTexts.hybridGasConsumptionLabel,
        detail.hybridGasKmPerLiter,
        withMpg: true,
      ),
      _row(
        SpecSection.consumption,
        SpecKind.electricConsumption,
        AppTexts.electricConsumptionLabel,
        consumption == null ? null : AppTexts.kwhPer100KmFigure(consumption),
      ),
      _row(
        SpecSection.consumption,
        SpecKind.annualCost,
        SpecSheetTexts.annualCost,
        cost == null ? null : AppTexts.annualCostLabel(cost),
      ),
      _row(
        SpecSection.energy,
        SpecKind.fuel,
        AppTexts.detailFuelRowLabel,
        _fuelValue(detail),
      ),
      _row(
        SpecSection.energy,
        SpecKind.powertrain,
        SpecSheetTexts.powertrain,
        _powertrainValue(detail.engineKind),
      ),
      _row(
        SpecSection.energy,
        SpecKind.electricRange,
        AppTexts.electricRangeLabel,
        electricRange == null ? null : AppTexts.kilometersFigure(electricRange),
      ),
      _row(
        SpecSection.energy,
        SpecKind.totalRange,
        AppTexts.totalRangeLabel,
        totalRange == null ? null : AppTexts.kilometersFigure(totalRange),
      ),
      _row(
        SpecSection.energy,
        SpecKind.chargeTime,
        SpecSheetTexts.chargeTime240,
        charge240 == null ? null : SpecSheetTexts.hoursFigure(charge240),
      ),
      _row(
        SpecSection.energy,
        SpecKind.chargeTime,
        SpecSheetTexts.chargeTime120,
        charge120 == null ? null : SpecSheetTexts.hoursFigure(charge120),
      ),
      _row(
        SpecSection.energy,
        SpecKind.co2,
        AppTexts.co2Label,
        co2 == null ? null : AppTexts.gramsPerKilometerFigure(co2),
      ),
      _row(
        SpecSection.body,
        SpecKind.vehicleClass,
        SpecSheetTexts.vehicleClass,
        vehicleClassTranslator.labelFor(detail.vehicleClass),
      ),
      _row(
        SpecSection.body,
        SpecKind.passengerVolume,
        SpecSheetTexts.passengerVolume,
        passengers == null ? null : SpecSheetTexts.litersFigure(passengers),
      ),
      _row(
        SpecSection.body,
        SpecKind.cargoVolume,
        SpecSheetTexts.cargoVolume,
        cargo == null ? null : SpecSheetTexts.litersFigure(cargo),
      ),
    ];
  }

  _Row _consumptionRow(
    SpecKind kind,
    String label,
    double? kmPerLiter, {
    required bool withMpg,
  }) {
    final text = kmPerLiter == null
        ? null
        : withMpg
        ? SpecSheetTexts.kmPerLiterWithMpg(kmPerLiter)
        : SpecSheetTexts.kmPerLiterOnly(kmPerLiter);
    return _row(SpecSection.consumption, kind, label, text);
  }

  // Un eléctrico se nombra por su energía; el resto usa el combustible real.
  String? _fuelValue(VehicleDetailEntity detail) {
    if (detail.engineKind == EngineKind.electric) {
      return AppTexts.electricLabel;
    }
    return fuelTypeLabeler.labelFor(detail.fuelType);
  }

  // Solo los híbridos y el hidrógeno añaden la motorización; el resto ya se lee en el combustible.
  String? _powertrainValue(EngineKind? kind) {
    const shown = {
      EngineKind.hybrid,
      EngineKind.pluginHybrid,
      EngineKind.hydrogen,
    };
    return kind != null && shown.contains(kind)
        ? AppTexts.engineKindLabels[kind.name]
        : null;
  }

  // Texto de aspiración forzada; nulo (fila oculta) si no tiene.
  String? _aspirationLabel(VehicleDetailEntity detail) {
    if (detail.hasTurbo && detail.hasSupercharger) {
      return AppTexts.aspirationBoth;
    }
    if (detail.hasTurbo) return AppTexts.aspirationTurbo;
    if (detail.hasSupercharger) return AppTexts.aspirationSupercharger;
    return null;
  }

  // México (CONUEE): motor, consumo, energía y emisiones por ciclo.
  List<_Row> _mexico(VehicleDetailEntity detail) {
    final cubicCentimeters = detail.displacementCubicCentimeters;
    final liters = detail.displacementLiters;
    final power = detail.powerText;
    final torque = detail.torqueText;
    final co2 = detail.co2GramsPerKilometer;
    final cityCo2 = detail.cityCo2GramsPerKilometer;
    final highwayCo2 = detail.highwayCo2GramsPerKilometer;
    return [
      _row(
        SpecSection.engine,
        SpecKind.cylinders,
        AppTexts.detailCylindersRowLabel,
        detail.cylindersLabel,
      ),
      _row(
        SpecSection.engine,
        SpecKind.displacement,
        AppTexts.detailDisplacementRowLabel,
        cubicCentimeters == null || liters == null
            ? null
            : AppTexts.displacementCubicCentimetersLabel(
                cubicCentimeters,
                liters,
              ),
      ),
      _row(
        SpecSection.engine,
        SpecKind.transmission,
        AppTexts.detailTransmissionRowLabel,
        detail.transmission,
      ),
      _row(
        SpecSection.engine,
        SpecKind.power,
        AppTexts.detailPowerRowLabel,
        power == null
            ? null
            : AppTexts.peakWithRpm(power, AppTexts.horsepowerUnit),
      ),
      _row(
        SpecSection.engine,
        SpecKind.torque,
        AppTexts.detailTorqueRowLabel,
        torque == null
            ? null
            : AppTexts.peakWithRpm(torque, AppTexts.newtonMetersUnit),
      ),
      _row(
        SpecSection.engine,
        SpecKind.compression,
        AppTexts.detailCompressionRowLabel,
        detail.compressionRatioText,
      ),
      _consumptionRow(
        SpecKind.cityConsumption,
        SpecSheetTexts.cityConsumption,
        detail.cityKmPerLiter,
        withMpg: false,
      ),
      _consumptionRow(
        SpecKind.highwayConsumption,
        SpecSheetTexts.highwayConsumption,
        detail.highwayKmPerLiter,
        withMpg: false,
      ),
      _consumptionRow(
        SpecKind.combinedConsumption,
        SpecSheetTexts.combinedConsumption,
        detail.combinedKmPerLiter,
        withMpg: false,
      ),
      _row(
        SpecSection.energy,
        SpecKind.fuel,
        AppTexts.detailFuelRowLabel,
        detail.fuelType,
      ),
      _row(
        SpecSection.energy,
        SpecKind.powertrain,
        SpecSheetTexts.powertrain,
        _powertrainValue(detail.engineKind),
      ),
      _row(
        SpecSection.energy,
        SpecKind.co2,
        AppTexts.co2Label,
        co2 == null ? null : AppTexts.gramsPerKilometerFigure(co2),
      ),
      _row(
        SpecSection.energy,
        SpecKind.cityCo2,
        SpecSheetTexts.cityCo2,
        cityCo2 == null ? null : AppTexts.gramsPerKilometerFigure(cityCo2),
      ),
      _row(
        SpecSection.energy,
        SpecKind.highwayCo2,
        SpecSheetTexts.highwayCo2,
        highwayCo2 == null
            ? null
            : AppTexts.gramsPerKilometerFigure(highwayCo2),
      ),
    ];
  }
}

// Fila candidata antes de descartar las que no tienen valor.
class _Row {
  const _Row(this.section, this.kind, this.label, this.value);

  final SpecSection section;
  final SpecKind kind;
  final String label;
  final String? value;
}
