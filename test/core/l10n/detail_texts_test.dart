import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la etiqueta de versiones distingue singular y plural', () {
    expect(AppTexts.detailVersionLabel(1), 'Versión (1 disponible)');
    expect(AppTexts.detailVersionLabel(5), 'Versión (5 disponibles)');
  });

  test('marca y año va en mayúsculas', () {
    expect(AppTexts.brandYearLabel('Toyota', 2020), 'TOYOTA · 2020');
  });

  test('el crédito de la foto lleva autor y licencia', () {
    expect(
      AppTexts.photoCreditLabel('Ana', 'CC BY 4.0'),
      'Foto: Ana · CC BY 4.0',
    );
  });

  test('el consumo lleva un decimal', () {
    expect(AppTexts.kmPerLiterFigure(14.62), '14.6');
    expect(AppTexts.kmPerLiterFigure(9), '9.0');
    expect(AppTexts.kmPerLiterUnit, 'km/l');
  });
}
