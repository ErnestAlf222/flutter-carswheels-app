import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('consulta: minúsculas, sin acentos y un token por palabra', () {
    expect(SearchTokenizer.queryTokens('  Citroën  C3 '), ['citroen', 'c3']);
  });

  test('consulta: los guiones se quitan (F-150 y CX-5)', () {
    expect(SearchTokenizer.queryTokens('F-150'), ['f150']);
    expect(SearchTokenizer.queryTokens('cx-5'), ['cx5']);
  });

  test('consulta: sin repetidos ni vacíos', () {
    expect(SearchTokenizer.queryTokens('toyota Toyota'), ['toyota']);
    expect(SearchTokenizer.queryTokens('   '), isEmpty);
  });

  test('índice: palabra entera y partes con guion', () {
    expect(SearchTokenizer.indexTokens('Ford F-150'), {
      'ford',
      'f150',
      'f',
      '150',
    });
    expect(SearchTokenizer.indexTokens('Mazda CX-5'), {
      'mazda',
      'cx5',
      'cx',
      '5',
    });
  });

  test('índice: acentos y mayúsculas se normalizan', () {
    expect(SearchTokenizer.indexTokens('Citroën Ë-C4'), contains('citroen'));
  });
}
