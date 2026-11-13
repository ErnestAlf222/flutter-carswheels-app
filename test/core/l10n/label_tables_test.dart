import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/real_fuel_economy_values.dart';

void main() {
  group('DriveTexts', () {
    test('cada valor real de drive no vacío tiene entrada', () {
      for (final value in realDriveValues.where((v) => v.isNotEmpty)) {
        expect(DriveTexts.labels.containsKey(value), isTrue, reason: value);
      }
    });

    test('el valor vacío no tiene entrada y no sobran entradas', () {
      expect(DriveTexts.labels.containsKey(''), isFalse);
      expect(realDriveValues, containsAll(DriveTexts.labels.keys));
    });

    test('ninguna traducción es vacía', () {
      for (final entry in DriveTexts.labels.entries) {
        expect(entry.value.trim(), isNotEmpty, reason: entry.key);
      }
    });
  });

  group('FuelTypeTexts', () {
    test('cada valor real de fuelType tiene entrada', () {
      for (final value in realFuelTypeValues.where((v) => v.isNotEmpty)) {
        expect(FuelTypeTexts.labels.containsKey(value), isTrue, reason: value);
      }
    });

    test('no sobran entradas y las traducciones son cortas y no vacías', () {
      expect(realFuelTypeValues, containsAll(FuelTypeTexts.labels.keys));
      for (final entry in FuelTypeTexts.labels.entries) {
        expect(entry.value.trim(), isNotEmpty, reason: entry.key);
        expect(entry.value.length, lessThanOrEqualTo(32), reason: entry.key);
      }
    });
  });

  group('AppTexts del descriptor', () {
    test('textos de transmisión y marcadores', () {
      expect(AppTexts.transmissionAutomaticLabel, 'Automática');
      expect(AppTexts.transmissionManualLabel, 'Manual');
      expect(AppTexts.transmissionCvtLabel, 'CVT');
      expect(AppTexts.descriptorSeparator, ' · ');
      expect(AppTexts.noDataLabel, '—');
    });

    test('funciones de formato', () {
      expect(AppTexts.transmissionSpeedsLabel(8), '8 vel.');
      expect(AppTexts.cylindersLabel(4), '4 cil');
      expect(AppTexts.displacementLabel(2), '2.0 L');
      expect(AppTexts.displacementLabel(6.2), '6.2 L');
    });

    test('el costo anual lleva separador de miles', () {
      expect(AppTexts.annualCostLabel(600), r'$600');
      expect(AppTexts.annualCostLabel(1750), r'$1,750');
      expect(AppTexts.annualCostLabel(12345), r'$12,345');
      expect(AppTexts.annualCostLabel(1234567), r'$1,234,567');
      expect(TextConfig.thousandsSeparator, ',');
    });
  });
}
