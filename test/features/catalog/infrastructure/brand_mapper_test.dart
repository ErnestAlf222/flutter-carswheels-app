import 'dart:convert';

import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('convierte un texto en BrandEntity', () {
    expect(BrandMapper.toBrand('Acura'), const BrandEntity(name: 'Acura'));
  });

  test('convierte los textos del fixture de marcas', () {
    final model = FuelEconomyMenuModel.fromJson(
      jsonDecode('{"menuItem":{"text":"Ford","value":"Ford"}}'),
    );
    expect(model.itemTexts.map(BrandMapper.toBrand), [
      const BrandEntity(name: 'Ford'),
    ]);
  });

  test('convierte años y ignora valores no numéricos', () {
    final model = FuelEconomyMenuModel.fromJson(
      jsonDecode(
        '{"menuItem":[{"text":"2027","value":"2027"},'
        '{"text":"abc","value":"abc"},{"text":"2026","value":"2026"}]}',
      ),
    );
    expect(BrandMapper.toYears(model.itemTexts), [2027, 2026]);
  });

  test('sin textos devuelve lista vacía', () {
    expect(BrandMapper.toYears(const []), isEmpty);
  });
}
