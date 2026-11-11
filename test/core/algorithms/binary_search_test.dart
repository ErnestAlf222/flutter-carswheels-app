import 'package:cars_wheels_app/core/algorithms/algorithms.dart';
import 'package:flutter_test/flutter_test.dart';

const List<int> _numbers = [1, 3, 5, 7, 9];
const List<String> _words = ['audi', 'bmw', 'bmwx', 'bmwz', 'ford'];

int Function(int) _target(int value) =>
    (item) => item.compareTo(value);

String _identity(String word) => word;

void main() {
  group('BinarySearch.indexOf', () {
    test('encuentra un elemento', () {
      expect(BinarySearch.indexOf(_numbers, _target(7)), 3);
    });

    test('no encontrado devuelve -1', () {
      expect(BinarySearch.indexOf(_numbers, _target(4)), -1);
    });

    test('primer elemento', () {
      expect(BinarySearch.indexOf(_numbers, _target(1)), 0);
    });

    test('último elemento', () {
      expect(BinarySearch.indexOf(_numbers, _target(9)), 4);
    });

    test('lista vacía', () {
      expect(BinarySearch.indexOf(<int>[], _target(1)), -1);
    });
  });

  group('BinarySearch.lowerBound', () {
    test('con duplicados devuelve el primero', () {
      expect(BinarySearch.lowerBound([1, 2, 2, 2, 3], _target(2)), 1);
    });

    test('objetivo mayor que todos devuelve la longitud', () {
      expect(BinarySearch.lowerBound(_numbers, _target(100)), _numbers.length);
    });

    test('lista vacía devuelve 0', () {
      expect(BinarySearch.lowerBound(<int>[], _target(1)), 0);
    });
  });

  group('BinarySearch.withPrefix', () {
    test('varias coincidencias', () {
      expect(BinarySearch.withPrefix(_words, 'bmw', _identity), [
        'bmw',
        'bmwx',
        'bmwz',
      ]);
    });

    test('ninguna coincidencia', () {
      expect(BinarySearch.withPrefix(_words, 'zzz', _identity), isEmpty);
    });

    test('prefijo vacío devuelve todo', () {
      expect(BinarySearch.withPrefix(_words, '', _identity), _words);
    });

    test('lista vacía', () {
      expect(BinarySearch.withPrefix(<String>[], 'a', _identity), isEmpty);
    });
  });
}
