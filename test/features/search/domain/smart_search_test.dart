import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/search_test_support.dart';

const Map<String, List<String>> _catalog = {
  'Audi': ['A3', 'A4', 'Q5'],
  'Ferrari': ['296 GTB', 'Roma', 'F8 Tributo'],
  'Ford': ['F-150', 'Mustang', 'Focus'],
  'Toyota': ['Camry', 'Corolla', 'RAV4'],
  'Honda': ['Accord', 'Civic'],
};

Future<SearchHarness> _indexed({
  Map<String, List<String>> groups = _catalog,
  SearchScopeEntity scope = usScope,
}) async {
  final harness = SearchHarness(groupsByBrand: groups);
  await harness.build(scope).drain<void>();
  return harness;
}

SearchWithScopeUseCase _search(SearchHarness harness) => SearchWithScopeUseCase(
  store: harness.store,
  ranker: const SearchResultRanker(sortStrategy: rankedSort),
);

SuggestSearchTermsUseCase _suggest(SearchHarness harness) =>
    SuggestSearchTermsUseCase(
      store: harness.store,
      sortStrategy: suggestionSort,
    );

void main() {
  group('búsqueda con alcance suave', () {
    test('sin alcance: todo va en primary, igual que antes', () async {
      final harness = await _indexed();
      final response = _search(harness)(usScope, 'cor');
      expect([for (final r in response.primary) r.groupName], ['Corolla']);
      expect(response.others, isEmpty);
      final plain = SearchCatalogUseCase(
        store: harness.store,
        ranker: const SearchResultRanker(sortStrategy: rankedSort),
      )(usScope, 'fo');
      expect(_search(harness)(usScope, 'fo').primary, plain);
    });

    test('alcance Audi y "ferrari": nada dentro, los Ferrari fuera', () async {
      final harness = await _indexed();
      final response = _search(harness)(usScope, 'ferrari', scopeBrand: 'Audi');
      expect(response.primary, isEmpty);
      expect(response.others, isNotEmpty);
      expect(response.others.every((r) => r.brand == 'Ferrari'), isTrue);
      expect(response.isEmpty, isFalse);
    });

    test('texto que cruza marcas separa dentro y fuera de la marca', () async {
      final harness = await _indexed(
        groups: {
          'Toyota': ['Corolla', 'Corolla Cross'],
          'Honda': ['Corvette X'],
        },
      );
      final response = _search(harness)(usScope, 'cor', scopeBrand: 'Toyota');
      expect(
        [for (final r in response.primary) r.groupName],
        ['Corolla', 'Corolla Cross'],
      );
      expect([for (final r in response.others) r.groupName], ['Corvette X']);
      // Sin el alcance son las mismas tres coincidencias, todas en primary.
      expect(_search(harness)(usScope, 'cor').primary, hasLength(3));
    });

    test('el total no supera el tope de resultados', () async {
      final harness = await _indexed(
        groups: {
          'Toyota': [for (int i = 0; i < 40; i++) 'Modelo A$i'],
          'Honda': [for (int i = 0; i < 40; i++) 'Modelo B$i'],
        },
      );
      final response = _search(harness)(
        usScope,
        'modelo',
        scopeBrand: 'Toyota',
      );
      expect(response.primary, hasLength(40));
      expect(response.others, hasLength(SearchConfig.maxResults - 40));
    });

    test('marcas coincidentes por prefijo, sin la marca del alcance', () async {
      final harness = await _indexed();
      final response = _search(harness)(usScope, 'ferrari');
      expect(response.brandMatches, ['Ferrari']);
      // Los modelos de la marca también salen como coincidencia por marca.
      expect(response.primary.map((r) => r.brand).toSet(), {'Ferrari'});
      expect(response.primary, hasLength(3));
      final scoped = _search(harness)(
        usScope,
        'ferrari',
        scopeBrand: 'Ferrari',
      );
      expect(scoped.brandMatches, isEmpty);
    });

    test(
      'muchas marcas coinciden: tope de config y la exacta primero',
      () async {
        final harness = await _indexed(
          groups: {
            'Mazda': ['Tres'],
            'Maserati': ['Ghibli'],
            'Maybach': ['Clase S'],
            'McLaren': ['Siete'],
            'Ma': ['Equis'],
          },
        );
        final response = _search(harness)(usScope, 'ma');
        expect(response.brandMatches, hasLength(SearchConfig.maxBrandMatches));
        expect(response.brandMatches.first, 'Ma');
      },
    );

    test('con texto menor al mínimo o sin índice, vacío', () async {
      final harness = await _indexed();
      expect(_search(harness)(usScope, 'f').isEmpty, isTrue);
      expect(_search(harness)(mxScope, 'ferrari').isEmpty, isTrue);
    });
  });

  group('sugerencias por distancia de edición', () {
    test('"ferari" sugiere ferrari', () async {
      final harness = await _indexed();
      expect(_suggest(harness)(usScope, 'ferari'), ['ferrari']);
    });

    test('"corola" (6 letras, tope 2) sugiere corolla', () async {
      final harness = await _indexed();
      expect(_suggest(harness)(usScope, 'corola'), ['corolla']);
    });

    test('"camri" sugiere camry y "toyta" sugiere toyota', () async {
      final harness = await _indexed();
      expect(_suggest(harness)(usScope, 'camri'), ['camry']);
      expect(_suggest(harness)(usScope, 'toyta'), ['toyota']);
    });

    test('"f150" existe: no hay nada que sugerir', () async {
      final harness = await _indexed();
      expect(_search(harness)(usScope, 'f150').primary, isNotEmpty);
      expect(_suggest(harness)(usScope, 'f150'), isEmpty);
    });

    test(
      'con varias palabras corrige la que falla y conserva las demás',
      () async {
        final harness = await _indexed();
        expect(_suggest(harness)(usScope, 'ford mustnag'), ['ford mustang']);
      },
    );

    test('máximo 2 sugerencias, de la más cercana a la más lejana', () async {
      final harness = await _indexed(
        groups: {
          'Marca': ['Casa', 'Cosa', 'Cesa', 'Cusa'],
        },
      );
      final suggestions = _suggest(harness)(usScope, 'cisa');
      expect(suggestions, hasLength(SearchConfig.maxSuggestions));
      expect(suggestions, ['casa', 'cesa']);
    });

    test('una candidata más lejana que la mejor no se ofrece', () async {
      final harness = await _indexed(
        groups: {
          'Ferrari': ['Roma'],
          'GMC': ['Terrain'],
        },
      );
      // "terrain" está a distancia 2 de "ferari", pero "ferrari" está a 1.
      expect(_suggest(harness)(usScope, 'ferari'), ['ferrari']);
    });

    test('el tope depende del largo: 1 hasta 5 letras, 2 desde 6', () {
      expect(SuggestSearchTermsUseCase.maxDistanceFor(5), 1);
      expect(SuggestSearchTermsUseCase.maxDistanceFor(6), 2);
    });

    test(
      'lejos del vocabulario, muy corto o sin índice: sin sugerencias',
      () async {
        final harness = await _indexed();
        expect(_suggest(harness)(usScope, 'zzzzzz'), isEmpty);
        expect(_suggest(harness)(usScope, 'xy'), isEmpty);
        expect(_suggest(harness)(mxScope, 'ferari'), isEmpty);
      },
    );
  });

  group('años cercanos', () {
    const selector = NearestYearsSelector(sortStrategy: yearSort);

    test('los más cercanos, sin el vigente y con el reciente en empate', () {
      expect(
        selector.select(
          available: [2027, 2026, 2025, 2024, 2023, 2022],
          currentYear: 2025,
        ),
        [2026, 2024, 2027],
      );
    });

    test('con pocos años devuelve los que hay (México)', () {
      expect(selector.select(available: [2026, 2025], currentYear: 2025), [
        2026,
      ]);
      expect(selector.select(available: [2025], currentYear: 2025), isEmpty);
    });

    test('respeta la cantidad pedida y no repite', () {
      expect(
        selector.select(
          available: [2027, 2027, 2026, 2025],
          currentYear: 2027,
          count: 1,
        ),
        [2026],
      );
    });
  });
}
