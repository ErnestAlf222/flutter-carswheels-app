import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/conuee_test_support.dart';
import '../../../support/mx_detail_test_support.dart';

void main() {
  const disambiguator = MxVersionLabelDisambiguator();

  MxVersionEntity version(
    String label, {
    String? transmission,
    int? cc,
    String? power,
  }) => MxVersionEntity(
    label: label,
    vehicle: MxVehicleEntity(
      id: 0,
      brand: 'Marca',
      rawModel: label,
      model: label,
      transmission: transmission,
      displacementCubicCentimeters: cc,
      power: power,
    ),
  );

  test('etiquetas distintas se quedan como están', () {
    final labels = disambiguator.labelsFor([
      mxVersion('COROLLA'),
      mxVersion('COROLLA HIBRIDO'),
    ]);
    expect(labels, ['COROLLA', 'COROLLA HIBRIDO']);
  });

  test('dos iguales se distinguen por la transmisión', () {
    final labels = disambiguator.labelsFor([
      version('KICKS PLAY', transmission: 'Manual', cc: 1598),
      version('KICKS PLAY', transmission: 'CVT', cc: 1598),
      version('KICKS'),
    ]);
    expect(labels, ['KICKS PLAY · Manual', 'KICKS PLAY · CVT', 'KICKS']);
  });

  test('si la transmisión no separa, usa la cilindrada', () {
    final labels = disambiguator.labelsFor([
      version('ADX', transmission: 'CVT', cc: 1498),
      version('ADX', transmission: 'CVT', cc: 1998),
    ]);
    expect(labels, ['ADX · 1.5 L', 'ADX · 2.0 L']);
  });

  test('si ninguna sola separa, junta transmisión y cilindrada', () {
    final labels = disambiguator.labelsFor([
      version('A5', transmission: 'Manual', cc: 1984),
      version('A5', transmission: 'Manual', cc: 1798),
      version('A5', transmission: 'CVT', cc: 1984),
    ]);
    expect(labels, [
      'A5 · Manual · 2.0 L',
      'A5 · Manual · 1.8 L',
      'A5 · CVT · 2.0 L',
    ]);
  });

  test('la comparación ignora mayúsculas y acentos', () {
    final labels = disambiguator.labelsFor([
      version('Kicks Pláy', transmission: 'Manual'),
      version('KICKS PLAY', transmission: 'CVT'),
    ]);
    expect(labels, ['Kicks Pláy · Manual', 'KICKS PLAY · CVT']);
  });

  test('con todo igual la potencia es el último recurso', () {
    final labels = disambiguator.labelsFor([
      version(
        'A5',
        transmission: 'Automática',
        cc: 1984,
        power: '245.4 @ 5000',
      ),
      version(
        'A5',
        transmission: 'Automática',
        cc: 1984,
        power: '187.74 @ 4200',
      ),
    ]);
    expect(labels, [
      'A5 · Automática · 2.0 L · 245.4 hp',
      'A5 · Automática · 2.0 L · 187.74 hp',
    ]);
  });

  test('filas reales: Corolla y Corolla Cross no chocan entre sí', () {
    final labels = disambiguator.labelsFor([
      MxVersionEntity(label: 'COROLLA', vehicle: conueeVehicle('COROLLA')),
      MxVersionEntity(
        label: 'COROLLA CROSS',
        vehicle: conueeVehicle('COROLLA CROSS'),
      ),
    ]);
    expect(labels, ['COROLLA', 'COROLLA CROSS']);
  });
}
