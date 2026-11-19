import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/search_test_support.dart';

void main() {
  late FakeRecentSearches datasource;
  late AddRecentSearchUseCase add;
  late GetRecentSearchesUseCase list;
  late int tick;

  setUp(() {
    datasource = FakeRecentSearches();
    tick = 0;
    add = AddRecentSearchUseCase(
      datasource: datasource,
      clock: () => DateTime.fromMillisecondsSinceEpoch(++tick * 1000),
    );
    list = GetRecentSearchesUseCase(datasource);
  });

  Future<List<String>> texts() async => [
    for (final search in await list()) search.text,
  ];

  test('agrega y lista la más reciente primero', () async {
    await add('camry');
    await add('f-150');
    expect(await texts(), ['f-150', 'camry']);
  });

  test('un duplicado (con otras mayúsculas) sube al inicio', () async {
    await add('camry');
    await add('corolla');
    await add('  CAMRY ');
    expect(await texts(), ['CAMRY', 'corolla']);
  });

  test('respeta el máximo y descarta la más antigua', () async {
    for (final i in List.generate(
      SearchConfig.maxRecentSearches + 3,
      (i) => i,
    )) {
      await add('busqueda$i');
    }
    final current = await texts();
    expect(current, hasLength(SearchConfig.maxRecentSearches));
    expect(current.first, 'busqueda${SearchConfig.maxRecentSearches + 2}');
    expect(current, isNot(contains('busqueda0')));
  });

  test('bajo el mínimo de caracteres no se guarda', () async {
    expect(await add('x'), isFalse);
    expect(await add(' - '), isFalse);
    expect(await texts(), isEmpty);
    expect(await add('x5'), isTrue);
  });

  test('borra una y borra todas', () async {
    await add('camry');
    await add('corolla');
    await RemoveRecentSearchUseCase(datasource)('camry');
    expect(await texts(), ['corolla']);
    await ClearRecentSearchesUseCase(datasource)();
    expect(await texts(), isEmpty);
  });
}
