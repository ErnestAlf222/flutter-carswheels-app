import 'dart:async';

import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/market_test_support.dart';
import '../../../support/search_test_support.dart';

class _CatalogRepository implements CatalogRepository {
  @override
  Future<List<int>> fetchYears() async => [2025];

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async => const [];

  @override
  Future<List<ModelEntity>> fetchModels(int year, String brand) async => const [
    ModelEntity(name: 'Camry'),
    ModelEntity(name: 'Camry Hybrid'),
  ];
}

Widget _wrap(SearchHarness harness, Widget home) => MultiRepositoryProvider(
  providers: [
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
  ],
  child: MultiBlocProvider(
    providers: [
      BlocProvider<SearchCubit>.value(value: harness.cubit),
      BlocProvider<BrandLogosCubit>.value(value: buildMockBrandLogosCubit()),
      BlocProvider<MarketCubit>.value(value: buildMarketCubit()),
    ],
    child: home,
  ),
);

// Sin animaciones: las pruebas avanzan el reloj a mano.
Widget _noAnimations(BuildContext context, Widget? child) => MediaQuery(
  data: MediaQuery.of(context).copyWith(disableAnimations: true),
  child: child!,
);

Widget _page(
  SearchHarness harness, {
  void Function(BuildContext, SearchResultEntity)? onOpen,
}) => _wrap(
  harness,
  MaterialApp(
    builder: _noAnimations,
    home: SearchPage(onOpenResult: onOpen ?? (_, _) {}),
  ),
);

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _type(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pump(const Duration(milliseconds: 350));
  await tester.pump(const Duration(milliseconds: 350));
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('sin consulta muestra recientes, marcas rápidas y el contexto', (
    tester,
  ) async {
    final harness = SearchHarness();
    harness.recents.stored = [
      RecentSearchEntity(
        key: 'civic',
        text: 'Civic',
        searchedAt: DateTime(2026),
      ),
    ];
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.text(AppTexts.searchPageTitle), findsOneWidget);
    expect(find.text('EE. UU. · 2025'), findsOneWidget);
    expect(find.text(AppTexts.searchRecentsTitle), findsOneWidget);
    expect(find.text('Civic'), findsOneWidget);
    expect(find.byIcon(Symbols.history), findsOneWidget);
    expect(find.text(AppTexts.searchClearAllLabel), findsOneWidget);
    expect(find.text(AppTexts.searchQuickBrandsTitle), findsOneWidget);
    expect(find.text('Toyota'), findsOneWidget);
    expect(find.text('Honda'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('sin recientes ni índice muestra el texto breve', (tester) async {
    final harness = SearchHarness(initialScope: null);
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.text(AppTexts.searchIdleHint), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('el progreso no reemplaza los resultados ya mostrados', (
    tester,
  ) async {
    final harness = SearchHarness();
    harness.source.gate = Completer<void>();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text(AppTexts.searchPreparingLabel), findsOneWidget);
    await _type(tester, 'toy');
    // Se puede buscar por marca mientras el índice se construye.
    expect(find.text('Toyota'), findsWidgets);
    expect(find.text(AppTexts.searchBrandRowSubtitle), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    harness.source.gate!.complete();
    await _settle(tester);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Camry'), findsOneWidget);
    expect(find.text('Toyota'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'tocar un resultado lo entrega a la capa app y guarda la reciente',
    (tester) async {
      final harness = SearchHarness();
      final opened = <SearchResultEntity>[];
      await tester.pumpWidget(_page(harness, onOpen: (_, r) => opened.add(r)));
      await _settle(tester);
      await _type(tester, 'cam');
      await tester.tap(find.text('Camry'));
      await _settle(tester);
      expect(opened, [
        const SearchResultEntity(
          brand: 'Toyota',
          groupName: 'Camry',
          year: 2025,
          marketCode: 'us',
        ),
      ]);
      expect(harness.recents.stored.single.key, 'cam');
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('una marca sola filtra por esa marca sin navegar', (
    tester,
  ) async {
    final harness = SearchHarness();
    final opened = <SearchResultEntity>[];
    await tester.pumpWidget(_page(harness, onOpen: (_, r) => opened.add(r)));
    await _settle(tester);
    await _type(tester, 'hon');
    await tester.tap(find.text(AppTexts.searchBrandRowSubtitle));
    await _settle(tester);
    expect(opened, isEmpty);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Honda',
    );
    expect(find.text('Accord'), findsOneWidget);
    expect(find.text('Civic'), findsOneWidget);
    expect(find.text('Corolla'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('sin resultados dice qué se buscó y dónde', (tester) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _type(tester, 'zzzz');
    expect(find.text(AppTexts.searchNoResultsTitle('zzzz')), findsOneWidget);
    expect(
      find.text(
        AppTexts.searchNoResultsScope(AppTexts.marketUnitedStatesLabel, 2025),
      ),
      findsOneWidget,
    );
    expect(find.text(AppTexts.searchNoResultsSuggestion), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('índice parcial: aviso discreto y reintento', (tester) async {
    final harness = SearchHarness();
    harness.source.failingBrands.add('Honda');
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.text(AppTexts.searchPartialMessage), findsOneWidget);
    harness.source.failingBrands.clear();
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    await _settle(tester);
    expect(find.text(AppTexts.searchPartialMessage), findsNothing);
    expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('sin conexión muestra el error de la app con Reintentar', (
    tester,
  ) async {
    final harness = SearchHarness();
    harness.source.failBrands = true;
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    expect(find.byType(ErrorStateWidget), findsOneWidget);
    harness.source.failBrands = false;
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    await _settle(tester);
    expect(find.byType(ErrorStateWidget), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('enviar con el teclado guarda la reciente; tocarla la repite', (
    tester,
  ) async {
    final harness = SearchHarness();
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await _type(tester, 'honda');
    expect(harness.recents.stored, isEmpty);
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await _settle(tester);
    expect(harness.recents.stored.single.text, 'honda');
    await tester.tap(find.byTooltip(AppTexts.searchClearSemanticLabel));
    await _settle(tester);
    expect(find.text(AppTexts.searchRecentsTitle), findsOneWidget);
    await tester.tap(find.text('honda'));
    await _settle(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'honda',
    );
    expect(find.text('Accord'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('borrar una reciente y borrar todo', (tester) async {
    final harness = SearchHarness();
    harness.recents.stored = [
      RecentSearchEntity(
        key: 'civic',
        text: 'Civic',
        searchedAt: DateTime(2026),
      ),
      RecentSearchEntity(
        key: 'camry',
        text: 'Camry',
        searchedAt: DateTime(2026),
      ),
    ];
    await tester.pumpWidget(_page(harness));
    await _settle(tester);
    await tester.tap(
      find.byTooltip(AppTexts.searchRecentRemoveSemanticLabel('Civic')),
    );
    await _settle(tester);
    expect(find.text('Civic'), findsNothing);
    expect(find.text('Camry'), findsOneWidget);
    await tester.tap(find.text(AppTexts.searchClearAllLabel));
    await _settle(tester);
    expect(find.text('Camry'), findsNothing);
    expect(harness.recents.stored, isEmpty);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'la consulta y los resultados se conservan al volver a la pantalla',
    (tester) async {
      final harness = SearchHarness();
      await tester.pumpWidget(_page(harness));
      await _settle(tester);
      await _type(tester, 'cam');
      expect(find.text('Camry'), findsOneWidget);
      // Se sale de la sección (la pantalla se destruye) y se vuelve.
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(_page(harness));
      await _settle(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'cam',
      );
      expect(find.text('Camry'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('los resultados abren Detalle con año, marca, grupo y mercado', (
    tester,
  ) async {
    final harness = SearchHarness();
    DetailArgsEntity? args;
    final router = GoRouter(
      initialLocation: RoutesConfig.search,
      routes: [
        GoRoute(
          path: RoutesConfig.search,
          builder: (_, _) =>
              const SearchPage(onOpenResult: openSearchResultInDetail),
        ),
        GoRoute(
          path: RoutesConfig.detail,
          builder: (_, state) {
            args = state.extra! as DetailArgsEntity;
            return const Scaffold(body: Text('detalle'));
          },
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _wrap(
        harness,
        MaterialApp.router(builder: _noAnimations, routerConfig: router),
      ),
    );
    await _settle(tester);
    await _type(tester, 'camry');
    await tester.tap(find.text('Camry').first);
    await _settle(tester);
    expect(find.text('detalle'), findsOneWidget);
    expect(args?.brand, 'Toyota');
    expect(args?.groupName, 'Camry');
    expect(args?.year, 2025);
    expect(args?.market, Market.unitedStates);
    expect(args?.variantNames, isNotEmpty);
    // Al volver, la búsqueda sigue como estaba.
    router.pop();
    await _settle(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'camry',
    );
    expect(find.text('Camry'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('la barra de inicio no es editable y lleva a búsqueda con foco', (
    tester,
  ) async {
    final harness = SearchHarness();
    final router = GoRouter(
      routes: [
        GoRoute(
          path: RoutesConfig.home,
          builder: (context, _) => Scaffold(
            body: HomeSearchBarWidget(onTap: () => openSearchFromHome(context)),
          ),
        ),
        GoRoute(
          path: RoutesConfig.search,
          builder: (_, _) => SearchPage(onOpenResult: (_, _) {}),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      _wrap(
        harness,
        MaterialApp.router(builder: _noAnimations, routerConfig: router),
      ),
    );
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    expect(find.text(AppTexts.searchHomeBarLabel), findsOneWidget);
    await tester.tap(find.byType(HomeSearchBarWidget));
    await _settle(tester);
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.focusNode!.hasFocus, isTrue);
    expect(harness.cubit.state.indexStatus?.phase, SearchIndexPhase.ready);
    await tester.pumpWidget(const SizedBox());
  });
}
