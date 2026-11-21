import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/app/favorites/favorite_card_cubits.dart';
import 'package:cars_wheels_app/app/search_results/search_card_cubits_factory.dart';
import 'package:cars_wheels_app/app/search_results/search_cubit_factory.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
  _Flow({
    List<FavoriteEntity> favorites = const [],
    this.initialLocation = RoutesConfig.home,
  }) {
    favoritesStore = InMemoryFavoritesDatasource(favorites);
    favoritesCubit = buildFavoritesCubit(datasource: favoritesStore);
    store = InMemoryCompareSelection();
    tabSearch = SearchHarness();
    pickerSearch = SearchHarness();
    initial = const [];
    router = buildAppRouter();
  }

  late final InMemoryFavoritesDatasource favoritesStore;
  late final FavoritesCubit favoritesCubit;
  final MarketCubit marketCubit = buildMarketCubit();

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
    addTearDown(favoritesCubit.close);
    addTearDown(marketCubit.close);
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
          RepositoryProvider<VehicleSpecSheetBuilder>.value(
            value: const VehicleSpecSheetBuilder(
              transmissionLabeler: TransmissionLabeler(),
              fuelTypeLabeler: FuelTypeLabeler(),
              driveLabeler: DriveLabeler(),
            ),
          ),
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
          RepositoryProvider<FavoriteCardCubitsFactory>.value(
            value: _cardFactory,
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
            BlocProvider<MarketCubit>.value(value: marketCubit),
            BlocProvider<SearchCubit>.value(value: tabSearch.cubit),
            BlocProvider<CompareCubit>.value(value: compare),
            BlocProvider<FavoritesCubit>.value(value: favoritesCubit),
            BlocProvider<CompareTableCubit>.value(value: table),
          ],
          child: MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: FavoritesMessageHost(bottomInset: 0, child: child!),
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

class _MockResolveSummary extends Mock implements ResolveGroupSummaryUseCase {}

class _MockResolvePhoto extends Mock implements ResolveModelPhotoUseCase {}

class _MockCancelSummaries extends Mock
    implements CancelPendingSummariesUseCase {}

class _MockCancelPhotos extends Mock implements CancelPendingPhotosUseCase {}

// Cubits de las tarjetas de Favoritos con dependencias que nunca se usan.
final FavoriteCardCubitsFactory _cardFactory = FavoriteCardCubitsFactory(
  createPhotos: () => SnapshotPhotosCubit(
    resolveModelPhoto: _MockResolvePhoto(),
    cancelPendingPhotos: _MockCancelPhotos(),
    keyBuilder: const PhotoKeyBuilder(selector: PhotoCandidateSelector()),
  ),
  createSummaries: () => SnapshotSummariesCubit(
    resolveGroupSummary: _MockResolveSummary(),
    cancelPendingSummaries: _MockCancelSummaries(),
    keyBuilder: const SummaryKeyBuilder(),
  ),
);

