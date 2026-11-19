import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/search_test_support.dart';

SearchResultEntity _result(String brand, String group) => SearchResultEntity(
  brand: brand,
  groupName: group,
  year: 2026,
  marketCode: 'us',
);

const SearchFilterService _service = SearchFilterService(
  sortStrategy: resultSort,
);

final SearchResultEntity _camry = _result('Toyota', 'Camry');
final SearchResultEntity _prius = _result('Toyota', 'Prius');
final SearchResultEntity _bz4x = _result('Toyota', 'bZ4X');
final SearchResultEntity _civic = _result('Honda', 'Civic');
final SearchResultEntity _accord = _result('Honda', 'Accord');
final SearchResultEntity _ioniq = _result('Hyundai', 'Ioniq');
final List<SearchResultEntity> _all = [
  _camry,
  _prius,
  _bz4x,
  _civic,
  _accord,
  _ioniq,
];

// Gasolina 14, híbrido y gasolina (mixto) 25, eléctrico sin consumo,
// gasolina 12, sin dato de motorización, enchufable con consumo 20.
final Map<String, SearchResultTraitsEntity> _traits = {
  _camry.traitsKey: const SearchResultTraitsEntity(
    engines: {SearchEngineOption.combustion},
    maxKmPerLiter: 14,
  ),
  _prius.traitsKey: const SearchResultTraitsEntity(
    engines: {SearchEngineOption.hybrid, SearchEngineOption.combustion},
    maxKmPerLiter: 25,
  ),
  _bz4x.traitsKey: const SearchResultTraitsEntity(
    engines: {SearchEngineOption.electric},
  ),
  _civic.traitsKey: const SearchResultTraitsEntity(
    engines: {SearchEngineOption.combustion},
    maxKmPerLiter: 12,
  ),
  _accord.traitsKey: SearchResultTraitsEntity.unknown,
  _ioniq.traitsKey: const SearchResultTraitsEntity(
    engines: {SearchEngineOption.pluginHybrid},
    maxKmPerLiter: 20,
  ),
};

List<String> _names(List<SearchResultEntity> results) => [
  for (final result in results) result.groupName!,
];

