import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('las rutas de menú empiezan con barra', () {
    expect(FuelEconomyConfig.menuYearPath, startsWith('/'));
    expect(FuelEconomyConfig.menuMakePath, startsWith('/'));
    expect(FuelEconomyConfig.menuModelPath, startsWith('/'));
  });

  test('las claves y la cabecera no están vacías', () {
    expect(FuelEconomyConfig.yearQueryParameter, isNotEmpty);
    expect(FuelEconomyConfig.menuItemKey, isNotEmpty);
    expect(FuelEconomyConfig.itemTextKey, isNotEmpty);
    expect(FuelEconomyConfig.makeQueryParameter, isNotEmpty);
  });

  test('el User-Agent de FuelEconomy no está vacío', () {
    expect(UserAgentsConfig.fuelEconomyUserAgent, isNotEmpty);
  });
}
