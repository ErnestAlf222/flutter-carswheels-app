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
import 'package:mocktail/mocktail.dart';

import '../support/brand_logos_test_support.dart';
import '../support/class_translator_test_support.dart';
import '../support/favorites_test_support.dart';

class _MockResolveSummary extends Mock implements ResolveGroupSummaryUseCase {}

class _MockResolvePhoto extends Mock implements ResolveModelPhotoUseCase {}

class _MockCancelSummaries extends Mock
    implements CancelPendingSummariesUseCase {}

class _MockCancelPhotos extends Mock implements CancelPendingPhotosUseCase {}

// Cubits de las tarjetas con dependencias que nunca se usan: solo se siembran.
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

const FavoriteSnapshotEntity _camrySnapshot = FavoriteSnapshotEntity(
  label: 'Mediano',
  engineKinds: ['hybrid'],
  minKmPerLiter: 12.2,
  maxKmPerLiter: 15.4,
  variantNames: ['Camry LE'],
);

const FavoriteSnapshotEntity _mexicoSnapshot = FavoriteSnapshotEntity(
  label: 'Gasolina',
  engineKinds: ['gasoline'],
  minKmPerLiter: 10,
  maxKmPerLiter: 12,
);

FavoriteEntity _us(
  String model,
  int minute, {
  FavoriteSnapshotEntity? snapshot,
}) => testFavorite(
  model: model,
  savedAt: DateTime(2026, 1, 1, 0, minute),
  snapshot: snapshot ?? _camrySnapshot,
);

FavoriteEntity _mx(String model, int minute) => testFavorite(
  model: model,
  brand: 'Nissan',
  year: 2024,
  marketCode: 'mx',
  savedAt: DateTime(2026, 1, 1, 0, minute),
  snapshot: _mexicoSnapshot,
);

class _Harness {
  _Harness(this.tester);

  final WidgetTester tester;
  final List<FavoriteEntity> opened = [];
  final List<String> explored = [];
  late final InMemoryFavoritesDatasource store;
  late final FavoritesCubit cubit;

