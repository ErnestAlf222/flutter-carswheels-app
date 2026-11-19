import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/class_translator_test_support.dart';
import '../../../support/market_test_support.dart';
import '../../../support/photos_test_support.dart';
import '../../../support/summaries_test_support.dart';
import '../../../support/tall_view_test_support.dart';

class _MockCatalogCubit extends MockCubit<CatalogState>
    implements CatalogCubit {}

class _FakeBuildContext extends Fake implements BuildContext {}

class _MockLogoPrecacheCubit extends MockCubit<LogoPrecacheState>
    implements LogoPrecacheCubit {}

/// Repositorio con los modelos de Acura; cuenta cuántas veces se consultó.
class _FakeCatalogRepository implements CatalogRepository {
  int modelCalls = 0;

  @override
  Future<List<int>> fetchYears() async => const [2026];

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async => const [];

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async {
    modelCalls++;
    return const [ModelEntity(name: 'Integra'), ModelEntity(name: 'MDX')];
  }
}

const _acuraCatalog = CatalogLoaded(
  year: 2026,
  availableYears: [2026],
  brands: [
    BrandEntity(name: 'Acura'),
    BrandEntity(name: 'Buick'),
  ],
);

// Regresión: la lista de modelos quedaba vacía al volver a Inicio.
void main() {
  late _FakeCatalogRepository repository;
  late ModelsCubit models;
  late ValueNotifier<bool> homeVisible;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    registerFallbackValue(_FakeBuildContext());
    registerFallbackValue(<String>[]);
  });

  setUp(() {
    useTallPhoneView();
    repository = _FakeCatalogRepository();
    models = ModelsCubit(
      getModelGroups: GetModelGroupsUseCase(
        repository: repository,
        grouper: const ModelGrouper(
          sortStrategy: AdaptiveSortStrategy<ModelGroupEntity>(
            smallListStrategy: BubbleSortStrategy<ModelGroupEntity>(),
            largeListStrategy: ShellSortStrategy<ModelGroupEntity>(),
          ),
        ),
      ),
    );
    homeVisible = ValueNotifier<bool>(true);
  });

  tearDown(() async {
    await models.close();
    homeVisible.dispose();
  });

  // Inicio sobre otra pestaña: se muestra o se desmonta como lo hace el menú.
  Future<void> pumpApp(WidgetTester tester) async {
    final catalog = _MockCatalogCubit();
    whenListen(
      catalog,
      const Stream<CatalogState>.empty(),
      initialState: _acuraCatalog,
    );
    final precache = _MockLogoPrecacheCubit();
    when(() => precache.state).thenReturn(const LogoPrecacheState());
    when(() => precache.precache(any(), any())).thenReturn(null);
    final market = buildMarketCubit();
    addTearDown(market.close);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: RepositoryProvider<ScrollOffsetStore>.value(
          value: ScrollOffsetStore(),
          child: withClassTranslator(
            MultiBlocProvider(
              providers: [
                BlocProvider<CatalogCubit>.value(value: catalog),
                BlocProvider<ModelsCubit>.value(value: models),
                BlocProvider<PhotosCubit>.value(value: buildMockPhotosCubit()),
                BlocProvider<SummariesCubit>.value(
                  value: buildMockSummariesCubit(),
                ),
                BlocProvider<BrandLogosCubit>.value(
                  value: buildMockBrandLogosCubit(),
                ),
                BlocProvider<LogoPrecacheCubit>.value(value: precache),
                BlocProvider<MarketCubit>.value(value: market),
              ],
              child: ValueListenableBuilder<bool>(
                valueListenable: homeVisible,
                builder: (context, visible, _) => visible
                    ? HomePage(onSearchTap: (_) {})
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('Inicio con marca elegida, ir a otra pestaña y volver: la '
      'lista sigue ahí', (tester) async {
    await pumpApp(tester);
    expect(models.state, isA<ModelsLoaded>());
    expect(find.byType(ModelGridCardWidget), findsNWidgets(2));
    homeVisible.value = false;
    await tester.pump();
    homeVisible.value = true;
    await tester.pump();
    await tester.pump();
    expect(find.byType(ModelGridCardWidget), findsNWidgets(2));
    expect(repository.modelCalls, 1);
  });

  testWidgets('cambio de mercado con Inicio fuera de pantalla: al volver '
      'carga los modelos de la marca en vez de quedar vacía', (tester) async {
    await pumpApp(tester);
    homeVisible.value = false;
    await tester.pump();
    // El cambio de mercado vacía la lista mientras Inicio no está montado.
    models.reset();
    expect(models.state, isA<ModelsInitial>());
    homeVisible.value = true;
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(models.state, isA<ModelsLoaded>());
    expect(find.byType(ModelGridCardWidget), findsNWidgets(2));
    expect(repository.modelCalls, 2);
  });
}
