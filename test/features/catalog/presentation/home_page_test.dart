import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogCubit extends MockCubit<CatalogState>
    implements CatalogCubit {}

class _MockModelsCubit extends MockCubit<ModelsState> implements ModelsCubit {}

class _MockBrandLogosCubit extends MockCubit<BrandLogosState>
    implements BrandLogosCubit {}

List<BrandEntity> _brands(int count) => [
  for (int index = 0; index < count; index++) BrandEntity(name: 'Marca$index'),
];

CatalogLoaded _loaded({
  int year = 2026,
  int selectedIndex = 0,
  int windowStart = 0,
  List<int> years = const [2026, 2025, 2024],
  List<BrandEntity>? brands,
}) => CatalogLoaded(
  year: year,
  availableYears: years,
  brands: brands ?? _brands(6),
  selectedIndex: selectedIndex,
  windowStart: windowStart,
);

ModelsLoaded _models(int total, int visible) => ModelsLoaded(
  models: [
    for (int index = 0; index < total; index++) ModelEntity(name: 'M$index'),
  ],
  visibleCount: visible,
);

void main() {
  late _MockCatalogCubit catalogCubit;
  late _MockModelsCubit modelsCubit;
  late _MockBrandLogosCubit logosCubit;
  late StreamController<CatalogState> catalogEvents;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    catalogCubit = _MockCatalogCubit();
    modelsCubit = _MockModelsCubit();
    logosCubit = _MockBrandLogosCubit();
    catalogEvents = StreamController<CatalogState>.broadcast();
    when(() => logosCubit.state).thenReturn(const BrandLogosInitial());
    when(() => logosCubit.urlFor(any())).thenReturn(null);
    when(() => modelsCubit.load(any(), any())).thenAnswer((_) async {});
    when(() => modelsCubit.loadMore()).thenReturn(null);
    when(() => modelsCubit.retry()).thenAnswer((_) async {});
    when(() => catalogCubit.retry()).thenAnswer((_) async {});
    when(() => catalogCubit.showOlderYear()).thenAnswer((_) async {});
    when(() => catalogCubit.showNewerYear()).thenAnswer((_) async {});
  });

  tearDown(() => catalogEvents.close());

  Future<void> pumpHome(
    WidgetTester tester, {
    required CatalogState catalog,
    ModelsState models = const ModelsInitial(),
  }) async {
    whenListen(catalogCubit, catalogEvents.stream, initialState: catalog);
    when(() => modelsCubit.state).thenReturn(models);
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<CatalogCubit>.value(value: catalogCubit),
            BlocProvider<ModelsCubit>.value(value: modelsCubit),
            BlocProvider<BrandLogosCubit>.value(value: logosCubit),
          ],
          child: const HomePage(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('loaded muestra carrusel, selector de año y modelos', (
    tester,
  ) async {
    await pumpHome(tester, catalog: _loaded(), models: _models(3, 3));
    await tester.pumpAndSettle();
    expect(find.byType(BrandCarouselWidget), findsOneWidget);
    expect(find.byType(YearSelectorWidget), findsOneWidget);
    expect(find.text('2026'), findsOneWidget);
    expect(find.byType(ModelsSectionWidget), findsOneWidget);
    expect(find.byType(ModelCardWidget), findsNWidgets(3));
    expect(find.text('3 modelos'), findsOneWidget);
  });

  testWidgets('loading muestra el AppLoader y no hay selector de año', (
    tester,
  ) async {
    await pumpHome(tester, catalog: const CatalogLoading());
    expect(find.byType(AppLoader), findsOneWidget);
    expect(find.byType(YearSelectorWidget), findsNothing);
    expect(find.byType(ModelsSectionWidget), findsNothing);
  });

  testWidgets('el error de marcas llama a retry', (tester) async {
    await pumpHome(
      tester,
      catalog: const CatalogError(NetworkFailure('sin red')),
    );
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    verify(() => catalogCubit.retry()).called(1);
  });

  testWidgets('sin marcas muestra el estado vacío y no carga modelos', (
    tester,
  ) async {
    await pumpHome(tester, catalog: _loaded(brands: const []));
    expect(find.byType(EmptyStateWidget), findsOneWidget);
    expect(find.byType(ModelsSectionWidget), findsNothing);
  });

  testWidgets('tocar año anterior llama a showOlderYear', (tester) async {
    await pumpHome(tester, catalog: _loaded());
    await tester.tap(find.bySemanticsLabel(AppTexts.olderYearLabel));
    verify(() => catalogCubit.showOlderYear()).called(1);
    verifyNever(() => catalogCubit.showNewerYear());
  });

  testWidgets('en el año más reciente la flecha siguiente no responde', (
    tester,
  ) async {
    await pumpHome(tester, catalog: _loaded());
    await tester.tap(find.bySemanticsLabel(AppTexts.newerYearLabel));
    verifyNever(() => catalogCubit.showNewerYear());
  });

  testWidgets('cambiar solo windowStart no carga modelos', (tester) async {
    await pumpHome(tester, catalog: _loaded());
    catalogEvents.add(_loaded(windowStart: 1));
    await tester.pump();
    verifyNever(() => modelsCubit.load(any(), any()));
  });

  testWidgets('cambiar la marca carga los modelos una vez', (tester) async {
    await pumpHome(tester, catalog: _loaded());
    catalogEvents.add(_loaded(selectedIndex: 2));
    await tester.pump();
    verify(() => modelsCubit.load(2026, 'Marca2')).called(1);
  });

  testWidgets('cambiar el año carga los modelos una vez', (tester) async {
    await pumpHome(tester, catalog: _loaded());
    catalogEvents.add(_loaded(year: 2025));
    await tester.pump();
    verify(() => modelsCubit.load(2025, 'Marca0')).called(1);
  });

  testWidgets('la primera carga de marcas carga los modelos', (tester) async {
    await pumpHome(tester, catalog: const CatalogLoading());
    catalogEvents.add(_loaded());
    await tester.pump();
    verify(() => modelsCubit.load(2026, 'Marca0')).called(1);
  });

  group('modelos', () {
    testWidgets('loading muestra el loader de modelos', (tester) async {
      await pumpHome(tester, catalog: _loaded(), models: const ModelsLoading());
      expect(find.byType(AppLoader), findsOneWidget);
    });

    testWidgets('error muestra reintento que llama a ModelsCubit.retry', (
      tester,
    ) async {
      await pumpHome(
        tester,
        catalog: _loaded(),
        models: const ModelsError(
          NetworkFailure('sin red'),
          year: 2026,
          brand: 'Marca0',
        ),
      );
      await tester.drag(find.byType(ListView), const Offset(0, -300));
      await tester.pump();
      await tester.tap(find.text(AppTexts.retryButtonLabel));
      verify(() => modelsCubit.retry()).called(1);
    });

    testWidgets('sin modelos muestra el estado vacío', (tester) async {
      await pumpHome(
        tester,
        catalog: _loaded(),
        models: const ModelsLoaded(models: [], visibleCount: 0),
      );
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });
  });

  group('carga por páginas', () {
    testWidgets('llegar al final con hasMore llama a loadMore', (tester) async {
      await pumpHome(tester, catalog: _loaded(), models: _models(30, 10));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -5000));
      await tester.pump();
      verify(() => modelsCubit.loadMore()).called(greaterThan(0));
    });

    testWidgets('llegar al final sin hasMore no llama a loadMore', (
      tester,
    ) async {
      await pumpHome(tester, catalog: _loaded(), models: _models(10, 10));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -5000));
      await tester.pump();
      verifyNever(() => modelsCubit.loadMore());
    });

    testWidgets('lejos del final no llama a loadMore', (tester) async {
      await pumpHome(tester, catalog: _loaded(), models: _models(30, 10));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView), const Offset(0, -20));
      await tester.pump();
      verifyNever(() => modelsCubit.loadMore());
    });
  });
}
