import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('el aire de Inicio crece respecto de los valores anteriores', () {
    // Antes: 24 bajo el encabezado, 16 sobre Marcas, 16 hasta los modelos,
    // 14 entre tarjetas.
    expect(HeaderConfig.contentBottomPadding, greaterThan(24));
    expect(CatalogConfig.brandsHeaderTopPadding, greaterThan(AppSpacing.m));
    expect(CatalogConfig.modelsSectionTopGap, greaterThan(0));
    expect(ModelGridConfig.crossAxisSpacing, greaterThan(14));
    expect(ModelGridConfig.mainAxisSpacing, greaterThan(14));
  });

  test('los títulos de sección pesan w600 en Outfit y nunca w800', () {
    expect(AppTextStyles.sectionTitle.fontWeight, FontWeight.w600);
    expect(AppTextStyles.sectionTitle.fontSize, 25);
    expect(AppTextStyles.sectionTitle.fontFamily, contains('Outfit'));
    for (final style in [
      AppTextStyles.screenTitle,
      AppTextStyles.sectionTitle,
      AppTextStyles.cardTitle,
      AppTextStyles.onDarkWordmark,
    ]) {
      expect(style.fontWeight, isNot(FontWeight.w800));
      expect(style.fontWeight, isNot(FontWeight.w900));
    }
  });

  test('el wordmark conserva su peso', () {
    expect(AppTextStyles.onDarkWordmark.fontWeight, FontWeight.w700);
  });
}
