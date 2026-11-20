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
import 'package:cars_wheels_app/features/favorites/favorites.dart';
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
import '../support/favorites_test_support.dart';
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
  final FakeCompareVersionLabeler versionLabeler = FakeCompareVersionLabeler();

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await store.write('us', initial);
    // El cubit nace con lo guardado ya escrito.
    compare = buildCompareCubit(
      selection: store,
      noticeDuration: const Duration(seconds: 30),
    );
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
          RepositoryProvider<CompareVersionLabeler>.value(
            value: versionLabeler,
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
            BlocProvider<FavoritesCubit>(create: (_) => buildFavoritesCubit()),
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

// El primer cierre del selector es el del encabezado (el aviso trae el suyo).
Finder get _pickerClose => find
    .descendant(
      of: find.byType(SearchPage),
      matching: find.byIcon(Symbols.close),
    )
    .first;

Finder get _pickerButtons => find.byType(ComparePickerButtonWidget);

Finder get _addLabel => find.descendant(
  of: _pickerButtons,
  matching: find.text(AppTexts.comparePickerAddLabel),
);

Finder get _addedLabel => find.descendant(
  of: _pickerButtons,
  matching: find.text(AppTexts.comparePickerAddedLabel),
);

Finder get _fullSheetTitle => find.text(AppTexts.compareActionsFullTitle);

Finder get _substituteAction =>
    find.text(AppTexts.compareActionsSubstituteLabel);

Finder get _otherModelAction =>
    find.text(AppTexts.compareActionsOtherModelLabel);

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

    // El botón "Comparar" lo agrega y cierra la hoja, sin abrir Detalle.
    await tester.tap(_addLabel.first);
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

  group('selector: modo comparar', () {
    Future<_Flow> openPicker(
      WidgetTester tester, {
      int initialVehicles = 1,
      String query = 'toy',
    }) async {
      final flow = _Flow(
        initialVehicles: initialVehicles,
        initialLocation: RoutesConfig.compare,
      );
      await flow.pump(tester);
      await tester.tap(find.byType(CompareEmptySlotWidget).first);
      await flow.settle(tester);
      await flow.type(tester, query);
      await flow.settle(tester);
      return flow;
    }

    testWidgets('el botón aparece solo en el selector, no en Buscar', (
      tester,
    ) async {
      final flow = _Flow(initialLocation: RoutesConfig.search);
      await flow.pump(tester);
      await flow.type(tester, 'toy');
      await flow.settle(tester);
      expect(find.byType(ModelGridCardWidget), findsWidgets);
      expect(_pickerButtons, findsNothing);
      expect(_addLabel, findsNothing);

      flow.router.go(RoutesConfig.compare);
      await flow.settle(tester);
      await tester.tap(find.text(AppTexts.compareAddVehicleLabel));
      await flow.settle(tester);
      await flow.type(tester, 'toy');
      await flow.settle(tester);
      expect(_pickerButtons, findsWidgets);
    });

    testWidgets(
      'con el vehículo ya agregado la pastilla abre el menú; otro modelo lo cierra',
      (tester) async {
        final flow = await openPicker(tester);
        // Camry ya está: pastilla neutra; Corolla y RAV4 siguen con botón.
        expect(_addedLabel, findsOneWidget);
        expect(_addLabel, findsWidgets);
        await tester.tap(_addedLabel);
        await flow.settle(tester);
        expect(
          find.text(AppTexts.compareActionsAlreadyTitle('Toyota Camry')),
          findsOneWidget,
        );
        // Solo él en la comparación: no hay a quién sustituir.
        expect(_substituteAction, findsNothing);
        await tester.tap(_otherModelAction);
        await flow.settle(tester);
        expect(_pickerTitle, findsOneWidget);
        expect(flow.router.state.uri.path, RoutesConfig.compare);
        expect(await flow.store.read('us'), hasLength(1));
      },
    );

    testWidgets(
      'con el comparador lleno el botón abre el menú y sustituye desde el selector',
      (tester) async {
        final flow = await openPicker(tester, initialVehicles: 2);
        // Con la hoja abierta la comparación se llena (3 de 3).
        await flow.store.write('us', [
          compareSlot(model: 'Camry', year: 2025),
          compareSlot(model: 'RAV4', year: 2025),
          compareSlot(model: 'Prius', year: 2025),
        ]);
        await flow.settle(tester);
        await tester.tap(_addLabel.first);
        await flow.settle(tester);
        expect(_fullSheetTitle, findsOneWidget);
        // Nada se agregó todavía.
        expect(await flow.store.read('us'), hasLength(3));
        await tester.tap(_substituteAction);
        await flow.settle(tester);
        expect(find.text(AppTexts.compareSubstituteTitle), findsOneWidget);
        await tester.tap(
          find.descendant(
            of: find.byType(BottomSheet).last,
            matching: find.text('Prius'),
          ),
        );
        await flow.settle(tester);
        final saved = await flow.store.read('us');
        expect(saved, hasLength(3));
        expect(saved.map((slot) => slot.modelName), isNot(contains('Prius')));
        // Se cerró el selector y quedó el aviso de reemplazo.
        expect(_pickerTitle, findsNothing);
        expect(flow.router.state.uri.path, RoutesConfig.compare);
        flow.compare.dismissNotice();
      },
    );

    testWidgets('el botón no propaga el toque a la tarjeta', (tester) async {
      final flow = await openPicker(tester, initialVehicles: 0);
      await tester.tap(_addLabel.first);
      await flow.settle(tester);
      // Se cerró la hoja y no se abrió Detalle.
      expect(flow.router.state.uri.path, RoutesConfig.compare);
      expect(_pickerTitle, findsNothing);
      expect(await flow.store.read('us'), hasLength(1));
      flow.compare.dismissNotice();
    });

    testWidgets(
      'tocar la tarjeta abre Detalle sin agregar y vuelve a la hoja',
      (tester) async {
        final flow = await openPicker(tester, initialVehicles: 0);
        await tester.tap(find.byType(ModelGridCardWidget).first);
        await flow.settle(tester);
        expect(flow.router.state.uri.path, RoutesConfig.detail);
        expect(await flow.store.read('us'), isEmpty);

        // Atrás: la hoja sigue con el texto de búsqueda y sus resultados.
        flow.router.pop();
        await flow.settle(tester);
        expect(flow.router.state.uri.path, RoutesConfig.compare);
        expect(_pickerTitle, findsOneWidget);
        expect(flow.pickerSearch.cubit.state.query, 'toy');
        expect(find.byType(ModelGridCardWidget), findsWidgets);
        expect(find.widgetWithText(TextField, 'toy'), findsOneWidget);
      },
    );

    testWidgets('Comparar con otro desde ese Detalle no deja hojas huérfanas', (
      tester,
    ) async {
      final flow = await openPicker(tester, initialVehicles: 0);
      await tester.tap(find.byType(ModelGridCardWidget).first);
      await flow.settle(tester);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      expect(await flow.store.read('us'), hasLength(1));
      expect(flow.router.state.uri.path, RoutesConfig.compare);
      // Ni la hoja del selector ni Detalle quedan abiertos.
      expect(_pickerTitle, findsNothing);
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byType(DetailPage), findsNothing);
      // Otro intento abre una sola hoja nueva.
      await tester.tap(find.byType(CompareEmptySlotWidget).first);
      await flow.settle(tester);
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('las tarjetas con y sin botón miden lo mismo', (tester) async {
      final flow = await openPicker(tester);
      final heights = {
        for (final card in tester.widgetList(find.byType(ModelGridCardWidget)))
          tester.getSize(find.byWidget(card)).height,
      };
      expect(_addedLabel, findsOneWidget);
      expect(_addLabel, findsWidgets);
      expect(heights, hasLength(1));
      expect(flow.router.state.uri.path, RoutesConfig.compare);
    });
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

    testWidgets('si ya estaba abre el menú, sin duplicar ni navegar', (
      tester,
    ) async {
      final flow = await openDetail(tester);
      await flow.store.write('us', [
        compareSlot(model: 'Corolla', year: 2020),
        compareSlot(model: 'Camry', year: 2025),
      ]);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      expect(
        find.text(AppTexts.compareActionsAlreadyTitle('Toyota Corolla')),
        findsOneWidget,
      );
      expect(await flow.store.read('us'), hasLength(2));
      expect(flow.router.state.uri.path, RoutesConfig.detail);
      expect(find.text(AppTexts.compareAlreadyAddedNotice), findsNothing);
    });

    Finder sheetText(String text) => find.descendant(
      of: find.byType(BottomSheet),
      matching: find.text(text),
    );

    testWidgets('con 3 vehículos abre el menú sin navegar ni cambiar nada', (
      tester,
    ) async {
      final flow = await openDetail(tester, initialVehicles: 3);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      expect(_fullSheetTitle, findsOneWidget);
      expect(_substituteAction, findsOneWidget);
      expect(_otherModelAction, findsOneWidget);
      expect(flow.router.state.uri.path, RoutesConfig.detail);
      expect(await flow.store.read('us'), hasLength(3));
      expect(find.text(AppTexts.compareFullNotice), findsNothing);
    });

    testWidgets('"Sustituir" lista los autos con año y bandera y reemplaza', (
      tester,
    ) async {
      final flow = await openDetail(tester, initialVehicles: 3);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      await tester.tap(_substituteAction);
      await flow.settle(tester);
      // Solo hay una hoja: la lista reemplaza al menú.
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(sheetText('Camry'), findsOneWidget);
      expect(sheetText('RAV4'), findsOneWidget);
      expect(sheetText('Prius'), findsOneWidget);
      expect(
        find.textContaining(MarketConfig.unitedStatesFlag),
        findsNWidgets(3),
      );
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

    testWidgets('"Comparar con otro modelo" abre el selector en Comparar', (
      tester,
    ) async {
      final flow = await openDetail(tester, initialVehicles: 3);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      await tester.tap(_otherModelAction);
      await flow.settle(tester);
      expect(flow.router.state.uri.path, RoutesConfig.compare);
      expect(_pickerTitle, findsOneWidget);
      // No se agregó ni quitó nada.
      expect(await flow.store.read('us'), hasLength(3));
    });

    testWidgets('cerrar el menú deja todo como estaba y sigue en Detalle', (
      tester,
    ) async {
      final flow = await openDetail(tester, initialVehicles: 3);
      await tester.tap(find.text(AppTexts.compareWithOtherLabel));
      await flow.settle(tester);
      await tester.tapAt(const Offset(10, 10));
      await flow.settle(tester);
      expect(_fullSheetTitle, findsNothing);
      expect(flow.router.state.uri.path, RoutesConfig.detail);
      final saved = await flow.store.read('us');
      expect(saved.map((slot) => slot.modelName), ['Camry', 'RAV4', 'Prius']);
    });
  });
}