  Future<void> pump({
    List<FavoriteEntity> initial = const [],
    double textScale = 1.0,
  }) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    store = InMemoryFavoritesDatasource(initial);
    cubit = buildFavoritesCubit(datasource: store);
    addTearDown(cubit.close);
    // Los proveedores van sobre MaterialApp, como en la app.
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
                disableAnimations: true,
                textScaler: TextScaler.linear(textScale),
              ),
              child: FavoritesMessageHost(bottomInset: 0, child: child!),
            ),
            home: withClassTranslator(
              FavoritesPage(
                // Como el real: un selector de ancho fijo.
                selectorBuilder: (_) => const SizedBox(
                  width: 160,
                  child: Text('selector-de-prueba', maxLines: 1),
                ),
                gridBuilder: buildFavoritesGrid,
                onOpen: (_, favorite) => opened.add(favorite),
                onExplore: (_) => explored.add('inicio'),
                loadCompareCapacity: (_) async => const {},
                onCompare: (_, _) async => false,
                onGoToCompare: (_) {},
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
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'muestra el título, el contador y las tarjetas del más reciente al más antiguo',
    (tester) async {
      final harness = _Harness(tester);
      await harness.pump(
        initial: [_us('Antiguo', 1), _us('Medio', 2), _us('Reciente', 3)],
      );
      expect(find.text(AppTexts.favoritesPageTitle), findsOneWidget);
      expect(find.text(AppTexts.favoritesCountLabel(3)), findsOneWidget);
      expect(find.text('selector-de-prueba'), findsOneWidget);
      expect(harness.names, ['Reciente', 'Medio', 'Antiguo']);
    },
  );

  testWidgets('el contador usa el singular con uno', (tester) async {
    final harness = _Harness(tester);
    await harness.pump(initial: [_us('Camry', 1)]);
    expect(find.text('1 guardado'), findsOneWidget);
  });

  testWidgets(
    'las tarjetas salen de la instantánea: clase, consumo, insignia y corazón activo',
    (tester) async {
      final semantics = tester.ensureSemantics();
      final harness = _Harness(tester);
      await harness.pump(initial: [_us('Camry', 1), _mx('Versa', 2)]);
      // EE. UU.: la etiqueta de clase guardada y su rango de consumo.
      expect(find.text('Mediano'), findsOneWidget);
      expect(find.textContaining('12–15', findRichText: true), findsOneWidget);
      // México: combustible en lugar de clase.
      expect(find.text('Gasolina'), findsOneWidget);
      // Insignia de mercado y año, y un corazón activo en cada tarjeta.
      expect(find.text('🇺🇸 2025'), findsOneWidget);
      expect(find.text('🇲🇽 2024'), findsOneWidget);
      expect(find.byType(FavoriteHeartButtonWidget), findsNWidgets(2));
      expect(
        find.bySemanticsLabel(AppTexts.favoriteRemoveSemanticLabel('Camry')),
        findsOneWidget,
      );
      semantics.dispose();
    },
  );

  testWidgets('sin datos resueltos la tarjeta muestra solo "—", sin inventar', (
    tester,
  ) async {
    final harness = _Harness(tester);
    await harness.pump(
      initial: [_us('Camry', 1, snapshot: FavoriteSnapshotEntity.empty)],
    );
    expect(find.text(AppTexts.missingValueLabel), findsWidgets);
    expect(find.textContaining('km/l', findRichText: true), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('filtro por mercado', () {
    testWidgets('con un solo mercado no aparece', (tester) async {
      final harness = _Harness(tester);
      await harness.pump(initial: [_us('A', 1), _us('B', 2)]);
      expect(find.byType(FavoritesMarketFilterWidget), findsNothing);
      expect(find.text(AppTexts.favoritesFilterAll), findsNothing);
    });

    testWidgets('con ambos aparece "Todos · EE. UU. · México" y filtra', (
      tester,
    ) async {
      final harness = _Harness(tester);
      await harness.pump(initial: [_us('Camry', 1), _mx('Versa', 2)]);
      expect(find.text(AppTexts.favoritesFilterAll), findsOneWidget);
      expect(find.text(AppTexts.marketUnitedStatesLabel), findsOneWidget);
      expect(find.text(AppTexts.marketMexicoLabel), findsOneWidget);
      expect(harness.names, ['Versa', 'Camry']);

      await tester.tap(find.text(AppTexts.marketMexicoLabel));
      await harness.settle();
      expect(harness.names, ['Versa']);
      // El contador sigue siendo el total guardado.
      expect(find.text(AppTexts.favoritesCountLabel(2)), findsOneWidget);

      await tester.tap(find.text(AppTexts.marketUnitedStatesLabel));
      await harness.settle();
      expect(harness.names, ['Camry']);

      await tester.tap(find.text(AppTexts.favoritesFilterAll));
      await harness.settle();
      expect(harness.names, ['Versa', 'Camry']);
    });

    testWidgets(
      'al quitar el último de un mercado el filtro desaparece y vuelve a Todos',
      (tester) async {
        final harness = _Harness(tester);
        await harness.pump(initial: [_us('Camry', 1), _mx('Versa', 2)]);
        await tester.tap(find.text(AppTexts.marketMexicoLabel));
        await harness.settle();
        await tester.tap(find.byType(FavoriteHeartButtonWidget));
        await harness.settle();
        expect(find.byType(FavoritesMarketFilterWidget), findsNothing);
        expect(harness.names, ["Camry"]);
        harness.cubit.dismissMessage();
      },
    );
  });

  testWidgets('tocar una tarjeta pide abrir ese favorito', (tester) async {
    final harness = _Harness(tester);
    await harness.pump(initial: [_us('Camry', 1), _mx('Versa', 2)]);
    await tester.tap(find.text('Versa'));
    await harness.settle();
    expect(harness.opened.single.modelName, 'Versa');
    expect(harness.opened.single.marketCode, 'mx');
  });

  testWidgets(
    'el corazón quita con "Quitaste X" y "Deshacer" lo restaura en su posición',
    (tester) async {
      final harness = _Harness(tester);
      await harness.pump(
        initial: [_us('Antiguo', 1), _us('Medio', 2), _us('Reciente', 3)],
      );
      // Quita el de en medio (segundo corazón).
      await tester.tap(find.byType(FavoriteHeartButtonWidget).at(1));
      await harness.settle();
      expect(harness.names, ['Reciente', 'Antiguo']);
      expect(
        find.text(AppTexts.favoriteRemovedNamedMessage('Medio')),
        findsOneWidget,
      );
      expect(find.text(AppTexts.favoriteUndoLabel), findsOneWidget);
      // El mensaje no tapó la lista ni la abrió.
      expect(harness.opened, isEmpty);

      await tester.tap(find.text(AppTexts.favoriteUndoLabel));
      await harness.settle();
      expect(harness.names, ['Reciente', 'Medio', 'Antiguo']);
      expect(find.text(AppTexts.favoriteUndoLabel), findsNothing);
      expect(await harness.store.readAll(), hasLength(3));
    },
  );

  group('estado vacío', () {
    testWidgets(
      'ilustración dibujada, título, ayuda y un único botón amarillo',
      (tester) async {
        final harness = _Harness(tester);
        await harness.pump();
        expect(find.text(AppTexts.favoritesEmptyTitle), findsOneWidget);
        expect(find.text(AppTexts.favoritesEmptyBody), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is CustomPaint &&
                widget.painter is FavoritesEmptyPainter,
          ),
          findsOneWidget,
        );
        expect(find.byType(AccentButton), findsOneWidget);
        expect(find.text(AppTexts.favoritesExploreLabel), findsOneWidget);
        expect(find.byType(FavoritesMarketFilterWidget), findsNothing);

        await tester.tap(find.text(AppTexts.favoritesExploreLabel));
        expect(harness.explored, ['inicio']);
      },
    );

    testWidgets('al quitar el último aparece el estado vacío', (tester) async {
      final harness = _Harness(tester);
      await harness.pump(initial: [_us('Camry', 1)]);
      await tester.tap(find.byType(FavoriteHeartButtonWidget));
      await harness.settle();
      expect(find.text(AppTexts.favoritesEmptyTitle), findsOneWidget);
      expect(find.text('0 guardados'), findsOneWidget);
      harness.cubit.dismissMessage();
    });
  });

  for (final scale in [1.0, 1.3]) {
    testWidgets('sin desbordes a 360 dp con escala de texto $scale', (
      tester,
    ) async {
      final harness = _Harness(tester);
      await harness.pump(
        initial: [
          _us(
            'Un nombre de modelo muy largo que ocupa dos líneas completas',
            1,
          ),
          _mx('Versa', 2),
          _us('Camry', 3),
        ],
        textScale: scale,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(ModelGridCardWidget), findsNWidgets(3));
    });
  }
}
