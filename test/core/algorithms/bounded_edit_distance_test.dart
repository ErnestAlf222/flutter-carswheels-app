import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BoundedEditDistance', () {
    test('cadenas iguales: distancia 0, incluso vacías', () {
      expect(BoundedEditDistance.between('ferrari', 'ferrari', 2), 0);
      expect(BoundedEditDistance.between('', '', 0), 0);
    });

    test('una inserción, un borrado y una sustitución cuestan 1', () {
      expect(BoundedEditDistance.between('ferari', 'ferrari', 2), 1);
      expect(BoundedEditDistance.between('toyota', 'toyta', 2), 1);
      expect(BoundedEditDistance.between('camry', 'camri', 2), 1);
    });

    test('una transposición adyacente cuesta 1 (Damerau)', () {
      expect(BoundedEditDistance.between('ab', 'ba', 1), 1);
      expect(BoundedEditDistance.between('toyota', 'toyoat', 1), 1);
      expect(BoundedEditDistance.between('civic', 'cviic', 2), 1);
    });

    test('contra una cadena vacía es el largo de la otra', () {
      expect(BoundedEditDistance.between('', 'abc', 3), 3);
      expect(BoundedEditDistance.between('abc', '', 3), 3);
      expect(BoundedEditDistance.between('abc', '', 2), isNull);
    });

    test('devuelve nulo si supera el tope', () {
      expect(BoundedEditDistance.between('ford', 'ferrari', 2), isNull);
      expect(BoundedEditDistance.between('abc', 'xyz', 2), isNull);
      expect(BoundedEditDistance.between('abc', 'xyz', 3), 3);
    });

    test('el tope es inclusivo y un tope negativo nunca coincide', () {
      expect(BoundedEditDistance.between('corola', 'corolla', 1), 1);
      expect(BoundedEditDistance.between('corola', 'corolla', 0), isNull);
      expect(BoundedEditDistance.between('a', 'a', -1), isNull);
    });

    test('la diferencia de largo mayor al tope descarta sin calcular', () {
      expect(BoundedEditDistance.between('a', 'abcd', 2), isNull);
    });

    test('es simétrica', () {
      expect(
        BoundedEditDistance.between('mustang', 'mustnag', 2),
        BoundedEditDistance.between('mustnag', 'mustang', 2),
      );
    });
  });

  group('CircularIndex', () {
    test('wrap, pageCount, next e initialPage', () {
      expect(CircularIndex.wrap(-1, 5), 4);
      expect(CircularIndex.wrap(5003, 5), 3);
      expect(CircularIndex.wrap(7, 1), 0);
      expect(CircularIndex.pageCount(1), 1);
      expect(CircularIndex.pageCount(2), isNull);
      expect(CircularIndex.next(4, 5), 0);
      expect(CircularIndex.next(0, 1), 0);
      expect(CircularIndex.wrap(CircularIndex.initialPage(3, 5), 5), 3);
    });
  });
}
