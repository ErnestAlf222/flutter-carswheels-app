import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/search_test_support.dart';

void main() {
  final entries = [
    const SearchEntryEntity(brand: 'Toyota'),
    groupEntry('Toyota', 'Camry'),
    groupEntry('Toyota', 'Corolla'),
    groupEntry('Ford', 'F-150'),
    groupEntry('Mazda', 'CX-5'),
    groupEntry('Mazda', 'Mazda3'),
    groupEntry('BMW', 'X5'),
  ];
  final index = SearchIndex.build(entries, postingSort);

  List<String> names(List<String> tokens) => [
    for (final entry in index.match(tokens))
      '${entry.brand}/${entry.groupName ?? '-'}',
  ];

  test('prefijo de un token', () {
    expect(names(['cam']), ['Toyota/Camry']);
    expect(names(['cor']), ['Toyota/Corolla']);
  });

  test('un token de marca trae la marca y sus grupos', () {
    expect(names(['toyota']), ['Toyota/-', 'Toyota/Camry', 'Toyota/Corolla']);
  });

  test('guiones: f150, 150 y f encuentran F-150', () {
    expect(names(['f150']), ['Ford/F-150']);
    expect(names(['150']), ['Ford/F-150']);
    expect(names(['cx5']), ['Mazda/CX-5']);
  });

  test('varios tokens se intersectan', () {
    expect(names(['toyota', 'cam']), ['Toyota/Camry']);
    expect(names(['mazda', 'cx']), ['Mazda/CX-5']);
  });

  test('sin resultados', () {
    expect(names(['zzzz']), isEmpty);
    expect(names(['toyota', 'f150']), isEmpty);
    expect(names([]), isEmpty);
  });

  test('el índice vacío no encuentra nada', () {
    expect(SearchIndex.empty.match(['a']), isEmpty);
  });

  group('SearchCatalogUseCase', () {
    final store = SearchIndexStore()
      ..save(
        usScope.key,
        SearchIndexRecord(
          index: index,
          status: const SearchIndexStatusEntity.ready(totalBrands: 4),
        ),
      );
    final useCase = SearchCatalogUseCase(
      store: store,
      ranker: const SearchResultRanker(sortStrategy: rankedSort),
    );

    test('consulta bajo el mínimo no busca', () {
      expect(TextNormalizer.normalize('x').length, lessThan(2));
      expect(useCase(usScope, 'x'), isEmpty);
      expect(useCase(usScope, '  '), isEmpty);
    });

    test('con el mínimo busca', () {
      expect(useCase(usScope, 'x5').single.brand, 'BMW');
    });

    test('sin índice para el alcance devuelve vacío', () {
      expect(useCase(mxScope, 'camry'), isEmpty);
    });
  });
}
