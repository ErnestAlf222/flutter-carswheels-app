import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('34 mpg equivalen a unos 14.45 km/l', () {
    const milesPerGallon = 34;
    const expectedKilometersPerLiter = 14.45;
    const tolerance = 0.01;
    const converted =
        milesPerGallon * UnitsConfig.milesPerGallonToKilometersPerLiter;
    expect(converted, closeTo(expectedKilometersPerLiter, tolerance));
  });
}
