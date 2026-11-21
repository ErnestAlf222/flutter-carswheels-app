import 'package:cars_wheels_app/app/favorites/favorite_card_cubits.dart';
import 'package:cars_wheels_app/app/favorites/favorites_grid.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';

import '../support/brand_logos_test_support.dart';
import '../support/class_translator_test_support.dart';
import '../support/favorites_test_support.dart';

class _MockResolveSummary extends Mock implements ResolveGroupSummaryUseCase {}

class _MockResolvePhoto extends Mock implements ResolveModelPhotoUseCase {}

class _MockCancelSummaries extends Mock
    implements CancelPendingSummariesUseCase {}

class _MockCancelPhotos extends Mock implements CancelPendingPhotosUseCase {}

final FavoriteCardCubitsFactory _factory = FavoriteCardCubitsFactory(
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

FavoritePhotoEntity _photo(int width, int height) => FavoritePhotoEntity(
  thumbnailUrl: 'https://ejemplo.test/$width.jpg',
  authorName: 'Ana',
  licenseName: 'CC BY-SA 4.0',
  sourceUrl: 'https://ejemplo.test/origen',
  isReference: false,
  widthPixels: width,
  heightPixels: height,
);

FavoriteEntity _fav(
  String model,
  int minute, {
  String brand = 'Toyota',
  String market = 'us',
  double? maxKm,
  FavoritePhotoEntity? photo,
}) => testFavorite(
  model: model,
  brand: brand,
  marketCode: market,
  savedAt: DateTime(2026, 1, 1, 0, minute),
  snapshot: FavoriteSnapshotEntity(
    label: market == 'mx' ? 'Gasolina' : 'Mediano',
    engineKinds: const ['gasoline'],
    minKmPerLiter: 10,
    maxKmPerLiter: maxKm ?? 12,
    variantNames: [model],
    photo: photo,
  ),
);

class _Harness {
  _Harness(this.tester);

  final WidgetTester tester;
  final List<List<FavoriteEntity>> compared = [];
  int goToCompareCalls = 0;
  late final FavoritesCubit cubit;

  Future<void> pump(
    List<FavoriteEntity> initial, {
    Map<String, int> capacity = const {},
    double textScale = 1.0,
    bool disableAnimations = true,
  }) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    cubit = buildFavoritesCubit(
      datasource: InMemoryFavoritesDatasource(initial),
    );
    addTearDown(cubit.close);
    await tester.pumpWidget(
      RepositoryProvider<FavoriteCardCubitsFactory>.value(
        value: _factory,
        child: MultiBlocProvider(
          providers: [
            BlocProvider<FavoritesCubit>.value(value: cubit),
            BlocProvider<BrandLogosCubit>.value(
              value: buildMockBrandLogosCubit(),
            ),
          ],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations: disableAnimations,
                textScaler: TextScaler.linear(textScale),
              ),
              child: child!,
            ),
            home: withClassTranslator(
              FavoritesPage(
                selectorBuilder: (_) => const SizedBox(width: 120),
                gridBuilder: buildFavoritesGrid,
                onOpen: (_, _) {},
                onExplore: (_) {},
                loadCompareCapacity: (_) async => capacity,
                onCompare: (_, favorites) async {
                  compared.add(favorites);
                  return true;
                },
                onGoToCompare: (_) => goToCompareCalls++,
              ),
            ),
          ),
        ),
      ),
    );
    await settle();
  }

  Future<void> settle() async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  List<String> get names => [
    for (final card in tester.widgetList<ModelGridCardWidget>(
      find.byType(ModelGridCardWidget),
    ))
      card.group.name,
  ];

  // Los nombres en el orden visual: de arriba abajo y, a igual altura, de izquierda a derecha.
  List<String> get visualNames {
    final entries =
        [
          for (final element in find.byType(ModelGridCardWidget).evaluate())
            (
              name: (element.widget as ModelGridCardWidget).group.name,
              top: tester.getTopLeft(find.byWidget(element.widget)),
            ),
        ]..sort((a, b) {
          final byTop = a.top.dy.compareTo(b.top.dy);
          return byTop != 0 ? byTop : a.top.dx.compareTo(b.top.dx);
        });
    return [for (final entry in entries) entry.name];
  }

  Finder get selectAction => find.bySemanticsLabel(FavoritesTexts.selectAction);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('mosaico', () {
    testWidgets('las tarjetas miden distinto según la proporción de su foto', (
      tester,
    ) async {
      final harness = _Harness(tester);
      await harness.pump([
        _fav('Ancha', 3, photo: _photo(1500, 1000)),
        _fav('Alta', 2, photo: _photo(750, 1000)),
        _fav('Sin foto', 1),
      ]);
      final heights = {
        for (final card in tester.widgetList<ModelGridCardWidget>(
          find.byType(ModelGridCardWidget),
        ))
          card.group.name: tester.getSize(find.byWidget(card)).height,
      };
      expect(heights['Alta']!, greaterThan(heights['Ancha']!));
      expect(heights['Sin foto']!, isNot(heights['Alta']));
      expect(tester.takeException(), isNull);
    });

    testWidgets('el rango limita las fotos extremas', (tester) async {
      final harness = _Harness(tester);
      await harness.pump([
        _fav('Panorama', 2, photo: _photo(6000, 1000)),
        _fav('Torre', 1, photo: _photo(500, 3000)),
      ]);
      final sizes = {
        for (final card in tester.widgetList<ModelGridCardWidget>(
          find.byType(ModelGridCardWidget),
        ))
          card.group.name: tester.getSize(find.byWidget(card)),
      };
      final widthOf = sizes['Torre']!.width;
      final expectedMax = widthOf / FavoritesConfig.mosaicMinPhotoAspect;
      // La altura de la foto de la torre no pasa de ancho / proporción mínima.
      expect(sizes['Torre']!.height, lessThan(expectedMax + 400));
      expect(sizes['Panorama']!.height, lessThan(sizes['Torre']!.height));
    });

    testWidgets('cada tarjeta va en la columna más corta y en su propia capa', (
      tester,
    ) async {
      final harness = _Harness(tester);
      await harness.pump([
        _fav('C', 3, photo: _photo(750, 1000)),
        _fav('B', 2, photo: _photo(1500, 1000)),
        _fav('A', 1, photo: _photo(1500, 1000)),
      ]);
      // Recientes: C (alta) a la izquierda, B a la derecha, A bajo B (la columna más corta).
      final positions = {
        for (final card in tester.widgetList<ModelGridCardWidget>(
          find.byType(ModelGridCardWidget),
        ))
          card.group.name: tester.getTopLeft(find.byWidget(card)),
      };
      expect(positions['C']!.dx, lessThan(positions['B']!.dx));
      expect(positions['A']!.dx, positions['B']!.dx);
      expect(positions['A']!.dy, greaterThan(positions['B']!.dy));
      expect(
        find.descendant(
          of: find.byType(ModelGridCardWidget).first,
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
      );
    });

    testWidgets(
      'entrada en cascada: con animaciones aparece de forma escalonada',
      (tester) async {
        final harness = _Harness(tester);
        await harness.pump([
          _fav('A', 2),
          _fav('B', 1),
        ], disableAnimations: false);
        expect(find.byType(StaggeredEntryWidget), findsNWidgets(2));
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('quitar y "Deshacer" reacomoda sin errores', (tester) async {
      final harness = _Harness(tester);
      await harness.pump([
        _fav('A', 3),
        _fav('B', 2),
        _fav('C', 1),
      ], disableAnimations: false);
      await tester.tap(find.byType(FavoriteHeartButtonWidget).first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 600));
      expect(harness.names, ['B', 'C']);
      await harness.cubit.undo();
      await tester.pump(const Duration(milliseconds: 600));
      harness.cubit.dismissMessage();
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(tester.takeException(), isNull);
    });
  });

  group('orden', () {
    testWidgets('Recientes · A–Z · Más eficiente reordenan la lista', (
      tester,
    ) async {
      final harness = _Harness(tester);
      await harness.pump([
        _fav('Beta', 3, maxKm: 10),
        _fav('Alfa', 2, maxKm: 20),
        _fav('Gama', 1, maxKm: 15),
      ]);
      expect(find.text(FavoritesTexts.sortRecent), findsOneWidget);
      expect(find.text(FavoritesTexts.sortAlphabetical), findsOneWidget);
      expect(find.text(FavoritesTexts.sortMostEfficient), findsOneWidget);
      expect(harness.visualNames, ['Beta', 'Alfa', 'Gama']);

      await tester.tap(find.text(FavoritesTexts.sortAlphabetical));
      await harness.settle();
      expect(harness.visualNames, ['Alfa', 'Beta', 'Gama']);

      await tester.tap(find.text(FavoritesTexts.sortMostEfficient));
      await harness.settle();
      expect(harness.visualNames, ['Alfa', 'Gama', 'Beta']);

      await tester.tap(find.text(FavoritesTexts.sortRecent));
      await harness.settle();
      expect(harness.visualNames, ['Beta', 'Alfa', 'Gama']);
    });

    testWidgets(
      'se aplica tras el filtro de mercado y se conserva en el cubit',
      (tester) async {
        final harness = _Harness(tester);
        await harness.pump([
          _fav('Zeta', 3, market: 'mx', brand: 'Nissan'),
          _fav('Beta', 2),
          _fav('Alfa', 1),
        ]);
        await tester.tap(find.text(FavoritesTexts.sortAlphabetical));
        await harness.settle();
        await tester.tap(find.text(AppTexts.marketUnitedStatesLabel));
        await harness.settle();
        expect(harness.visualNames, ['Alfa', 'Beta']);
        final state = harness.cubit.state as FavoritesLoaded;
        expect(state.sortMode, FavoriteSortMode.alphabetical);
      },
    );
  });

  group('selección para comparar', () {
    testWidgets('sin favoritos no hay acción de seleccionar', (tester) async {
      final harness = _Harness(tester);
      await harness.pump(const []);
      expect(harness.selectAction, findsNothing);
    });

    testWidgets('al entrar aparece la barra con un único botón amarillo', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final harness = _Harness(tester);
      await harness.pump([_fav('Camry', 2), _fav('Versa', 1, market: 'mx')]);
      expect(find.byType(AccentButton), findsNothing);
      await tester.tap(harness.selectAction);
      await harness.settle();
      expect(find.byType(AccentButton), findsOneWidget);
      expect(find.text(FavoritesTexts.compareAction(0)), findsOneWidget);
      // Las casillas ocupan el lugar de los corazones.
      expect(find.byType(FavoriteHeartButtonWidget), findsNothing);
      expect(find.byType(FavoriteSelectCheckboxWidget), findsNWidgets(2));
      semantics.dispose();
    });

    testWidgets(
      'el botón se habilita con uno y el resto de otro mercado se atenúa',
      (tester) async {
        final harness = _Harness(tester);
        await harness.pump([_fav('Camry', 2), _fav('Versa', 1, market: 'mx')]);
        await tester.tap(harness.selectAction);
        await harness.settle();
        await tester.tap(find.byType(FavoriteSelectCheckboxWidget).first);
        await harness.settle();
        expect(find.text(FavoritesTexts.compareAction(1)), findsOneWidget);
        expect(find.text(FavoritesTexts.otherMarketNote), findsOneWidget);
        // La de México se ve atenuada y tocarla no la elige.
        final dimmed = tester
            .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
            .where((w) => w.opacity == FavoritesConfig.selectionDimmedOpacity);
        expect(dimmed, hasLength(1));
        await tester.tap(find.text('Versa'));
        await harness.settle();
        expect(find.text(FavoritesTexts.compareAction(1)), findsOneWidget);
      },
    );

    testWidgets('Comparar (N) entrega lo elegido y sale del modo', (
      tester,
    ) async {
      final harness = _Harness(tester);
      await harness.pump([_fav('Camry', 2), _fav('Corolla', 1)]);
      await tester.tap(harness.selectAction);
      await harness.settle();
      await tester.tap(find.text('Camry'));
      await tester.tap(find.text('Corolla'));
      await harness.settle();
      await tester.tap(find.text(FavoritesTexts.compareAction(2)));
      await harness.settle();
      expect(
        [for (final f in harness.compared.single) f.modelName],
        ['Camry', 'Corolla'],
      );
      expect(find.byType(AccentButton), findsNothing);
      expect(find.byType(FavoriteHeartButtonWidget), findsNWidgets(2));
    });

    testWidgets('con capacidad para uno no deja elegir un segundo', (
      tester,
    ) async {
      final harness = _Harness(tester);
      await harness.pump(
        [_fav('Camry', 2), _fav('Corolla', 1)],
        capacity: const {'us': 1},
      );
      await tester.tap(harness.selectAction);
      await harness.settle();
      await tester.tap(find.text('Camry'));
      await harness.settle();
      await tester.tap(find.text('Corolla'));
      await harness.settle();
      expect(find.text(FavoritesTexts.compareAction(1)), findsOneWidget);
      expect(find.text(FavoritesTexts.capacityNote(1)), findsOneWidget);
    });

    testWidgets('con la comparación llena avisa y ofrece "Ir a Comparar"', (
      tester,
    ) async {
      final harness = _Harness(tester);
      await harness.pump([_fav('Camry', 2)], capacity: const {'us': 0});
      await tester.tap(harness.selectAction);
      await harness.settle();
      await tester.tap(find.text('Camry'));
      await harness.settle();
      expect(find.text(FavoritesTexts.compareFullNote), findsOneWidget);
      await tester.tap(find.text(FavoritesTexts.goToCompareAction));
      expect(harness.goToCompareCalls, 1);
      expect(find.text(FavoritesTexts.compareAction(0)), findsOneWidget);
    });

    testWidgets('la X sale del modo de selección', (tester) async {
      final semantics = tester.ensureSemantics();
      final harness = _Harness(tester);
      await harness.pump([_fav('Camry', 1)]);
      await tester.tap(harness.selectAction);
      await harness.settle();
      expect(find.byIcon(Symbols.close), findsOneWidget);
      await tester.tap(
        find.bySemanticsLabel(FavoritesTexts.exitSelectionSemanticLabel),
      );
      await harness.settle();
      expect(find.byType(FavoriteSelectCheckboxWidget), findsNothing);
      expect(find.byType(AccentButton), findsNothing);
      semantics.dispose();
    });

    for (final scale in [1.0, 1.3]) {
      testWidgets('sin desbordes a 360 dp con escala de texto $scale', (
        tester,
      ) async {
        final harness = _Harness(tester);
        await harness.pump([
          _fav('Camry Hybrid LE Edición Especial', 3, photo: _photo(900, 1000)),
          _fav('Versa', 2, market: 'mx', brand: 'Nissan'),
          _fav('Corolla', 1, photo: _photo(1800, 1000)),
        ], textScale: scale);
        await tester.tap(harness.selectAction);
        await harness.settle();
        await tester.tap(find.byType(FavoriteSelectCheckboxWidget).first);
        await harness.settle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
