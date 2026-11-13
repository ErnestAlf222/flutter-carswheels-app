import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/class_translator_test_support.dart';
import '../../../support/photos_test_support.dart';
import '../../../support/summaries_test_support.dart';

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

const _failedRequest = ModelsRequest(year: 2025, brand: 'Marca0');

ModelsLoaded _models(int total, int visible) => ModelsLoaded(
  groups: [
    for (int index = 0; index < total; index++)
      ModelGroupEntity(
        name: 'M$index',
        variants: [ModelEntity(name: 'M$index')],
      ),
  ],
  visibleCount: visible,
  year: 2026,
  brand: 'Marca0',
);

class _FakeBuildContext extends Fake implements BuildContext {}

class _MockLogoPrecacheCubit extends MockCubit<LogoPrecacheState>
    implements LogoPrecacheCubit {}

void main() {
  late _MockLogoPrecacheCubit precacheCubit;
  late _MockCatalogCubit catalogCubit;
  late _MockModelsCubit modelsCubit;
  late MockPhotosCubit photosCubit;
  late MockSummariesCubit summariesCubit;
  late StreamController<ModelsState> modelsEvents;
  late _MockBrandLogosCubit logosCubit;
  late StreamController<CatalogState> catalogEvents;
  late StreamController<BrandLogosState> logosEvents;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(_FakeBuildContext());
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    catalogCubit = _MockCatalogCubit();
    modelsCubit = _MockModelsCubit();
    photosCubit = buildMockPhotosCubit();
    summariesCubit = buildMockSummariesCubit();
    modelsEvents = StreamController<ModelsState>.broadcast();
    logosCubit = _MockBrandLogosCubit();
    precacheCubit = _MockLogoPrecacheCubit();
    when(() => precacheCubit.state).thenReturn(const LogoPrecacheState());
    when(() => precacheCubit.precache(any(), any())).thenReturn(null);
    catalogEvents = StreamController<CatalogState>.broadcast();
    logosEvents = StreamController<BrandLogosState>.broadcast();
    whenListen(
      logosCubit,
      logosEvents.stream,
      initialState: const BrandLogosInitial(),
    );
    when(() => logosCubit.state).thenReturn(const BrandLogosInitial());
    when(() => logosCubit.urlFor(any())).thenReturn(null);
    when(() => modelsCubit.load(any(), any())).thenAnswer((_) async {});
    when(() => modelsCubit.loadMore()).thenReturn(null);
    when(() => modelsCubit.retry()).thenAnswer((_) async {});
    when(() => catalogCubit.retry()).thenAnswer((_) async {});
    when(() => catalogCubit.showOlderYear()).thenAnswer((_) async {});
    when(() => catalogCubit.showNewerYear()).thenAnswer((_) async {});
  });

  tearDown(() {
    catalogEvents.close();
    logosEvents.close();
    modelsEvents.close();
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    required CatalogState catalog,
    ModelsState models = const ModelsInitial(),
  }) async {
    whenListen(catalogCubit, catalogEvents.stream, initialState: catalog);
    whenListen(modelsCubit, modelsEvents.stream, initialState: models);
    await tester.pumpWidget(
      MaterialApp(
        home: withClassTranslator(
          MultiBlocProvider(
            providers: [
              BlocProvider<CatalogCubit>.value(value: catalogCubit),
              BlocProvider<ModelsCubit>.value(value: modelsCubit),
              BlocProvider<PhotosCubit>.value(value: photosCubit),
              BlocProvider<SummariesCubit>.value(value: summariesCubit),
              BlocProvider<BrandLogosCubit>.value(value: logosCubit),
              BlocProvider<LogoPrecacheCubit>.value(value: precacheCubit),
            ],
            child: const HomePage(),
          ),
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
    // El encabezado tiene una copia expandida y otra compacta.
    expect(find.byType(YearSelectorWidget), findsNWidgets(2));
    expect(find.text('2026'), findsNWidgets(2));
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

  testWidgets('con isRefreshing no hay AppLoader y el contenido sigue', (
    tester,
  ) async {
    await pumpHome(
      tester,
      catalog: _loaded().refreshing(),
      models: _models(3, 3),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AppLoader), findsNothing);
    expect(find.byType(BrandCarouselWidget), findsOneWidget);
    expect(find.byType(ModelCardWidget), findsNWidgets(3));
    final dimmed = tester.widget<AnimatedOpacity>(
      find
          .descendant(
            of: find.byType(RefreshableContentWidget),
            matching: find.byType(AnimatedOpacity),
          )
          .first,
    );
    expect(dimmed.opacity, UiConfig.dimmedOpacity);
  });

  testWidgets('el fallo al cambiar de año muestra mensaje y reintenta', (
    tester,
  ) async {
    await pumpHome(
      tester,
      catalog: _loaded().failedRefresh(2025, const NetworkFailure('sin red')),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.refreshFailedLabel), findsOneWidget);
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    verify(() => catalogCubit.retry()).called(1);
  });

  group('precarga de logos', () {
    void stubLogosLoaded() {
      when(() => logosCubit.state)
          .thenReturn(const BrandLogosLoaded({'marca0': 'a.png'}));
      when(() => logosCubit.urlFor('Marca0')).thenReturn('a.png');
    }

    testWidgets('se dispara al cargar los logos con marcas presentes', (
      tester,
    ) async {
      await pumpHome(tester, catalog: _loaded());
      stubLogosLoaded();
      logosEvents.add(const BrandLogosLoaded({'marca0': 'a.png'}));
      await tester.pump();
      verify(() => precacheCubit.precache(any(), ['a.png'])).called(1);
    });

    testWidgets('se dispara al cargar las marcas con logos presentes', (
      tester,
    ) async {
      stubLogosLoaded();
      await pumpHome(tester, catalog: const CatalogLoading());
      catalogEvents.add(_loaded());
      await tester.pump();
      verify(() => precacheCubit.precache(any(), ['a.png'])).called(1);
    });

    testWidgets('no se dispara si los logos aún no cargaron', (tester) async {
      await pumpHome(tester, catalog: const CatalogLoading());
      catalogEvents.add(_loaded());
      await tester.pump();
      verifyNever(() => precacheCubit.precache(any(), any()));
    });

    testWidgets('respeta el máximo de logos a precargar', (tester) async {
      final brands = _brands(CarouselConfig.logoPrecacheMaxItems + 5);
      when(() => logosCubit.state).thenReturn(const BrandLogosLoaded({}));
      when(() => logosCubit.urlFor(any()))
          .thenAnswer((call) => '${call.positionalArguments.first}.png');
      await pumpHome(tester, catalog: const CatalogLoading());
      catalogEvents.add(_loaded(brands: brands));
      await tester.pump();
      final captured = verify(() => precacheCubit.precache(any(), captureAny()))
          .captured;
      expect(
        (captured.last as Iterable<String>).length,
        CarouselConfig.logoPrecacheMaxItems,
      );
    });
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

  group('fotos de los modelos', () {
    List<PhotoRequest> requestsFor(
      String brand,
      int year,
      Iterable<int> indexes,
    ) => [
      for (final index in indexes)
        PhotoRequest(brand: brand, model: 'M$index', year: year),
    ];

    testWidgets('al cargar modelos pide una vez los visibles con año y marca', (
      tester,
    ) async {
      await pumpHome(tester, catalog: _loaded());
      modelsEvents.add(_models(5, 3));
      await tester.pump();
      verify(
        () => photosCubit.requestPhotos(requestsFor('Marca0', 2026, [0, 1, 2])),
      ).called(1);
    });

    testWidgets('al cargar más pide solo los nuevos', (tester) async {
      final first = _models(5, 3);
      await pumpHome(tester, catalog: _loaded(), models: first);
      modelsEvents.add(first);
      await tester.pump();
      // La caché del cubit ya tiene los tres primeros.
      final slots = {
        for (final index in [0, 1, 2])
          photoKeyFor('Marca0', 'M$index', 2026): const PhotoLoading(),
      };
      when(() => photosCubit.state).thenReturn(PhotosState(slots: slots));
      clearInteractions(photosCubit);
      modelsEvents.add(first.copyWith(visibleCount: 5));
      await tester.pump();
      verify(
        () => photosCubit.requestPhotos(requestsFor('Marca0', 2026, [3, 4])),
      ).called(1);
    });

    testWidgets('al cambiar de marca cancela antes de pedir', (tester) async {
      await pumpHome(tester, catalog: _loaded());
      catalogEvents.add(_loaded(selectedIndex: 2));
      await tester.pump();
      modelsEvents.add(
        const ModelsLoaded(
          groups: [
            ModelGroupEntity(
              name: 'M0',
              variants: [ModelEntity(name: 'M0')],
            ),
          ],
          visibleCount: 1,
          year: 2026,
          brand: 'Marca2',
        ),
      );
      await tester.pump();
      verifyInOrder([
        () => photosCubit.cancelPending(),
        () => modelsCubit.load(2026, 'Marca2'),
        () => photosCubit.requestPhotos(requestsFor('Marca2', 2026, [0])),
      ]);
    });

    testWidgets('un refresco fallido no pide fotos', (tester) async {
      final loaded = _models(3, 3);
      await pumpHome(tester, catalog: _loaded(), models: loaded);
      modelsEvents.add(loaded.refreshing());
      await tester.pump();
      modelsEvents.add(
        loaded.failedRefresh(_failedRequest, const NetworkFailure('sin red')),
      );
      await tester.pump();
      verifyNever(() => photosCubit.requestPhotos(any()));
    });

    testWidgets('tras un refresco fallido las fotos no usan el año fallido', (
      tester,
    ) async {
      final loaded = _models(3, 3);
      await pumpHome(tester, catalog: _loaded(), models: loaded);
      final failed = loaded.failedRefresh(
        _failedRequest,
        const NetworkFailure('sin red'),
      );
      expect(failed.year, loaded.year);
      modelsEvents.add(failed);
      await tester.pump();
      verifyNever(() => photosCubit.requestPhotos(any()));
    });
  });

  group('resúmenes de los modelos', () {
    List<SummaryRequest> requestsFor(
      String brand,
      int year,
      Iterable<int> indexes,
    ) => [
      for (final index in indexes)
        SummaryRequest(
          brand: brand,
          groupName: 'M$index',
          year: year,
          variantNames: ['M$index'],
        ),
    ];

    testWidgets('al cargar modelos pide una vez los visibles', (tester) async {
      await pumpHome(tester, catalog: _loaded());
      modelsEvents.add(_models(5, 3));
      await tester.pump();
      verify(() => photosCubit.requestPhotos(any())).called(1);
      verify(
        () => summariesCubit.requestSummaries(
          requestsFor('Marca0', 2026, [0, 1, 2]),
        ),
      ).called(1);
    });

    testWidgets('pide los nombres de las variantes del grupo en orden', (
      tester,
    ) async {
      await pumpHome(tester, catalog: _loaded());
      modelsEvents.add(
        const ModelsLoaded(
          groups: [
            ModelGroupEntity(
              name: 'Civic',
              variants: [
                ModelEntity(name: 'Civic 4Dr'),
                ModelEntity(name: 'Civic 2Dr'),
              ],
            ),
          ],
          visibleCount: 1,
          year: 2026,
          brand: 'Marca0',
        ),
      );
      await tester.pump();
      verify(
        () => summariesCubit.requestSummaries(const [
          SummaryRequest(
            brand: 'Marca0',
            groupName: 'Civic',
            year: 2026,
            variantNames: ['Civic 4Dr', 'Civic 2Dr'],
          ),
        ]),
      ).called(1);
    });

    testWidgets('al cargar más pide solo los nuevos', (tester) async {
      final first = _models(5, 3);
      await pumpHome(tester, catalog: _loaded(), models: first);
      modelsEvents.add(first);
      await tester.pump();
      final slots = {
        for (final index in [0, 1, 2])
          summaryKeyFor('Marca0', 'M$index', 2026): const SummaryLoading(),
      };
      when(() => summariesCubit.state).thenReturn(SummariesState(slots: slots));
      clearInteractions(summariesCubit);
      modelsEvents.add(first.copyWith(visibleCount: 5));
      await tester.pump();
      verify(
        () => summariesCubit.requestSummaries(
          requestsFor('Marca0', 2026, [3, 4]),
        ),
      ).called(1);
    });

    testWidgets('al cambiar de marca cancela ambos cubits antes de pedir', (
      tester,
    ) async {
      await pumpHome(tester, catalog: _loaded());
      catalogEvents.add(_loaded(selectedIndex: 2));
      await tester.pump();
      modelsEvents.add(
        const ModelsLoaded(
          groups: [
            ModelGroupEntity(
              name: 'M0',
              variants: [ModelEntity(name: 'M0')],
            ),
          ],
          visibleCount: 1,
          year: 2026,
          brand: 'Marca2',
        ),
      );
      await tester.pump();
      verify(() => photosCubit.cancelPending()).called(1);
      verifyInOrder([
        () => summariesCubit.cancelPending(),
        () => modelsCubit.load(2026, 'Marca2'),
        () => summariesCubit.requestSummaries(requestsFor('Marca2', 2026, [0])),
      ]);
    });

    testWidgets('al cambiar de año cancela ambos cubits', (tester) async {
      await pumpHome(tester, catalog: _loaded());
      catalogEvents.add(_loaded(year: 2025));
      await tester.pump();
      verify(() => photosCubit.cancelPending()).called(1);
      verify(() => summariesCubit.cancelPending()).called(1);
    });

    testWidgets('un refresco fallido no pide ni cancela resúmenes', (
      tester,
    ) async {
      final loaded = _models(3, 3);
      await pumpHome(tester, catalog: _loaded(), models: loaded);
      modelsEvents.add(loaded.refreshing());
      await tester.pump();
      modelsEvents.add(
        loaded.failedRefresh(_failedRequest, const NetworkFailure('sin red')),
      );
      await tester.pump();
      verifyNever(() => summariesCubit.requestSummaries(any()));
      verifyNever(() => summariesCubit.cancelPending());
    });
  });

  group('modelos', () {
    testWidgets('loading muestra esqueletos y ningún AppLoader', (
      tester,
    ) async {
      await pumpHome(tester, catalog: _loaded(), models: const ModelsLoading());
      expect(find.byType(AppLoader), findsNothing);
      expect(
        find.byType(ModelCardSkeletonWidget),
        findsNWidgets(UiConfig.skeletonCardCount),
      );
    });

    testWidgets('refrescar modelos mantiene las tarjetas visibles', (
      tester,
    ) async {
      await pumpHome(
        tester,
        catalog: _loaded(),
        models: _models(3, 3).refreshing(),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppLoader), findsNothing);
      expect(find.byType(ModelCardWidget), findsNWidgets(3));
    });

    testWidgets('fallo al refrescar modelos muestra mensaje y reintenta', (
      tester,
    ) async {
      await pumpHome(
        tester,
        catalog: _loaded(),
        models: _models(
          3,
          3,
        ).failedRefresh(_failedRequest, const NetworkFailure('sin red')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(InlineMessageWidget), findsOneWidget);
      await tester.ensureVisible(find.text(AppTexts.retryButtonLabel));
      await tester.tap(find.text(AppTexts.retryButtonLabel));
      verify(() => modelsCubit.retry()).called(1);
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
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pump();
      await tester.tap(find.text(AppTexts.retryButtonLabel));
      verify(() => modelsCubit.retry()).called(1);
    });

    testWidgets('sin modelos muestra el estado vacío', (tester) async {
      await pumpHome(
        tester,
        catalog: _loaded(),
        models: const ModelsLoaded(
          groups: [],
          visibleCount: 0,
          year: 2026,
          brand: 'Honda',
        ),
      );
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });
  });

  group('carga por páginas', () {
    testWidgets('llegar al final con hasMore llama a loadMore', (tester) async {
      await pumpHome(tester, catalog: _loaded(), models: _models(30, 10));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -5000));
      await tester.pump();
      verify(() => modelsCubit.loadMore()).called(greaterThan(0));
    });

    testWidgets('llegar al final sin hasMore no llama a loadMore', (
      tester,
    ) async {
      await pumpHome(tester, catalog: _loaded(), models: _models(10, 10));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -5000));
      await tester.pump();
      verifyNever(() => modelsCubit.loadMore());
    });

    testWidgets('lejos del final no llama a loadMore', (tester) async {
      await pumpHome(tester, catalog: _loaded(), models: _models(30, 10));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -20));
      await tester.pump();
      verifyNever(() => modelsCubit.loadMore());
    });
  });
}
