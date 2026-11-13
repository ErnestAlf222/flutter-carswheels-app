import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLoad extends Mock implements LoadGroupDetailsUseCase {}

const DetailArgsEntity _args = DetailArgsEntity(
  brand: 'Toyota',
  groupName: 'Camry',
  year: 2020,
  variantNames: ['Camry'],
  photo: null,
  heroTag: 'tag',
);

VehicleDetailEntity _detail(int id) => VehicleDetailEntity(
  id: id,
  year: 2020,
  make: 'Toyota',
  model: 'Camry',
  vehicleClass: null,
  powertrain: Powertrain.combustion,
  transmission: null,
  cylinders: null,
  displacementLiters: null,
  drive: null,
  fuelType: null,
  cityKmPerLiter: null,
  highwayKmPerLiter: null,
  combinedKmPerLiter: 10,
  annualFuelCostUsd: null,
);

final GroupDetailsEntity _details = GroupDetailsEntity(
  versions: [
    for (final id in [1, 2, 3])
      GroupVersionEntity(variantName: 'Camry', detail: _detail(id)),
  ],
  defaultIndex: 1,
);

void main() {
  late _MockLoad load;

  setUpAll(() => registerFallbackValue(_args));
  setUp(() => load = _MockLoad());

  DetailCubit build() => DetailCubit(load);

  group('load', () {
    blocTest<DetailCubit, DetailState>(
      'loading → loaded con selectedIndex = defaultIndex',
      build: build,
      setUp: () => when(() => load(any())).thenAnswer((_) async => _details),
      act: (cubit) => cubit.load(_args),
      expect: () => [
        const DetailLoading(),
        DetailLoaded(details: _details, selectedIndex: 1),
      ],
    );

    blocTest<DetailCubit, DetailState>(
      'loading → empty cuando no hay versiones',
      build: build,
      setUp: () => when(() => load(any())).thenAnswer(
        (_) async => const GroupDetailsEntity(versions: [], defaultIndex: 0),
      ),
      act: (cubit) => cubit.load(_args),
      expect: () => [const DetailLoading(), const DetailEmpty()],
    );

    blocTest<DetailCubit, DetailState>(
      'loading → error con la falla',
      build: build,
      setUp: () => when(() => load(any())).thenThrow(const NetworkFailure('x')),
      act: (cubit) => cubit.load(_args),
      expect: () => [
        const DetailLoading(),
        const DetailError(NetworkFailure('x')),
      ],
    );

    blocTest<DetailCubit, DetailState>(
      'un error que no es AppFailure se vuelve UnknownFailure',
      build: build,
      setUp: () => when(() => load(any())).thenThrow(StateError('boom')),
      act: (cubit) => cubit.load(_args),
      expect: () => [const DetailLoading(), isA<DetailError>()],
      verify: (cubit) {
        final state = cubit.state as DetailError;
        expect(state.failure, isA<UnknownFailure>());
      },
    );
  });

  group('select', () {
    blocTest<DetailCubit, DetailState>(
      'un índice válido y distinto emite el nuevo',
      build: build,
      seed: () => DetailLoaded(details: _details, selectedIndex: 1),
      act: (cubit) => cubit.select(2),
      expect: () => [DetailLoaded(details: _details, selectedIndex: 2)],
    );

    blocTest<DetailCubit, DetailState>(
      'índice fuera de rango, negativo o repetido no emite',
      build: build,
      seed: () => DetailLoaded(details: _details, selectedIndex: 1),
      act: (cubit) => cubit
        ..select(3)
        ..select(-1)
        ..select(1),
      expect: () => <DetailState>[],
    );

    blocTest<DetailCubit, DetailState>(
      'fuera de DetailLoaded no hace nada',
      build: build,
      act: (cubit) => cubit.select(0),
      expect: () => <DetailState>[],
    );
  });

  group('retry', () {
    blocTest<DetailCubit, DetailState>(
      'repite la carga con los mismos args',
      build: build,
      setUp: () {
        when(() => load(any())).thenThrow(const NetworkFailure('x'));
      },
      act: (cubit) async {
        await cubit.load(_args);
        when(() => load(any())).thenAnswer((_) async => _details);
        await cubit.retry();
      },
      expect: () => [
        const DetailLoading(),
        const DetailError(NetworkFailure('x')),
        const DetailLoading(),
        DetailLoaded(details: _details, selectedIndex: 1),
      ],
      verify: (_) => verify(() => load(_args)).called(2),
    );

    blocTest<DetailCubit, DetailState>(
      'sin args previos no hace nada',
      build: build,
      act: (cubit) => cubit.retry(),
      expect: () => <DetailState>[],
      verify: (_) => verifyNever(() => load(any())),
    );
  });

  test('no emite tras close()', () async {
    final completer = Completer<GroupDetailsEntity>();
    when(() => load(any())).thenAnswer((_) => completer.future);
    final cubit = build();
    final emitted = <DetailState>[];
    final subscription = cubit.stream.listen(emitted.add);
    final pending = cubit.load(_args);
    await Future<void>.delayed(Duration.zero);
    await cubit.close();
    completer.complete(_details);
    await pending;
    await subscription.cancel();
    expect(emitted, [const DetailLoading()]);
    // Cargar o reintentar con el cubit cerrado tampoco falla.
    await cubit.load(_args);
    await cubit.retry();
  });

  test('una carga vieja no pisa a la más reciente', () async {
    final first = Completer<GroupDetailsEntity>();
    final second = Completer<GroupDetailsEntity>();
    final answers = [first, second];
    when(() => load(any())).thenAnswer((_) => answers.removeAt(0).future);
    final cubit = build();
    final firstLoad = cubit.load(_args);
    final secondLoad = cubit.load(_args);
    second.complete(_details);
    first.complete(const GroupDetailsEntity(versions: [], defaultIndex: 0));
    await Future.wait([firstLoad, secondLoad]);
    expect(cubit.state, DetailLoaded(details: _details, selectedIndex: 1));
    await cubit.close();
  });
}
