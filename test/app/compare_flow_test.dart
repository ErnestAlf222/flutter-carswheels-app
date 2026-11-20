import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/app/search_results/search_card_cubits_factory.dart';
import 'package:cars_wheels_app/app/search_results/search_cubit_factory.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/navigation/navigation.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';

import '../support/brand_logos_test_support.dart';
import '../support/compare_test_support.dart';
import '../support/detail_test_support.dart';
import '../support/market_test_support.dart';
import '../support/photos_test_support.dart';
import '../support/search_test_support.dart';
import '../support/summaries_test_support.dart';

class _MockLoad extends Mock implements LoadGroupDetailsUseCase {}

class _MockCatalogCubit extends MockCubit<CatalogState>
    implements CatalogCubit {}

class _MockModelsCubit extends MockCubit<ModelsState> implements ModelsCubit {}

class _MockLogoPrecacheCubit extends MockCubit<LogoPrecacheState>
    implements LogoPrecacheCubit {}

class _CatalogRepository implements CatalogRepository {
  @override
  Future<List<int>> fetchYears() async => [2025];

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async => const [];

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async =>
      const [];
}

/// La app real (router incluido) con cubits falsos en los bordes.
class _Flow {
  _Flow({int initialVehicles = 0, this.initialLocation = RoutesConfig.home}) {
    store = InMemoryCompareSelection();
    compare = buildCompareCubit(
      selection: store,
      noticeDuration: const Duration(seconds: 30),
    );
    tabSearch = SearchHarness();
    pickerSearch = SearchHarness();
    initial = [
      for (final model in ['Camry', 'RAV4', 'Prius'].take(initialVehicles))
        compareSlot(model: model, year: 2025),
    ];
    router = buildAppRouter();
  }

  late final InMemoryCompareSelection store;
  late final CompareCubit compare;
  late final CompareTableCubit table;
  late final SearchHarness tabSearch;
  late final SearchHarness pickerSearch;
  late final List<CompareSlotEntity> initial;
  late final GoRouter router;
  final String initialLocation;
  final ScrollOffsetStore tabScroll = ScrollOffsetStore();

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await store.write('us', initial);
    final load = _MockLoad();
    when(() => load(any()))
        .thenAnswer((_) => Completer<GroupDetailsEntity>().future);
    final gallery = MockResolveModelGalleryUseCase();
    when(
      () => gallery(
        brand: any(named: 'brand'),
        modelName: any(named: 'modelName'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async => const []);
    final catalog = _MockCatalogCubit();
    whenListen(
      catalog,
      const Stream<CatalogState>.empty(),
      initialState: const CatalogInitial(),
    );
    final models = _MockModelsCubit();
    when(() => models.state).thenReturn(const ModelsInitial());
    final precache = _MockLogoPrecacheCubit();
    when(() => precache.state).thenReturn(const LogoPrecacheState());
    final photos = buildMockPhotosCubit();
    when(() => photos.isClosed).thenReturn(false);
    table = buildCompareTableCubit(
      compare: compare,
      vehicles: FakeCompareVehicleSource(),
    );
    addTearDown(router.dispose);
    addTearDown(compare.close);
    addTearDown(table.close);
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ScrollOffsetStore>.value(value: tabScroll),
          RepositoryProvider<LoadGroupDetailsUseCase>.value(value: load),
          RepositoryProvider<ResolveModelGalleryUseCase>.value(value: gallery),
          RepositoryProvider<PhotoPrefetcher>.value(
            value: const PhotoPrefetcher(),
          ),
          RepositoryProvider<VehicleClassTranslator>.value(
            value: const VehicleClassTranslator(),
          ),
          RepositoryProvider<FuelTypeLabeler>.value(
            value: const FuelTypeLabeler(),
          ),
          RepositoryProvider<DriveLabeler>.value(value: const DriveLabeler()),
          RepositoryProvider<VersionDescriptorBuilder>.value(
            value: const VersionDescriptorBuilder(
              transmissionLabeler: TransmissionLabeler(),
            ),
          ),
          RepositoryProvider<GetModelGroupsUseCase>.value(
            value: GetModelGroupsUseCase(
              repository: _CatalogRepository(),
              grouper: const ModelGrouper(
                sortStrategy: AdaptiveSortStrategy<ModelGroupEntity>(
                  smallListStrategy: BubbleSortStrategy<ModelGroupEntity>(),
                  largeListStrategy: ShellSortStrategy<ModelGroupEntity>(),
                ),
              ),
            ),
          ),
          RepositoryProvider<SearchCardCubitsFactory>.value(
            value: SearchCardCubitsFactory(
              createPhotos: () {
                final cubit = buildMockPhotosCubit();
                when(() => cubit.isClosed).thenReturn(false);
                when(() => cubit.close()).thenAnswer((_) async {});
                return cubit;
              },
              createSummaries: () {
                final cubit = buildMockSummariesCubit();
                when(() => cubit.isClosed).thenReturn(false);
                when(() => cubit.close()).thenAnswer((_) async {});
                return cubit;
              },
            ),
          ),
          RepositoryProvider<CompareVersionsSource>.value(
            value: FakeCompareVersionsSource(),
          ),
          // El selector recibe el cubit de su propia búsqueda.
          RepositoryProvider<SearchCubitFactory>.value(
            value: SearchCubitFactory((_) => pickerSearch.cubit),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<CatalogCubit>.value(value: catalog),
            BlocProvider<ModelsCubit>.value(value: models),
            BlocProvider<BrandLogosCubit>.value(
              value: buildMockBrandLogosCubit(),
            ),
            BlocProvider<LogoPrecacheCubit>.value(value: precache),
            BlocProvider<PhotosCubit>.value(value: photos),
            BlocProvider<MarketCubit>.value(value: buildMarketCubit()),
            BlocProvider<SectionLoaderCubit>(
              create: (_) => SectionLoaderCubit(),
            ),
            BlocProvider<SearchCubit>.value(value: tabSearch.cubit),
            BlocProvider<CompareCubit>.value(value: compare),
            BlocProvider<CompareTableCubit>.value(value: table),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: child!,
            ),
          ),
        ),
      ),
    );
    await settle(tester);
    router.go(initialLocation);
    await settle(tester);
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 350));
  }
}