Finder get _hearts => find.byType(FavoriteHeartButtonWidget);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(testArgs());
  });

  group('corazón en las tarjetas', () {
    testWidgets(
      'Buscar lo muestra en cada tarjeta; tocarlo guarda sin abrir Detalle',
      (tester) async {
        final flow = _Flow(initialLocation: RoutesConfig.search);
        await flow.pump(tester);
        await flow.type(tester, 'toy');
        await flow.settle(tester);
        final cards = find.byType(ModelGridCardWidget);
        expect(cards, findsWidgets);
        expect(_hearts, findsNWidgets(tester.widgetList(cards).length));

        await tester.tap(_hearts.first);
        await flow.settle(tester);
        // No abrió Detalle y quedó guardado con mercado, año, marca y grupo.
        expect(flow.router.state.uri.path, RoutesConfig.search);
        final saved = (await flow.favoritesStore.readAll()).single;
        expect(saved.marketCode, 'us');
        expect(saved.year, 2025);
        expect(saved.brand, 'Toyota');
        expect(find.text(AppTexts.favoriteSavedMessage), findsOneWidget);

        // Otro toque lo quita.
        await tester.tap(_hearts.first);
        await flow.settle(tester);
        expect(await flow.favoritesStore.readAll(), isEmpty);
        flow.favoritesCubit.dismissMessage();
      },
    );

    testWidgets(
      'la hoja del selector de Comparar no lleva corazón: sigue su botón',
      (tester) async {
        final flow = _Flow(initialLocation: RoutesConfig.compare);
        await flow.pump(tester);
        await tester.tap(find.text(AppTexts.compareAddVehicleLabel));
        await flow.settle(tester);
        await flow.type(tester, 'toy');
        await flow.settle(tester);
        expect(find.byType(ComparePickerButtonWidget), findsWidgets);
        expect(_hearts, findsNothing);
      },
    );
  });

  group('corazón en Detalle', () {
    Future<_Flow> openDetail(WidgetTester tester) async {
      final flow = _Flow();
      await flow.pump(tester);
      unawaited(flow.router.push<void>(RoutesConfig.detail, extra: testArgs()));
      await flow.settle(tester);
      return flow;
    }

    testWidgets('alterna el favorito del modelo abierto y avisa', (
      tester,
    ) async {
      final flow = await openDetail(tester);
      expect(_hearts, findsOneWidget);
      await tester.tap(_hearts);
      await flow.settle(tester);
      final saved = (await flow.favoritesStore.readAll()).single;
      // Identidad de los argumentos de Detalle (Toyota Corolla 2020).
      expect(saved.identity.marketCode, 'us');
      expect(saved.year, 2020);
      expect(saved.modelName, 'Corolla');
      expect(saved.snapshot.variantNames, ['Corolla']);
      expect(find.text(AppTexts.favoriteSavedMessage), findsOneWidget);

      await tester.tap(_hearts);
      await flow.settle(tester);
      expect(await flow.favoritesStore.readAll(), isEmpty);
      expect(find.text(AppTexts.favoriteRemovedMessage), findsOneWidget);
      flow.favoritesCubit.dismissMessage();
    });

    testWidgets('refleja en tiempo real lo que cambia desde otro lugar', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final flow = await openDetail(tester);
      final identity = favoriteIdentity(
        model: 'Corolla',
        brand: 'Toyota',
        year: 2020,
      );
      expect(
        find.bySemanticsLabel(AppTexts.favoriteAddSemanticLabel('Corolla')),
        findsOneWidget,
      );
      // Se guarda desde fuera de Detalle (otra pantalla).
      await tester.runAsync(() => flow.favoritesCubit.toggle(identity));
      await flow.settle(tester);
      expect(
        find.bySemanticsLabel(AppTexts.favoriteRemoveSemanticLabel('Corolla')),
        findsOneWidget,
      );
      await tester.runAsync(() => flow.favoritesCubit.toggle(identity));
      await flow.settle(tester);
      expect(
        find.bySemanticsLabel(AppTexts.favoriteAddSemanticLabel('Corolla')),
        findsOneWidget,
      );
      flow.favoritesCubit.dismissMessage();
      semantics.dispose();
    });
  });

  group('pantalla Favoritos', () {
    testWidgets(
      'abrir un favorito de otro mercado no cambia el mercado ni el año globales',
      (tester) async {
        final flow = _Flow(
          initialLocation: RoutesConfig.favorites,
          favorites: [
            testFavorite(
              model: 'Versa',
              brand: 'Nissan',
              year: 2024,
              marketCode: 'mx',
              snapshot: const FavoriteSnapshotEntity(
                label: 'Gasolina',
                variantNames: ['Versa Sense'],
              ),
            ),
          ],
        );
        await flow.pump(tester);
        expect(flow.marketCubit.market, Market.unitedStates);
        await tester.tap(find.text('Versa'));
        await flow.settle(tester);
        expect(flow.router.state.uri.path, RoutesConfig.detail);
        final args = flow.router.state.extra! as DetailArgsEntity;
        // Detalle recibe el mercado y el año del favorito...
        expect(args.market, Market.mexico);
        expect(args.year, 2024);
        expect(args.brand, 'Nissan');
        expect(args.variantNames, ['Versa Sense']);
        // ...y el mercado global de la app sigue siendo el de antes.
        expect(flow.marketCubit.market, Market.unitedStates);
      },
    );

    testWidgets('el estado vacío lleva a Inicio con su único botón amarillo', (
      tester,
    ) async {
      final flow = _Flow(initialLocation: RoutesConfig.favorites);
      await flow.pump(tester);
      expect(find.byType(AccentButton), findsOneWidget);
      await tester.tap(find.text(AppTexts.favoritesExploreLabel));
      await flow.settle(tester);
      expect(flow.router.state.uri.path, RoutesConfig.home);
    });

    testWidgets(
      'lo guardado aparece aquí y quitarlo con el corazón avisa con "Deshacer"',
      (tester) async {
        final flow = _Flow(initialLocation: RoutesConfig.search);
        await flow.pump(tester);
        await flow.type(tester, 'toy');
        await flow.settle(tester);
        await tester.tap(_hearts.first);
        await flow.settle(tester);
        flow.favoritesCubit.dismissMessage();
        flow.router.go(RoutesConfig.favorites);
        await flow.settle(tester);
        expect(find.byType(ModelGridCardWidget), findsOneWidget);
        expect(find.text(AppTexts.favoritesCountLabel(1)), findsOneWidget);
        await tester.tap(_hearts.first);
        await flow.settle(tester);
        expect(find.text(AppTexts.favoriteUndoLabel), findsOneWidget);
        await tester.tap(find.text(AppTexts.favoriteUndoLabel));
        await flow.settle(tester);
        expect(find.byType(ModelGridCardWidget), findsOneWidget);
        expect(await flow.favoritesStore.readAll(), hasLength(1));
        flow.favoritesCubit.dismissMessage();
      },
    );
  });
}
