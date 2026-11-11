import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

Object? _decode(String body) => jsonDecode(body);

void main() {
  test('lee una lista de items', () {
    final model = FuelEconomyMenuModel.fromJson(
      _decode(
        '{"menuItem":[{"text":"Acura","value":"Acura"},'
        '{"text":"Alfa Romeo","value":"Alfa Romeo"}]}',
      ),
    );
    expect(model.itemTexts, ['Acura', 'Alfa Romeo']);
  });

  test('lee un solo objeto como lista de uno', () {
    final model = FuelEconomyMenuModel.fromJson(
      _decode('{"menuItem":{"text":"Ford","value":"Ford"}}'),
    );
    expect(model.itemTexts, ['Ford']);
  });

  test('lista vacía da lista vacía', () {
    final model = FuelEconomyMenuModel.fromJson(_decode('{"menuItem":[]}'));
    expect(model.itemTexts, isEmpty);
  });

  test('cuerpo sin menuItem da lista vacía', () {
    final model = FuelEconomyMenuModel.fromJson(_decode('{}'));
    expect(model.itemTexts, isEmpty);
  });

  test('cuerpo que no es objeto lanza ParsingFailure', () {
    expect(
      () => FuelEconomyMenuModel.fromJson(_decode('[1,2]')),
      throwsA(isA<ParsingFailure>()),
    );
    expect(
      () => FuelEconomyMenuModel.fromJson('texto'),
      throwsA(isA<ParsingFailure>()),
    );
    expect(
      () => FuelEconomyMenuModel.fromJson(null),
      throwsA(isA<ParsingFailure>()),
    );
  });

  test('menuItem de otra forma lanza ParsingFailure', () {
    expect(
      () => FuelEconomyMenuModel.fromJson(_decode('{"menuItem":"x"}')),
      throwsA(isA<ParsingFailure>()),
    );
    expect(
      () =>
          FuelEconomyMenuModel.fromJson(_decode('{"menuItem":[{"value":1}]}')),
      throwsA(isA<ParsingFailure>()),
    );
  });
}
