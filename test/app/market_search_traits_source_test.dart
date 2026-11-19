import 'package:cars_wheels_app/app/search_results/market_search_traits_source.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockResolve extends Mock implements ResolveGroupSummaryUseCase {}

GroupSummaryEntity _summary({
  List<EngineKind> kinds = const [],
  bool electric = false,
  bool plugin = false,
  double? maxKm,
}) => GroupSummaryEntity(
  vehicleClass: null,
  minKmPerLiter: maxKm,
  maxKmPerLiter: maxKm,
  hasElectric: electric,
  hasPluginHybrid: plugin,
  variantCount: 1,
  engineKinds: kinds,
);

const SearchResultEntity _camry = SearchResultEntity(
  brand: 'Toyota',
  groupName: 'Camry',
  year: 2026,
  marketCode: 'us',
  variantNames: ['Camry LE', 'Camry XSE'],
);

void main() {
  group('mapeo de motorización', () {
    SearchResultTraitsEntity map(GroupSummaryEntity summary) =>
        MarketSearchTraitsSource.traitsOfSummary(summary);

    test('cada tipo cae en su opción', () {
      expect(map(_summary(kinds: [EngineKind.electric])).engines, {
        SearchEngineOption.electric,
      });
      expect(map(_summary(kinds: [EngineKind.hybrid])).engines, {
        SearchEngineOption.hybrid,
      });
      expect(map(_summary(kinds: [EngineKind.pluginHybrid])).engines, {
        SearchEngineOption.pluginHybrid,
      });
    });

    test('gasolina, diésel y flexible son combustión', () {
      for (final kind in [
        EngineKind.gasoline,
        EngineKind.diesel,
        EngineKind.flexFuel,
      ]) {
        expect(map(_summary(kinds: [kind])).engines, {
          SearchEngineOption.combustion,
        });
      }
    });

    test('un grupo mixto contiene varias opciones sin repetir', () {
      final traits = map(
        _summary(
          kinds: [EngineKind.hybrid, EngineKind.diesel, EngineKind.gasoline],
          maxKm: 18,
        ),
      );
      expect(traits.engines, {
        SearchEngineOption.hybrid,
        SearchEngineOption.combustion,
      });
      expect(traits.maxKmPerLiter, 18);
    });

    test('el hidrógeno no entra a ninguna opción', () {
      expect(map(_summary(kinds: [EngineKind.hydrogen])).engines, isEmpty);
    });

    test('sin tipos usa las banderas de los resúmenes antiguos', () {
      expect(map(_summary(electric: true, plugin: true)).engines, {
        SearchEngineOption.electric,
        SearchEngineOption.pluginHybrid,
      });
    });

    test('sin ningún dato no se inventa motorización ni consumo', () {
      final traits = map(_summary());
      expect(traits.engines, isEmpty);
      expect(traits.maxKmPerLiter, isNull);
    });

    test('un eléctrico no trae consumo', () {
      expect(map(_summary(kinds: [EngineKind.electric])).maxKmPerLiter, isNull);
    });
  });

  group('fuente de rasgos', () {
    setUp(() {
      registerFallbackValue(const <String>[]);
    });

    test('pide el resumen con el mismo caso de uso que las tarjetas', () async {
      final resolve = _MockResolve();
      when(
        () => resolve(
          year: any(named: 'year'),
          brand: any(named: 'brand'),
          groupName: any(named: 'groupName'),
          variantNames: any(named: 'variantNames'),
        ),
      ).thenAnswer(
        (_) async => _summary(kinds: [EngineKind.gasoline], maxKm: 14),
      );
      final traits = await MarketSearchTraitsSource(resolve).traitsOf(_camry);
      expect(traits.engines, {SearchEngineOption.combustion});
      expect(traits.maxKmPerLiter, 14);
      verify(
        () => resolve(
          year: 2026,
          brand: 'Toyota',
          groupName: 'Camry',
          variantNames: ['Camry LE', 'Camry XSE'],
        ),
      ).called(1);
    });

    test('sin resumen devuelve "sin dato" y un fallo se propaga', () async {
      final resolve = _MockResolve();
      when(
        () => resolve(
          year: any(named: 'year'),
          brand: any(named: 'brand'),
          groupName: any(named: 'groupName'),
          variantNames: any(named: 'variantNames'),
        ),
      ).thenAnswer((_) async => null);
      final source = MarketSearchTraitsSource(resolve);
      expect(await source.traitsOf(_camry), SearchResultTraitsEntity.unknown);
      when(
        () => resolve(
          year: any(named: 'year'),
          brand: any(named: 'brand'),
          groupName: any(named: 'groupName'),
          variantNames: any(named: 'variantNames'),
        ),
      ).thenThrow(StateError('sin red'));
      expect(source.traitsOf(_camry), throwsStateError);
    });

    test('un resultado solo de marca no pide nada', () async {
      final resolve = _MockResolve();
      const brandOnly = SearchResultEntity(
        brand: 'Toyota',
        year: 2026,
        marketCode: 'us',
      );
      expect(
        await MarketSearchTraitsSource(resolve).traitsOf(brandOnly),
        SearchResultTraitsEntity.unknown,
      );
      verifyZeroInteractions(resolve);
    });
  });
}