void main() {
  group('conteos de motorización', () {
    test('un grupo mixto cuenta en cada opción que contiene', () {
      final counts = _service.engineCounts(
        _all,
        SearchFiltersEntity.none,
        _traits,
      );
      expect(counts[SearchEngineOption.combustion], 3);
      expect(counts[SearchEngineOption.hybrid], 1);
      expect(counts[SearchEngineOption.electric], 1);
      expect(counts[SearchEngineOption.pluginHybrid], 1);
    });

    test('un resultado sin dato no entra a ninguna opción', () {
      final counts = _service.engineCounts(
        [_accord],
        SearchFiltersEntity.none,
        _traits,
      );
      expect(counts.values, everyElement(0));
    });

    test('un resultado sin analizar no cuenta', () {
      final counts = _service.engineCounts(_all, SearchFiltersEntity.none, {});
      expect(counts.values, everyElement(0));
    });

    test('se calculan con el filtro de marcas aplicado', () {
      const filters = SearchFiltersEntity(brands: {'Honda'});
      final counts = _service.engineCounts(_all, filters, _traits);
      expect(counts[SearchEngineOption.combustion], 1);
      expect(counts[SearchEngineOption.hybrid], 0);
      expect(counts[SearchEngineOption.electric], 0);
    });

    test('las opciones disponibles son solo las que existen', () {
      final available = _service.availableEngines(_all, _traits);
      expect(available, SearchEngineOption.values.toSet());
      expect(_service.availableEngines([_camry, _civic], _traits), {
        SearchEngineOption.combustion,
      });
    });
  });

  group('conteos de marca', () {
    test('cuentan resultados por marca', () {
      final counts = _service.brandCounts(
        _all,
        SearchFiltersEntity.none,
        _traits,
      );
      expect(counts, {'Toyota': 3, 'Honda': 2, 'Hyundai': 1});
    });

    test('se calculan con el filtro de motorización aplicado', () {
      const filters = SearchFiltersEntity(
        engines: {SearchEngineOption.combustion},
      );
      final counts = _service.brandCounts(_all, filters, _traits);
      // Accord (sin dato) y Ioniq (enchufable) quedan fuera.
      expect(counts, {'Toyota': 2, 'Honda': 1});
      expect(counts.containsKey('Hyundai'), isFalse);
    });
  });

  group('aplicar filtros', () {
    test('sin filtros devuelve todo en el mismo orden', () {
      expect(
        _service.apply(_all, SearchFiltersEntity.none, _traits),
        orderedEquals(_all),
      );
    });

    test('motorización múltiple es una unión', () {
      const filters = SearchFiltersEntity(
        engines: {SearchEngineOption.electric, SearchEngineOption.pluginHybrid},
      );
      expect(_names(_service.apply(_all, filters, _traits)), ['bZ4X', 'Ioniq']);
    });

    test('motorización y marca se combinan', () {
      const filters = SearchFiltersEntity(
        engines: {SearchEngineOption.combustion},
        brands: {'Toyota'},
      );
      expect(_names(_service.apply(_all, filters, _traits)), [
        'Camry',
        'Prius',
      ]);
    });

    test('con filtro de motorización lo no analizado o sin dato se oculta', () {
      const filters = SearchFiltersEntity(
        engines: {SearchEngineOption.combustion},
      );
      final partial = {_camry.traitsKey: _traits[_camry.traitsKey]!};
      expect(_names(_service.apply(_all, filters, partial)), ['Camry']);
      expect(_service.apply([_accord], filters, _traits), isEmpty);
    });

    test('solo con filtro de marca no hace falta analizar', () {
      const filters = SearchFiltersEntity(brands: {'Honda'});
      expect(_names(_service.apply(_all, filters, {})), ['Civic', 'Accord']);
    });

    test('con filtros que no dejan nada, el resultado es vacío', () {
      const filters = SearchFiltersEntity(
        engines: {SearchEngineOption.electric},
        brands: {'Honda'},
      );
      expect(_service.apply(_all, filters, _traits), isEmpty);
    });

    test('cuenta cuántos faltan por analizar con el filtro de marcas', () {
      const filters = SearchFiltersEntity(brands: {'Toyota'});
      final partial = {_camry.traitsKey: _traits[_camry.traitsKey]!};
      expect(_service.unanalyzedCount(_all, filters, partial), 2);
      expect(
        _service.unanalyzedCount(_all, SearchFiltersEntity.none, partial),
        5,
      );
      expect(_service.unanalyzedCount(_all, filters, _traits), 0);
    });
  });

  group('orden', () {
    test('A–Z ordena por nombre sin distinguir tildes ni mayúsculas', () {
      const filters = SearchFiltersEntity(sort: SearchSortOrder.alphabetical);
      expect(_names(_service.apply(_all, filters, _traits)), [
        'Accord',
        'bZ4X',
        'Camry',
        'Civic',
        'Ioniq',
        'Prius',
      ]);
    });

    test(
      'más eficiente: mayor a menor y sin dato al final, en orden original',
      () {
        const filters = SearchFiltersEntity(
          sort: SearchSortOrder.mostEfficient,
        );
        // bZ4X (eléctrico) y Accord (sin dato) van al final como estaban.
        expect(_names(_service.apply(_all, filters, _traits)), [
          'Prius',
          'Ioniq',
          'Camry',
          'Civic',
          'bZ4X',
          'Accord',
        ]);
      },
    );

    test('más eficiente: lo no analizado va al final, nunca como cero', () {
      const filters = SearchFiltersEntity(sort: SearchSortOrder.mostEfficient);
      final partial = {_civic.traitsKey: _traits[_civic.traitsKey]!};
      expect(
        _names(_service.apply([_camry, _civic, _prius], filters, partial)),
        ['Civic', 'Camry', 'Prius'],
      );
    });

    test('el orden y los filtros se combinan', () {
      const filters = SearchFiltersEntity(
        engines: {SearchEngineOption.combustion},
        sort: SearchSortOrder.mostEfficient,
      );
      expect(_names(_service.apply(_all, filters, _traits)), [
        'Prius',
        'Camry',
        'Civic',
      ]);
    });
  });

  group('filtros activos', () {
    test('cuenta opciones elegidas y el orden', () {
      const filters = SearchFiltersEntity(
        engines: {SearchEngineOption.electric, SearchEngineOption.hybrid},
        brands: {'Toyota'},
        sort: SearchSortOrder.alphabetical,
      );
      expect(filters.activeCount, 4);
      expect(SearchFiltersEntity.none.activeCount, 0);
      expect(SearchFiltersEntity.none.isActive, isFalse);
    });

    test('solo motorización o eficiencia necesitan el análisis', () {
      expect(
        const SearchFiltersEntity(brands: {'Toyota'}).needsTraits,
        isFalse,
      );
      expect(
        const SearchFiltersEntity(sort: SearchSortOrder.alphabetical)
            .needsTraits,
        isFalse,
      );
      expect(
        const SearchFiltersEntity(sort: SearchSortOrder.mostEfficient)
            .needsTraits,
        isTrue,
      );
      expect(
        const SearchFiltersEntity(engines: {SearchEngineOption.electric})
            .needsTraits,
        isTrue,
      );
    });
  });
}
