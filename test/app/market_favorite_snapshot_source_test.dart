import 'package:cars_wheels_app/app/favorites/market_favorite_snapshot_source.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/favorites_test_support.dart';

class _MockGroups extends Mock implements GetModelGroupsUseCase {}

class _MockSummary extends Mock implements ResolveGroupSummaryUseCase {}

class _MockPhoto extends Mock implements ResolveModelPhotoUseCase {}

const PhotoEntity _photo = PhotoEntity(
  thumbnailUrl: 'https://ejemplo.test/camry.jpg',
  authorName: 'Ana',
  licenseName: 'CC BY-SA 4.0',
  sourceUrl: 'https://ejemplo.test/origen',
  isReference: true,
  aspectRatio: 1.5,
);

void main() {
  late _MockGroups groups;
  late _MockSummary summary;
  late _MockPhoto photo;
  late Market market;

  MarketFavoriteSnapshotSource source() => MarketFavoriteSnapshotSource(
    getModelGroups: groups,
    resolveGroupSummary: summary,
    resolveModelPhoto: photo,
    classTranslator: const VehicleClassTranslator(),
    currentMarket: () => market,
  );

  void answerSummary(GroupSummaryEntity? value) => when(
    () => summary(
      year: any(named: 'year'),
      brand: any(named: 'brand'),
      groupName: any(named: 'groupName'),
      variantNames: any(named: 'variantNames'),
    ),
  ).thenAnswer((_) async => value);

  setUp(() {
    groups = _MockGroups();
    summary = _MockSummary();
    photo = _MockPhoto();
    market = Market.unitedStates;
    when(() => groups(any(), any())).thenAnswer(
      (_) async => const [
        ModelGroupEntity(
          name: 'Camry',
          variants: [
            ModelEntity(name: 'Camry LE'),
            ModelEntity(name: 'Camry XSE'),
          ],
        ),
      ],
    );
    when(
      () => photo(
        brand: any(named: 'brand'),
        modelName: any(named: 'modelName'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async => _photo);
  });

  test(
    'EE. UU.: clase traducida, motorización, consumo, variantes y foto',
    () async {
      answerSummary(
        const GroupSummaryEntity(
          vehicleClass: 'Midsize Cars',
          minKmPerLiter: 12.5,
          maxKmPerLiter: 15,
          hasElectric: false,
          hasPluginHybrid: false,
          variantCount: 2,
          engineKinds: [EngineKind.hybrid, EngineKind.gasoline],
        ),
      );
      final snapshot = await source().snapshotOf(favoriteIdentity());
      expect(snapshot, isNotNull);
      expect(
        snapshot!.label,
        const VehicleClassTranslator().labelFor('Midsize Cars'),
      );
      expect(snapshot.label, isNotNull);
      // Los tipos de motorización se guardan por nombre.
      expect(snapshot.engineKinds, ["hybrid", "gasoline"]);
      expect(snapshot.minKmPerLiter, 12.5);
      expect(snapshot.maxKmPerLiter, 15);
      expect(snapshot.variantNames, ['Camry LE', 'Camry XSE']);
      expect(snapshot.photo!.thumbnailUrl, 'https://ejemplo.test/camry.jpg');
      expect(snapshot.photo!.authorName, 'Ana');
      expect(snapshot.photo!.licenseName, 'CC BY-SA 4.0');
      expect(snapshot.photo!.sourceUrl, 'https://ejemplo.test/origen');
      expect(snapshot.photo!.isReference, isTrue);
    },
  );

  test('México: el combustible ya traducido va como etiqueta', () async {
    market = Market.mexico;
    answerSummary(
      const GroupSummaryEntity(
        vehicleClass: null,
        minKmPerLiter: 16,
        maxKmPerLiter: 16,
        hasElectric: false,
        hasPluginHybrid: false,
        variantCount: 2,
        engineKinds: [EngineKind.gasoline],
        fuelLabel: 'Gasolina',
      ),
    );
    final snapshot = await source().snapshotOf(
      favoriteIdentity(marketCode: 'mx'),
    );
    expect(snapshot!.label, 'Gasolina');
  });

  test('sin consumo de combustión los km/l quedan nulos, no cero', () async {
    answerSummary(
      const GroupSummaryEntity(
        vehicleClass: 'Midsize Cars',
        minKmPerLiter: null,
        maxKmPerLiter: null,
        hasElectric: true,
        hasPluginHybrid: false,
        variantCount: 1,
        engineKinds: [EngineKind.electric],
      ),
    );
    final snapshot = await source().snapshotOf(favoriteIdentity());
    expect(snapshot!.minKmPerLiter, isNull);
    expect(snapshot.maxKmPerLiter, isNull);
    expect(snapshot.engineKinds, ['electric']);
  });

  test(
    'si falla el resumen se guardan las demás partes, sin inventar',
    () async {
      when(
        () => summary(
          year: any(named: 'year'),
          brand: any(named: 'brand'),
          groupName: any(named: 'groupName'),
          variantNames: any(named: 'variantNames'),
        ),
      ).thenThrow(const NetworkFailure('sin red'));
      final snapshot = await source().snapshotOf(favoriteIdentity());
      expect(snapshot!.label, isNull);
      expect(snapshot.engineKinds, isEmpty);
      expect(snapshot.minKmPerLiter, isNull);
      expect(snapshot.variantNames, ['Camry LE', 'Camry XSE']);
      expect(snapshot.photo, isNotNull);
    },
  );

  test('si falla la foto el resumen se guarda igual', () async {
    answerSummary(
      const GroupSummaryEntity(
        vehicleClass: 'Midsize Cars',
        minKmPerLiter: 12,
        maxKmPerLiter: 14,
        hasElectric: false,
        hasPluginHybrid: false,
        variantCount: 1,
      ),
    );
    when(
      () => photo(
        brand: any(named: 'brand'),
        modelName: any(named: 'modelName'),
        year: any(named: 'year'),
      ),
    ).thenThrow(const NetworkFailure('sin red'));
    final snapshot = await source().snapshotOf(favoriteIdentity());
    expect(snapshot!.photo, isNull);
    expect(snapshot.minKmPerLiter, 12);
  });

  test('de otro mercado al vigente no se puede resolver: nulo', () async {
    market = Market.mexico;
    expect(await source().snapshotOf(favoriteIdentity()), isNull);
  });
}
