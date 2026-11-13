import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:mocktail/mocktail.dart';

/// Cubit de resúmenes falso para pruebas de widgets.
class MockSummariesCubit extends MockCubit<SummariesState>
    implements SummariesCubit {}

/// Prepara el cubit falso con la clave real y los espacios dados.
MockSummariesCubit buildMockSummariesCubit({
  Map<String, SummarySlot> slots = const {},
}) {
  registerFallbackValue(<SummaryRequest>[]);
  final cubit = MockSummariesCubit();
  when(() => cubit.state).thenReturn(SummariesState(slots: slots));
  when(() => cubit.keyFor(any(), any(), any())).thenAnswer((invocation) {
    final args = invocation.positionalArguments;
    return summaryKeyFor(args[0] as String, args[1] as String, args[2] as int);
  });
  when(() => cubit.requestSummaries(any())).thenReturn(null);
  when(() => cubit.cancelPending()).thenReturn(null);
  return cubit;
}

/// Clave de resumen de la marca, grupo y año dados.
String summaryKeyFor(String brand, String groupName, int year) =>
    const SummaryKeyBuilder().build(
      brand: brand,
      groupName: groupName,
      year: year,
    );
