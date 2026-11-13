import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el punto activo es blanco pleno y el inactivo blanco al 50 %', () {
    expect(AppColors.galleryDotActive, AppColors.onGradient);
    expect(AppColors.galleryDotActive, const Color(0xFFFFFFFF));
    expect(AppColors.galleryDotInactive, const Color(0x80FFFFFF));
  });

  test('la insignia sin foto mide 18', () {
    expect(UiConfig.rowNoPhotoBadgeSize, 18.0);
  });

  test('las constantes de la tarjeta de consumo', () {
    expect(UiConfig.efficiencyCardPadding, 20.0);
    expect(UiConfig.efficiencyGridSpacing, 16.0);
    expect(UiConfig.efficiencyScoreSegmentCount, 10);
    expect(UiConfig.efficiencyScoreSegmentWidth, 14.0);
    expect(UiConfig.efficiencyScoreSegmentHeight, 6.0);
    expect(UiConfig.efficiencyScoreSegmentGap, 3.0);
    expect(UiConfig.efficiencyScoreSegmentRadius, 3.0);
    expect(AppColors.scoreSegmentEmpty, AppColors.line);
  });

  test('las unidades y los límites de puntuación', () {
    expect(UnitsConfig.kilometersPerMile, 1.609344);
    expect(
      UnitsConfig.kilowattHoursPer100MilesToPer100Kilometers,
      1 / 1.609344,
    );
    expect(VehicleSpecsConfig.scoreMin, 1);
    expect(VehicleSpecsConfig.scoreMax, 10);
  });

  test('los textos de la tarjeta', () {
    expect(AppTexts.kilometersFigure(530.6), '531 km');
    expect(AppTexts.gramsPerKilometerFigure(159.7), '160 g/km');
    expect(AppTexts.kwhPer100KmFigure(16.14), '16.1 kWh/100 km');
    expect(AppTexts.scoreSemanticLabel(7), '7 de 10');
  });
}
