import 'package:cars_wheels_app/app/compare/compare_group_details_loader.dart';
import 'package:cars_wheels_app/app/compare/compare_slot_builder.dart';
import 'package:cars_wheels_app/app/compare/compare_version_labeler.dart';
import 'package:cars_wheels_app/app/compare/market_compare_safety_source.dart';
import 'package:cars_wheels_app/app/compare/market_compare_market_source.dart';
import 'package:cars_wheels_app/app/compare/market_compare_vehicle_source.dart';
import 'package:cars_wheels_app/app/compare/market_compare_versions_source.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../support/compare_test_support.dart';
import '../support/detail_test_support.dart';
import '../support/market_test_support.dart';

class _MockGroups extends Mock implements GetModelGroupsUseCase {}

class _MockLoad extends Mock implements LoadGroupDetailsUseCase {}

class _MockSafety extends Mock implements ResolveGroupSafetyUseCase {}

void main() {
  setUpAll(() => registerFallbackValue(testArgs()));

  group('CompareSlotBuilder', () {
    test('desde Detalle toma mercado, año, grupo y versión elegida', () {
      final slot = CompareSlotBuilder.fromDetail(
        testArgs(groupName: 'Corolla Hybrid', market: Market.mexico),
        'Corolla LE',
      );
      expect(slot.marketCode, 'mx');
      expect(slot.year, 2020);
      expect(slot.brand, 'Toyota');
      expect(slot.modelName, 'Corolla Hybrid');
      expect(slot.groupKey, 'corollahybrid');
      expect(slot.versionKey, 'Corolla LE');
    });

    test('sin versión elegida queda la predeterminada (nula)', () {
      expect(
        CompareSlotBuilder.fromDetail(testArgs(), null).versionKey,
        isNull,
      );
    });

    test('desde un resultado de búsqueda; una marca sola no es vehículo', () {
      const result = SearchResultEntity(
        brand: 'Honda',
        groupName: 'Civic',
        year: 2025,
        marketCode: 'us',
      );
      final slot = CompareSlotBuilder.fromResult(result)!;
      expect(slot.identity, 'us|2025|Honda|civic|');
      expect(
        CompareSlotBuilder.fromResult(
          const SearchResultEntity(
            brand: 'Honda',
            year: 2025,
            marketCode: 'us',
          ),
        ),
        isNull,
      );
    });
  });

  test(
    'MarketCompareMarketSource emite solo cambios reales de mercado',
    () async {
      final cubit = buildMarketCubit();
      final source = MarketCompareMarketSource(cubit);
      final codes = <String>[];
      final subscription = source.marketChanges.listen(codes.add);
      expect(source.marketCode, 'us');
      await Future<void>.delayed(Duration.zero);
      // Restaurar el mismo mercado no cuenta como cambio.
      await cubit.restore();
      await cubit.select(Market.mexico);
      await cubit.select(Market.mexico);
      await cubit.select(Market.unitedStates);
      await Future<void>.delayed(Duration.zero);
      await subscription.cancel();
      expect(codes, ['mx', 'us']);
      await cubit.close();
    },
  );

  group('fuentes del comparador sobre Detalle', () {
    late _MockGroups groups;
    late _MockLoad load;
    late Market market;

    CompareGroupDetailsLoader loader() => CompareGroupDetailsLoader(
      getModelGroups: groups,
      loadGroupDetails: load,
      currentMarket: () => market,
    );

    const labeler = CompareVersionLabeler(
      VersionDescriptorBuilder(transmissionLabeler: TransmissionLabeler()),
    );

    MarketCompareVehicleSource build() => MarketCompareVehicleSource(
      loader: loader(),
      versionLabeler: labeler,
      classTranslator: const VehicleClassTranslator(),
      fuelTypeLabeler: const FuelTypeLabeler(),
      driveLabeler: const DriveLabeler(),
      transmissionLabeler: const TransmissionLabeler(),
    );

    setUp(() {
      groups = _MockGroups();
      load = _MockLoad();
      market = Market.unitedStates;
      when(() => groups(any(), any())).thenAnswer(
        (_) async => const [
          ModelGroupEntity(
            name: 'Corolla',
            variants: [
              ModelEntity(name: 'Corolla'),
              ModelEntity(name: 'Corolla LE'),
            ],
          ),
        ],
      );
    });

    GroupDetailsEntity details(List<VehicleDetailEntity> list) =>
        GroupDetailsEntity(
          versions: [
            for (final (index, detail) in list.indexed)
              testVersion(detail, variantName: 'V$index'),
          ],
          defaultIndex: 0,
        );

    test('usa la versión elegida y traduce los textos', () async {
      when(() => load(any())).thenAnswer(
        (_) async => details([
          testDetail(combinedKmPerLiter: 10),
          testDetail(combinedKmPerLiter: 20, fuelType: 'Premium'),
        ]),
      );
      final info = await build().detailOf(compareSlot(versionKey: 'V1'));
      expect(info!.combinedKmPerLiter, 20);
      expect(info.classLabel, isNotNull);
      expect(info.fuelLabel, isNotNull);
      expect(info.driveLabel, isNotNull);
      expect(
        info.transmissionLabel,
        startsWith(AppTexts.transmissionAutomaticLabel),
      );
      expect(info.cylindersLabel, AppTexts.cylindersLabel(4));
      expect(info.annualFuelCostUsd, 1750);
      expect(info.engineKind, CompareEngineKind.combustion);
      // Las variantes salen del catálogo del grupo.
      final args =
          verify(() => load(captureAny())).captured.single as DetailArgsEntity;
      expect(args.variantNames, ['Corolla', 'Corolla LE']);
    });

    test('sin versión elegida usa la predeterminada', () async {
      when(() => load(any())).thenAnswer(
        (_) async => details([
          testDetail(combinedKmPerLiter: 10),
          testDetail(combinedKmPerLiter: 20),
        ]),
      );
      final info = await build().detailOf(compareSlot());
      expect(info!.combinedKmPerLiter, 10);
    });

    test('datos ausentes quedan nulos, nunca cero', () async {
      when(() => load(any())).thenAnswer(
        (_) async => details([
          testDetail(
            vehicleClass: null,
            fuelType: null,
            drive: null,
            transmission: null,
            cylinders: null,
            annualFuelCostUsd: null,
            combinedKmPerLiter: null,
          ),
        ]),
      );
      final info = await build().detailOf(compareSlot());
      expect(info!.classLabel, isNull);
      expect(info.fuelLabel, isNull);
      expect(info.driveLabel, isNull);
      expect(info.transmissionLabel, isNull);
      expect(info.cylindersLabel, isNull);
      expect(info.annualFuelCostUsd, isNull);
      expect(info.combinedKmPerLiter, isNull);
      expect(info.co2GramsPerKilometer, isNull);
    });

    test('el tipo fino distingue híbrido y eléctrico', () async {
      when(() => load(any())).thenAnswer(
        (_) async => details([
          testDetail(engineKind: EngineKind.hybrid),
          testDetail(
            powertrain: Powertrain.electric,
            engineKind: EngineKind.electric,
            combinedKmPerLiter: null,
          ),
          testDetail(powertrain: Powertrain.pluginHybrid),
        ]),
      );
      expect(
        (await build().detailOf(compareSlot()))!.engineKind,
        CompareEngineKind.hybrid,
      );
      final electric = await build().detailOf(compareSlot(versionKey: 'V1'));
      expect(electric!.engineKind, CompareEngineKind.electric);
      expect(electric.combinedKmPerLiter, isNull);
      // Sin tipo fino (caché antigua) se usa la motorización.
      expect(
        (await build().detailOf(compareSlot(versionKey: 'V2')))!.engineKind,
        CompareEngineKind.pluginHybrid,
      );
    });

    test(
      'México: potencia y torque sin rpm, sin clase, tracción ni costo',
      () async {
        market = Market.mexico;
        when(() => load(any())).thenAnswer(
          (_) async => details([
            testDetail(
              fuelType: 'Gasolina',
              transmission: 'Automática',
              annualFuelCostUsd: 900,
              powerText: '190 @ 6000',
              torqueText: '350 @ 1500-4000',
              compressionRatioText: '10.5:1',
              cylindersLabel: 'V6',
            ),
          ]),
        );
        final info = await build().detailOf(compareSlot(marketCode: 'mx'));
        expect(info!.classLabel, isNull);
        expect(info.driveLabel, isNull);
        expect(info.annualFuelCostUsd, isNull);
        expect(info.fuelLabel, 'Gasolina');
        expect(info.transmissionLabel, 'Automática');
        expect(info.cylindersLabel, 'V6');
        expect(info.powerLabel, '190 hp');
        expect(info.torqueLabel, '350 N·m');
        expect(info.compressionLabel, '10.5:1');
      },
    );

    test('un vehículo de otro mercado o sin versiones da nulo', () async {
      when(() => load(any())).thenAnswer((_) async => details([testDetail()]));
      expect(await build().detailOf(compareSlot(marketCode: 'mx')), isNull);
      when(() => load(any())).thenAnswer(
        (_) async => const GroupDetailsEntity(versions: [], defaultIndex: 0),
      );
      expect(await build().detailOf(compareSlot()), isNull);
    });

    test('una falla de carga se relanza para que la columna la muestre', () {
      when(() => load(any())).thenThrow(const NetworkFailure('sin red'));
      expect(build().detailOf(compareSlot()), throwsA(isA<NetworkFailure>()));
    });

    test(
      'las versiones usan la variante como clave y un nombre legible',
      () async {
        when(() => load(any())).thenAnswer(
          (_) async => details([testDetail(), testDetail(transmission: null)]),
        );
        final options = await MarketCompareVersionsSource(
          loader: loader(),
          versionLabeler: labeler,
        ).versionsOf(compareSlot());
        expect(options.map((option) => option.key), ['V0', 'V1']);
        expect(
          options.first.label,
          contains(AppTexts.transmissionAutomaticLabel),
        );
        expect(options.first.caption, 'V0');
        expect(options[1].label, isNotEmpty);
      },
    );

    test(
      'México: la etiqueta propia es el título y no hay subtítulo',
      () async {
        market = Market.mexico;
        when(() => load(any())).thenAnswer(
          (_) async => GroupDetailsEntity(
            versions: [
              testVersion(testDetail(), variantName: 'RAW', label: 'LE 2.0L'),
            ],
            defaultIndex: 0,
          ),
        );
        final options = await MarketCompareVersionsSource(
          loader: loader(),
          versionLabeler: labeler,
        ).versionsOf(compareSlot(marketCode: 'mx'));
        expect(options.single.key, 'RAW');
        expect(options.single.label, 'LE 2.0L');
      },
    );

    test(
      'versionsOf: otro mercado da lista vacía y la falla se relanza',
      () async {
        final source = MarketCompareVersionsSource(
          loader: loader(),
          versionLabeler: labeler,
        );
        expect(await source.versionsOf(compareSlot(marketCode: 'mx')), isEmpty);
        when(() => load(any())).thenThrow(const NetworkFailure('sin red'));
        expect(
          source.versionsOf(compareSlot()),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );
  });

  group('MarketCompareSafetySource', () {
    late _MockSafety safety;

    void answer(GroupSafetyEntity? value) => when(
      () => safety.resolveSafety(
        year: any(named: 'year'),
        make: any(named: 'make'),
        model: any(named: 'model'),
      ),
    ).thenAnswer((_) async => value);

    setUp(() => safety = _MockSafety());

    test('devuelve las estrellas generales máximas del grupo', () async {
      answer(
        const GroupSafetyEntity(ratedCount: 2, minOverall: 4, maxOverall: 5),
      );
      expect(
        await MarketCompareSafetySource(safety).overallStarsOf(compareSlot()),
        5,
      );
    });

    test('sin emparejar o sin calificación general es nulo', () async {
      final source = MarketCompareSafetySource(safety);
      answer(null);
      expect(await source.overallStarsOf(compareSlot()), isNull);
      answer(const GroupSafetyEntity(ratedCount: 0));
      expect(await source.overallStarsOf(compareSlot()), isNull);
    });

    test('México nunca consulta NHTSA', () async {
      final source = MarketCompareSafetySource(safety);
      expect(
        await source.overallStarsOf(compareSlot(marketCode: 'mx')),
        isNull,
      );
      verifyZeroInteractions(safety);
    });
  });
}