// El título de la hoja del selector (el botón de Comparar dice lo mismo).
Finder get _pickerTitle => find.descendant(
  of: find.byType(SearchPage),
  matching: find.text(AppTexts.comparePickerTitle),
);

Finder get _pickerClose => find.descendant(
  of: find.byType(SearchPage),
  matching: find.byIcon(Symbols.close),
);

Finder get _fullSheetTitle => find.text(AppTexts.compareFullSheetTitle);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(testArgs());
  });

  testWidgets('el selector no altera texto, alcance ni scroll de Buscar', (
    tester,
  ) async {
    final flow = _Flow(initialLocation: RoutesConfig.search);
    await flow.pump(tester);
    // La pestaña Buscar tiene su consulta.
    await flow.type(tester, 'toy');
    await flow.settle(tester);
    final tabBefore = flow.tabSearch.cubit.state;
    expect(tabBefore.query, 'toy');
    expect(tabBefore.results, isNotEmpty);

    // Al selector se llega desde Comparar.
    flow.router.go(RoutesConfig.compare);
    await flow.settle(tester);
    // La posición de Buscar queda guardada; el selector no debe tocarla.
    final scopeKey = tabBefore.scope!.key;
    flow.tabScroll.save(ScrollConfig.searchSectionKey, scopeKey, 321);
    await tester.tap(find.text(AppTexts.compareAddVehicleLabel));
    await flow.settle(tester);
    expect(_pickerTitle, findsOneWidget);
    // Selector con su propia consulta: vacía, con su propia instancia.
    expect(flow.pickerSearch.cubit.state.query, isEmpty);
    expect(identical(flow.pickerSearch.cubit, flow.tabSearch.cubit), isFalse);
    await flow.type(tester, 'civic');
    await flow.settle(tester);
    expect(flow.pickerSearch.cubit.state.query, 'civic');
    expect(flow.tabSearch.cubit.state.query, 'toy');

    // Tocar un resultado lo agrega y cierra la hoja, sin abrir Detalle.
    await tester.tap(find.text('Civic').first);
    await flow.settle(tester);
    expect(_pickerTitle, findsNothing);
    expect(flow.router.state.uri.path, RoutesConfig.compare);
    final added = await flow.store.read('us');
    expect(added.single.modelName, 'Civic');
    expect(added.single.brand, 'Honda');
    expect(find.text('Civic'), findsOneWidget);
    expect(
      find.text(AppTexts.compareAddedNotice('Honda Civic')),
      findsOneWidget,
    );
    flow.compare.dismissNotice();

    // Buscar sigue exactamente como se dejó.
    final tabAfter = flow.tabSearch.cubit.state;
    expect(tabAfter.query, 'toy');
    expect(tabAfter.scope, tabBefore.scope);
    expect(tabAfter.scopeBrand, tabBefore.scopeBrand);
    expect(tabAfter.results, tabBefore.results);
    expect(tabAfter.filters, tabBefore.filters);
    expect(
      flow.tabScroll.offsetFor(ScrollConfig.searchSectionKey, scopeKey),
      321,
    );
  });

  testWidgets('el selector avisa si el vehículo ya está, sin duplicar', (
    tester,
  ) async {
    final flow = _Flow(
      initialVehicles: 1,
      initialLocation: RoutesConfig.compare,
    );
    await flow.pump(tester);
    // 'Camry' ya está: se elige otra vez desde el selector.
    await tester.tap(find.byType(CompareEmptySlotWidget).first);
    await flow.settle(tester);
    await flow.type(tester, 'camry');
    await flow.settle(tester);
    await tester.tap(find.text('Camry').first);
    await flow.settle(tester);
    // La hoja sigue abierta y el aviso aparece dentro de ella.
    expect(_pickerTitle, findsOneWidget);
    expect(await flow.store.read('us'), hasLength(1));
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.text(AppTexts.compareAlreadyAddedNotice),
      ),
      findsOneWidget,
    );
    flow.compare.dismissNotice();
  });

  group('Detalle → Comparar', () {
    Future<_Flow> openDetail(
      WidgetTester tester, {
      int initialVehicles = 0,
    }) async {
      final flow = _Flow(initialVehicles: initialVehicles);
      await flow.pump(tester);
      unawaited(flow.router.push<void>(RoutesConfig.detail, extra: testArgs()));
      await flow.settle(tester);
      return flow;
    }

    testWidgets('agrega el vehículo, navega a Comparar y abre el selector', (
      tester,
    ) async {
      final flow = await openDetail(tester);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      final saved = await flow.store.read('us');
      expect(saved.single.modelName, 'Corolla');
      expect(saved.single.brand, 'Toyota');
      expect(saved.single.year, 2020);
      // Con exactamente un vehículo, el selector se abre solo.
      expect(_pickerTitle, findsOneWidget);
      // Cerrar el selector deja la pestaña Comparar con el vehículo.
      await tester.tap(_pickerClose);
      await flow.settle(tester);
      expect(flow.router.state.uri.path, RoutesConfig.compare);
      expect(find.text('Corolla'), findsOneWidget);
      expect(_pickerTitle, findsNothing);
    });

    testWidgets('con 2 vehículos no abre el selector', (tester) async {
      final flow = await openDetail(tester, initialVehicles: 1);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      expect(await flow.store.read('us'), hasLength(2));
      expect(flow.router.state.uri.path, RoutesConfig.compare);
      expect(_pickerTitle, findsNothing);
      expect(find.text(AppTexts.compareTableTitle), findsOneWidget);
    });

    testWidgets('si ya estaba no se duplica y navega igual', (tester) async {
      final flow = await openDetail(tester);
      await flow.store.write('us', [
        compareSlot(model: 'Corolla', year: 2020),
        compareSlot(model: 'Camry', year: 2025),
      ]);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      expect(await flow.store.read('us'), hasLength(2));
      expect(flow.router.state.uri.path, RoutesConfig.compare);
      expect(find.text(AppTexts.compareAlreadyAddedNotice), findsOneWidget);
      flow.compare.dismissNotice();
    });

    Finder sheetText(String text) => find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text(text),
    );

    testWidgets('con 3 vehículos abre la hoja de lleno sin navegar', (
      tester,
    ) async {
      final flow = await openDetail(tester, initialVehicles: 3);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      expect(_fullSheetTitle, findsOneWidget);
      // Las 3 filas actuales, con marca y modelo; nada cambió ni se navegó.
      expect(sheetText('Camry'), findsOneWidget);
      expect(sheetText('RAV4'), findsOneWidget);
      expect(sheetText('Prius'), findsOneWidget);
      expect(find.text(AppTexts.compareFullSheetClearLabel), findsOneWidget);
      expect(flow.router.state.uri.path, RoutesConfig.detail);
      expect(await flow.store.read('us'), hasLength(3));
      expect(find.text(AppTexts.compareFullNotice), findsNothing);
    });

    testWidgets('tocar un vehículo lo reemplaza, mantiene el orden y navega', (
      tester,
    ) async {
      final flow = await openDetail(tester, initialVehicles: 3);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      await tester.tap(sheetText('RAV4'));
      await flow.settle(tester);
      final saved = await flow.store.read('us');
      expect(saved.map((slot) => slot.modelName), [
        'Camry',
        'Corolla',
        'Prius',
      ]);
      expect(flow.router.state.uri.path, RoutesConfig.compare);
      expect(_fullSheetTitle, findsNothing);
      expect(
        find.text(
          AppTexts.compareReplacedNotice('Toyota RAV4', 'Toyota Corolla'),
        ),
        findsOneWidget,
      );
      flow.compare.dismissNotice();
    });

    testWidgets('"Limpiar todo y agregar" deja solo el nuevo y navega', (
      tester,
    ) async {
      final flow = await openDetail(tester, initialVehicles: 3);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      await tester.tap(find.text(AppTexts.compareFullSheetClearLabel));
      await flow.settle(tester);
      final saved = await flow.store.read('us');
      expect(saved.map((slot) => slot.modelName), ['Corolla']);
      expect(flow.router.state.uri.path, RoutesConfig.compare);
      expect(
        find.text(AppTexts.compareStartedNewNotice('Toyota Corolla')),
        findsOneWidget,
      );
      flow.compare.dismissNotice();
    });

    testWidgets('Cancelar deja todo como estaba y sigue en Detalle', (
      tester,
    ) async {
      final flow = await openDetail(tester, initialVehicles: 3);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      await tester.tap(find.text(AppTexts.cancelLabel));
      await flow.settle(tester);
      expect(_fullSheetTitle, findsNothing);
      expect(flow.router.state.uri.path, RoutesConfig.detail);
      final saved = await flow.store.read('us');
      expect(saved.map((slot) => slot.modelName), ['Camry', 'RAV4', 'Prius']);
    });
  });
}
