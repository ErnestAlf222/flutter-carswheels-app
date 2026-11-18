import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/detail_test_support.dart';

class _MockSafety extends Mock implements ResolveGroupSafetyUseCase {}

const GroupSafetyEntity _rated = GroupSafetyEntity(
  ratedCount: 3,
  minOverall: 4,
  maxOverall: 5,
);
const RecallSummaryEntity _recalls = RecallSummaryEntity(
  recalls: [RecallEntity(campaignNumber: '23V-001')],
);

void main() {
  late _MockSafety safety;
  final args = testArgs();

  setUp(() => safety = _MockSafety());

  void stubSafety(Future<GroupSafetyEntity?> Function() answer) {
    when(
      () => safety.resolveSafety(
        year: any(named: 'year'),
        make: any(named: 'make'),
        model: any(named: 'model'),
      ),
    ).thenAnswer((_) => answer());
  }

  void stubRecalls(Future<RecallSummaryEntity?> Function() answer) {
    when(
      () => safety.resolveRecalls(
        year: any(named: 'year'),
        make: any(named: 'make'),
        model: any(named: 'model'),
      ),
    ).thenAnswer((_) => answer());
  }

  test('empieza cargando ambas partes', () {
    expect(DetailSafetyCubit(safety).state, const DetailSafetyState());
    expect(
      const DetailSafetyState().ratings,
      isA<SafetyLoading<GroupSafetyEntity>>(),
    );
  });

  test(
    'con datos entrega estrellas y recalls y pide con marca, grupo y año',
    () async {
      stubSafety(() async => _rated);
      stubRecalls(() async => _recalls);
      final cubit = DetailSafetyCubit(safety);
      await cubit.load(args);
      expect(cubit.state.ratings, const SafetyData(_rated));
      expect(cubit.state.recalls, const SafetyData(_recalls));
      verify(
        () => safety.resolveSafety(
          year: args.year,
          make: args.brand,
          model: args.groupName,
        ),
      ).called(1);
      verify(
        () => safety.resolveRecalls(
          year: args.year,
          make: args.brand,
          model: args.groupName,
        ),
      ).called(1);
      await cubit.close();
    },
  );

  test(
    'sin emparejar o sin calificar queda sin datos, nunca en cero',
    () async {
      stubSafety(() async => const GroupSafetyEntity(ratedCount: 0));
      stubRecalls(() async => null);
      final cubit = DetailSafetyCubit(safety);
      await cubit.load(args);
      expect(cubit.state.ratings, isA<SafetyEmpty<GroupSafetyEntity>>());
      expect(cubit.state.recalls, isA<SafetyEmpty<RecallSummaryEntity>>());
      await cubit.close();
    },
  );

  test('lista vacía de recalls es un cero confirmado con datos', () async {
    stubSafety(() async => null);
    stubRecalls(() async => const RecallSummaryEntity(recalls: []));
    final cubit = DetailSafetyCubit(safety);
    await cubit.load(args);
    expect(cubit.state.ratings, isA<SafetyEmpty<GroupSafetyEntity>>());
    final recalls = cubit.state.recalls as SafetyData<RecallSummaryEntity>;
    expect(recalls.value.count, 0);
    await cubit.close();
  });

  test('una falla de estrellas no afecta a los recalls', () async {
    stubSafety(() async => throw const NetworkFailure('sin red'));
    stubRecalls(() async => _recalls);
    final cubit = DetailSafetyCubit(safety);
    await cubit.load(args);
    expect(cubit.state.ratings, isA<SafetyFailed<GroupSafetyEntity>>());
    expect(cubit.state.recalls, const SafetyData(_recalls));
    await cubit.close();
  });

  test('una falla de recalls no afecta a las estrellas', () async {
    stubSafety(() async => _rated);
    stubRecalls(() async => throw Exception('inesperado'));
    final cubit = DetailSafetyCubit(safety);
    await cubit.load(args);
    expect(cubit.state.ratings, const SafetyData(_rated));
    expect(cubit.state.recalls, isA<SafetyFailed<RecallSummaryEntity>>());
    await cubit.close();
  });

  test('cada parte se publica apenas termina, sin esperar a la otra', () async {
    final slowRecalls = Completer<RecallSummaryEntity?>();
    stubSafety(() async => _rated);
    stubRecalls(() => slowRecalls.future);
    final cubit = DetailSafetyCubit(safety);
    final loading = cubit.load(args);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.ratings, const SafetyData(_rated));
    expect(cubit.state.recalls, isA<SafetyLoading<RecallSummaryEntity>>());
    slowRecalls.complete(_recalls);
    await loading;
    expect(cubit.state.recalls, const SafetyData(_recalls));
    await cubit.close();
  });

  test('si Detalle se cierra antes de terminar, ignora el resultado', () async {
    final pendingRatings = Completer<GroupSafetyEntity?>();
    final pendingRecalls = Completer<RecallSummaryEntity?>();
    stubSafety(() => pendingRatings.future);
    stubRecalls(() => pendingRecalls.future);
    final cubit = DetailSafetyCubit(safety);
    final loading = cubit.load(args);
    await cubit.close();
    pendingRatings.complete(_rated);
    pendingRecalls.complete(_recalls);
    await loading;
    expect(cubit.state, const DetailSafetyState());
  });
}
