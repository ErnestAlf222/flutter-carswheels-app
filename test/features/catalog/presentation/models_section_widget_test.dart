import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class _MockModelsCubit extends MockCubit<ModelsState> implements ModelsCubit {}

List<ModelEntity> _models(int count) => [
  for (int index = 0; index < count; index++) ModelEntity(name: 'Modelo$index'),
];

void main() {
  late _MockModelsCubit modelsCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    modelsCubit = _MockModelsCubit();
    when(() => modelsCubit.state).thenReturn(const ModelsInitial());
  });

  Widget section(ModelsState state) => MaterialApp(
    home: BlocProvider<ModelsCubit>.value(
      value: modelsCubit,
      child: Scaffold(
        body: SingleChildScrollView(
          child: ModelsSectionWidget(brandName: 'Honda', state: state),
        ),
      ),
    ),
  );

  testWidgets('initial muestra solo el nombre de la marca', (tester) async {
    await tester.pumpWidget(section(const ModelsInitial()));
    expect(find.text('Honda'), findsOneWidget);
    expect(find.byType(ModelCardWidget), findsNothing);
    expect(find.byType(AppLoader), findsNothing);
    expect(find.textContaining('modelo'), findsNothing);
  });

  testWidgets('loading muestra el AppLoader sin conteo', (tester) async {
    await tester.pumpWidget(section(const ModelsLoading()));
    expect(find.byType(AppLoader), findsOneWidget);
    expect(find.textContaining('modelo'), findsNothing);
  });

  testWidgets('error muestra ErrorStateWidget y reintenta', (tester) async {
    when(() => modelsCubit.retry()).thenAnswer((_) async {});
    await tester.pumpWidget(
      section(
        const ModelsError(
          NetworkFailure('sin red'),
          year: 2020,
          brand: 'Honda',
        ),
      ),
    );
    expect(find.byType(ErrorStateWidget), findsOneWidget);
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    verify(() => modelsCubit.retry()).called(1);
  });

  testWidgets('loaded sin modelos muestra el estado vacío', (tester) async {
    await tester.pumpWidget(
      section(const ModelsLoaded(models: [], visibleCount: 0)),
    );
    expect(find.byType(EmptyStateWidget), findsOneWidget);
    expect(find.text('0 modelos'), findsOneWidget);
  });

  testWidgets('con un modelo el conteo dice 1 modelo', (tester) async {
    await tester.pumpWidget(
      section(ModelsLoaded(models: _models(1), visibleCount: 1)),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 modelo'), findsOneWidget);
    expect(find.byType(ModelCardWidget), findsOneWidget);
  });

  testWidgets('muestra solo visibleCount tarjetas y el total en el conteo', (
    tester,
  ) async {
    await tester.pumpWidget(
      section(ModelsLoaded(models: _models(51), visibleCount: 10)),
    );
    await tester.pumpAndSettle();
    expect(find.text('51 modelos'), findsOneWidget);
    expect(
      find.byType(ModelCardWidget, skipOffstage: false),
      findsNWidgets(10),
    );
  });
}
