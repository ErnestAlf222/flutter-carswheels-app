import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/search_test_support.dart';

void main() {
  const ranker = SearchResultRanker(sortStrategy: rankedSort);

  List<String> rank(List<SearchEntryEntity> matches, String query) => [
    for (final result in ranker.rank(
      matches: matches,
      query: query,
      scope: usScope,
    ))
      '${result.brand}/${result.groupName ?? '-'}',
  ];

  test('exacto, luego prefijo, luego marca; alfabético dentro del nivel', () {
    final matches = [
      groupEntry('Zeta', 'Camry Hybrid'),
      const SearchEntryEntity(brand: 'Camry Motors'),
      groupEntry('Beta', 'Camry'),
      groupEntry('Alfa', 'Camryx'),
      groupEntry('Camry Motors', 'Zephyr'),
      groupEntry('Alfa', 'Camry'),
    ];
    expect(rank(matches, 'camry'), [
      'Alfa/Camry',
      'Beta/Camry',
      'Alfa/Camryx',
      'Zeta/Camry Hybrid',
      'Camry Motors/-',
      'Camry Motors/Zephyr',
    ]);
  });

  test('la coincidencia por marca queda después de los grupos', () {
    final matches = [
      groupEntry('Toyota', 'Avalon'),
      groupEntry('Toyota', 'Camry'),
      groupEntry('Camry', 'Toyota Special'),
    ];
    expect(rank(matches, 'toyota cam'), [
      'Camry/Toyota Special',
      'Toyota/Avalon',
      'Toyota/Camry',
    ]);
  });

  test('el orden alfabético ignora acentos y mayúsculas', () {
    final matches = [
      groupEntry('Citroën', 'C3'),
      groupEntry('Citroen', 'C3'),
      groupEntry('audi', 'A3'),
    ];
    expect(rank(matches, 'x'), ['audi/A3', 'Citroen/C3', 'Citroën/C3']);
  });

  test('corta en el máximo de resultados', () {
    final matches = [
      for (final i in List.generate(SearchConfig.maxResults + 10, (i) => i))
        groupEntry('Marca', 'Modelo ${i.toString().padLeft(3, '0')}'),
    ];
    final results = ranker.rank(
      matches: matches,
      query: 'modelo',
      scope: usScope,
    );
    expect(results, hasLength(SearchConfig.maxResults));
    expect(results.first.groupName, 'Modelo 000');
    expect(results.first.year, usScope.year);
    expect(results.first.marketCode, 'us');
  });
}
