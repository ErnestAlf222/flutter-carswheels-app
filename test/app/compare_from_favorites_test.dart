import 'package:cars_wheels_app/app/favorites/compare_from_favorites.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/compare_test_support.dart';
import '../support/favorites_test_support.dart';
import '../support/market_test_support.dart';

class _Harness {
  final InMemoryCompareSelection selection = InMemoryCompareSelection();
  late final MarketCubit market;
  late final CompareCubit compare;
  late final FavoritesCubit favorites;
  late final GoRouter router;
  bool? result;
  Map<String, int> capacity = const {};
  Object? lastExtra;
  FavoriteMessageKind? message;
  String? messageSubject;

  Future<void> pump(WidgetTester tester, List<FavoriteEntity> toCompare) async {
    market = buildMarketCubit();
    final source = FakeCompareMarketSource();
    compare = buildCompareCubit(selection: selection, market: source);
    // El comparador sigue al mercado global, como en la app.
    market.stream.listen((state) => source.switchTo(state.market.code));
    favorites = buildFavoritesCubit();
    addTearDown(market.close);
    addTearDown(compare.close);
    addTearDown(favorites.close);
    router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  capacity = await favoriteCompareCapacity(context);
                  result = await compareFromFavorites(context, toCompare);
                },
                child: const Text('comparar'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: RoutesConfig.compare,
          builder: (context, state) {
            lastExtra = state.extra;
            return const Scaffold(body: Text('pantalla-comparar'));
          },
        ),
      ],
    );
    await tester.pumpWidget(
      RepositoryProvider<ObserveCompareSelectionUseCase>.value(
        value: ObserveCompareSelectionUseCase(selection),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<MarketCubit>.value(value: market),
            BlocProvider<CompareCubit>.value(value: compare),
            BlocProvider<FavoritesCubit>.value(value: favorites),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> run(WidgetTester tester) async {
    await tester.tap(find.text('comparar'));
    // Las lecturas de la selección son asíncronas de verdad: se alterna reloj real y cuadros.
    for (final _ in List.generate(8, (n) => n)) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 40)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
    // Se anota el aviso y se retira: deja un temporizador que no debe quedar vivo.
    final state = favorites.state;
    if (state is FavoritesLoaded) {
      message = state.message;
      messageSubject = state.messageSubject;
    }
    favorites.dismissMessage();
  }
}

void main() {
  testWidgets('agrega a la comparación de su mercado, avisa y navega', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester, [
      testFavorite(model: 'Camry'),
      testFavorite(model: 'Corolla'),
    ]);
    await harness.run(tester);
    expect(harness.result, isTrue);
    expect(find.text('pantalla-comparar'), findsOneWidget);
    final saved = await harness.selection.read('us');
    expect([for (final slot in saved) slot.modelName], ['Camry', 'Corolla']);
    expect(harness.message, FavoriteMessageKind.addedToCompare);
    expect(harness.messageSubject, '2');
    // Con dos autos la comparación ya se muestra: no abre el selector.
    expect((harness.lastExtra! as dynamic).openPicker, isFalse);
  });

  testWidgets('con un solo auto en total abre el selector al llegar', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester, [testFavorite(model: 'Camry')]);
    await harness.run(tester);
    expect((harness.lastExtra! as dynamic).openPicker, isTrue);
  });

  testWidgets('un favorito de otro mercado cambia el mercado global en sitio', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.pump(tester, [
      testFavorite(model: 'Versa', brand: 'Nissan', marketCode: 'mx'),
      testFavorite(model: 'March', brand: 'Nissan', marketCode: 'mx'),
    ]);
    expect(harness.market.market, Market.unitedStates);
    await harness.run(tester);
    expect(harness.market.market, Market.mexico);
    expect(await harness.selection.read('mx'), hasLength(2));
    expect(await harness.selection.read('us'), isEmpty);
    expect(find.text('pantalla-comparar'), findsOneWidget);
  });

  testWidgets('la capacidad restante sale de lo ya guardado por mercado', (
    tester,
  ) async {
    final harness = _Harness();
    await harness.selection.write('us', [
      const CompareSlotEntity(
        marketCode: 'us',
        year: 2025,
        brand: 'Honda',
        groupKey: 'civic',
        modelName: 'Civic',
      ),
    ]);
    await harness.pump(tester, [testFavorite(model: 'Camry')]);
    await harness.run(tester);
    expect(harness.capacity['us'], CompareConfig.maxSlots - 1);
    expect(harness.capacity['mx'], CompareConfig.maxSlots);
  });

  testWidgets('lo que ya está en la comparación no se duplica', (tester) async {
    final harness = _Harness();
    await harness.pump(tester, [testFavorite(model: 'Camry')]);
    await harness.run(tester);
    expect(harness.result, isTrue);
    harness.router.go('/');
    await tester.pump(const Duration(milliseconds: 200));
    await harness.run(tester);
    expect(harness.result, isFalse);
    expect(await harness.selection.read('us'), hasLength(1));
  });
}
