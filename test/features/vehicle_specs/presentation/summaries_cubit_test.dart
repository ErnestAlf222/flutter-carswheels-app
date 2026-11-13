import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockResolve extends Mock implements ResolveGroupSummaryUseCase {}

class _MockCancel extends Mock implements CancelPendingSummariesUseCase {}

const GroupSummaryEntity _summary = GroupSummaryEntity(
  vehicleClass: 'Compact Cars',
  minKmPerLiter: 10,
  maxKmPerLiter: 12,
  hasElectric: false,
  hasPluginHybrid: false,
  variantCount: 2,
);

const SummaryRequest _civic = SummaryRequest(
  brand: 'Honda',
  groupName: 'Civic',
  year: 2020,
  variantNames: ['Civic 4Dr', 'Civic 2Dr'],
);
const SummaryRequest _accord = SummaryRequest(
  brand: 'Honda',
  groupName: 'Accord',
  year: 2020,
  variantNames: ['Accord'],
);

void main() {
  late _MockResolve resolve;
  late _MockCancel cancel;
  late SummariesCubit cubit;

  String key(SummaryRequest request) =>
      cubit.keyFor(request.brand, request.groupName, request.year);

  setUp(() {
    resolve = _MockResolve();
    cancel = _MockCancel();
    when(() => cancel()).thenAnswer((_) async {});
    cubit = SummariesCubit(
      resolveGroupSummary: resolve,
      cancelPendingSummaries: cancel,
      keyBuilder: const SummaryKeyBuilder(),
    );
  });

  tearDown(() => cubit.close());

  void stubResolve(Future<GroupSummaryEntity?> Function(String group) answer) {
    when(
      () => resolve(
        year: any(named: 'year'),
        brand: any(named: 'brand'),
        groupName: any(named: 'groupName'),
        variantNames: any(named: 'variantNames'),
      ),
    ).thenAnswer(
      (invocation) => answer(invocation.namedArguments[#groupName] as String),
    );
  }

  int resolveCalls() => verify(
    () => resolve(
      year: any(named: 'year'),
      brand: any(named: 'brand'),
      groupName: any(named: 'groupName'),
      variantNames: any(named: 'variantNames'),
    ),
  ).callCount;

  test('keyFor usa la marca, el grupo y el año', () {
    expect(
      cubit.keyFor('Honda', 'Civic', 2020),
      const SummaryKeyBuilder().build(
        brand: 'Honda',
        groupName: 'Civic',
        year: 2020,
      ),
    );
  });

  blocTest<SummariesCubit, SummariesState>(
    'un lote marca Loading en una sola emisión y luego resuelve cada uno',
    setUp: () => stubResolve((group) async => _summary),
    build: () => cubit,
    act: (cubit) => cubit.requestSummaries([_civic, _accord]),
    expect: () => [
      SummariesState(
        slots: {
          key(_civic): const SummaryLoading(),
          key(_accord): const SummaryLoading(),
        },
      ),
      isA<SummariesState>(),
      isA<SummariesState>(),
    ],
    verify: (cubit) {
      expect(cubit.state.slots[key(_civic)], const SummaryFound(_summary));
      expect(cubit.state.slots[key(_accord)], const SummaryFound(_summary));
    },
  );

  test('pasa a la resolución los datos del pedido', () async {
    stubResolve((group) async => _summary);
    cubit.requestSummaries([_civic]);
    await Future<void>.delayed(Duration.zero);
    verify(
      () => resolve(
        year: 2020,
        brand: 'Honda',
        groupName: 'Civic',
        variantNames: ['Civic 4Dr', 'Civic 2Dr'],
      ),
    ).called(1);
  });

  test('las claves repetidas del lote se resuelven una sola vez', () async {
    stubResolve((group) async => _summary);
    cubit.requestSummaries([_civic, _civic, _accord, _civic]);
    await Future<void>.delayed(Duration.zero);
    expect(resolveCalls(), 2);
  });

  test('un resultado nulo queda como Missing', () async {
    stubResolve((group) async => null);
    cubit.requestSummaries([_civic]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic)], const SummaryMissing());
  });

  test('no repite Loading, Found ni Missing', () async {
    final pending = Completer<GroupSummaryEntity?>();
    stubResolve((group) {
      if (group == 'Civic') return pending.future;
      if (group == 'Accord') return Future.value(_summary);
      return Future.value(null);
    });
    const tucson = SummaryRequest(
      brand: 'Hyundai',
      groupName: 'Tucson',
      year: 2020,
      variantNames: ['Tucson'],
    );
    cubit.requestSummaries([_civic, _accord, tucson]);
    await Future<void>.delayed(Duration.zero);
    cubit.requestSummaries([_civic, _accord, tucson]);
    await Future<void>.delayed(Duration.zero);
    expect(resolveCalls(), 3);
    pending.complete(_summary);
  });

  test('reintenta los Failed', () async {
    final shouldFail = <bool>[true];
    stubResolve((group) async {
      if (shouldFail.single) throw const NetworkFailure('sin red');
      return _summary;
    });
    cubit.requestSummaries([_civic]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic)], const SummaryFailed());
    shouldFail[0] = false;
    cubit.requestSummaries([_civic]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic)], const SummaryFound(_summary));
  });

  test(
    'cancelPending llama al caso de uso y marca Failed los Loading',
    () async {
      final pending = Completer<GroupSummaryEntity?>();
      stubResolve((group) {
        if (group == 'Civic') return pending.future;
        return Future.value(_summary);
      });
      cubit.requestSummaries([_accord]);
      await Future<void>.delayed(Duration.zero);
      cubit.requestSummaries([_civic]);
      cubit.cancelPending();
      verify(() => cancel()).called(1);
      expect(cubit.state.slots[key(_civic)], const SummaryFailed());
      expect(cubit.state.slots[key(_accord)], const SummaryFound(_summary));
      pending.complete(null);
    },
  );

  test('una resolución con CancelledFailure no emite fallo visible', () async {
    final pending = Completer<GroupSummaryEntity?>();
    stubResolve((group) => pending.future);
    cubit.requestSummaries([_civic]);
    cubit.cancelPending();
    final emitted = <SummariesState>[];
    final subscription = cubit.stream.listen(emitted.add);
    pending.completeError(const CancelledFailure('cancelado'));
    await Future<void>.delayed(Duration.zero);
    expect(emitted, isEmpty);
    expect(cubit.state.slots[key(_civic)], const SummaryFailed());
    await subscription.cancel();
  });

  test('una cancelación vieja no pisa un resultado más nuevo', () async {
    final first = Completer<GroupSummaryEntity?>();
    final calls = <int>[];
    stubResolve((group) {
      calls.add(calls.length);
      return calls.length == 1 ? first.future : Future.value(_summary);
    });
    cubit.requestSummaries([_civic]);
    cubit.cancelPending();
    cubit.requestSummaries([_civic]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic)], const SummaryFound(_summary));
    first.completeError(const CancelledFailure('cancelado'));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic)], const SummaryFound(_summary));
  });

  test('no emite después de close', () async {
    final pending = Completer<GroupSummaryEntity?>();
    stubResolve((group) => pending.future);
    cubit.requestSummaries([_civic]);
    await cubit.close();
    pending.complete(_summary);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.isClosed, isTrue);
  });

  test('consumptionLabelFor da el rango o las etiquetas de motorización', () {
    const state = SummariesState(
      slots: {
        'a': SummaryFound(_summary),
        'b': SummaryFound(
          GroupSummaryEntity(
            vehicleClass: null,
            minKmPerLiter: null,
            maxKmPerLiter: null,
            hasElectric: true,
            hasPluginHybrid: false,
            variantCount: 1,
          ),
        ),
        'c': SummaryLoading(),
        'd': SummaryFound(
          GroupSummaryEntity(
            vehicleClass: null,
            minKmPerLiter: null,
            maxKmPerLiter: null,
            hasElectric: true,
            hasPluginHybrid: true,
            hasFuelCell: true,
            variantCount: 1,
          ),
        ),
        'e': SummaryFound(
          GroupSummaryEntity(
            vehicleClass: null,
            minKmPerLiter: null,
            maxKmPerLiter: null,
            hasElectric: false,
            hasPluginHybrid: false,
            hasFuelCell: true,
            variantCount: 1,
          ),
        ),
        'f': SummaryFound(
          GroupSummaryEntity(
            vehicleClass: null,
            minKmPerLiter: null,
            maxKmPerLiter: null,
            hasElectric: false,
            hasPluginHybrid: false,
            hasFuelCell: false,
            variantCount: 1,
          ),
        ),
      },
    );
    expect(state.consumptionLabelFor('a'), '10–12 km/l combinado');
    expect(state.consumptionLabelFor('b'), AppTexts.electricLabel);
    expect(
      state.consumptionLabelFor('d'),
      [
        AppTexts.electricLabel,
        AppTexts.pluginHybridLabel,
        AppTexts.hydrogenLabel,
      ].join(AppTexts.semanticListSeparator),
    );
    expect(state.consumptionLabelFor('e'), AppTexts.hydrogenLabel);
    expect(state.consumptionLabelFor('f'), isNull);
    expect(state.consumptionLabelFor('c'), isNull);
    expect(state.consumptionLabelFor('z'), isNull);
  });
}
