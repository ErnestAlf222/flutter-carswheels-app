import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

List<ModelEntity> _map(String body) => ModelMapper.toModels(
  FuelEconomyMenuModel.fromJson(jsonDecode(body)).itemTexts,
);

void main() {
  test('mapea la lista de modelos sin cambiar los nombres', () {
    expect(
      _map(
        '{"menuItem":[{"text":"Civic 2Dr","value":"Civic 2Dr"},'
        '{"text":"Civic 4Dr","value":"Civic 4Dr"},'
        '{"text":"Civic 5Dr","value":"Civic 5Dr"}]}',
      ),
      const [
        ModelEntity(name: 'Civic 2Dr'),
        ModelEntity(name: 'Civic 4Dr'),
        ModelEntity(name: 'Civic 5Dr'),
      ],
    );
  });

  test('mapea un solo objeto como lista de uno', () {
    expect(_map('{"menuItem":{"text":"Chiron","value":"Chiron"}}'), const [
      ModelEntity(name: 'Chiron'),
    ]);
  });

  test('lista vacía y cuerpo sin menuItem dan lista vacía', () {
    expect(_map('{"menuItem":[]}'), isEmpty);
    expect(_map('{}'), isEmpty);
  });

  test('descarta los textos vacíos', () {
    expect(
      _map(
        '{"menuItem":[{"text":"","value":""},{"text":"  ","value":" "},'
        '{"text":"Divo","value":"Divo"}]}',
      ),
      const [ModelEntity(name: 'Divo')],
    );
  });

  test('un cuerpo inválido lanza ParsingFailure', () {
    expect(() => _map('"texto"'), throwsA(isA<ParsingFailure>()));
    expect(() => _map('{"menuItem":"x"}'), throwsA(isA<ParsingFailure>()));
  });
}
