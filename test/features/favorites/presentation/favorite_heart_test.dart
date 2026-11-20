import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/favorites/presentation/widgets/favorite_burst_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../support/favorites_test_support.dart';

class _Harness {
  _Harness(this.tester);

  final WidgetTester tester;
  late final InMemoryFavoritesDatasource store;
  late final FavoritesCubit cubit;
  int cardTaps = 0;
  int customTaps = 0;
  final List<String> haptics = [];

  Future<void> pump({
    bool disableAnimations = true,
    bool custom = false,
    List<FavoriteEntity> initial = const [],
  }) async {
    store = InMemoryFavoritesDatasource(initial);
    cubit = buildFavoritesCubit(datasource: store);
    addTearDown(cubit.close);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add('${call.arguments}');
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      BlocProvider<FavoritesCubit>.value(
        value: cubit,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(disableAnimations: disableAnimations),
            child: child!,
          ),
          home: Scaffold(
            // La tarjeta que contiene el corazón: tocarla cuenta aparte.
            body: InkWell(
              onTap: () => cardTaps++,
              child: SizedBox(
                width: 200,
                height: 200,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: FavoriteHeartButtonWidget(
                    identity: favoriteIdentity(),
                    onTap: custom ? () => customTaps++ : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
  }

  // El círculo es el primer DecoratedBox bajo el corazón.
  Color get circleColor {
    final box = tester.widget<DecoratedBox>(
      find
          .descendant(
            of: find.byType(FavoriteHeartButtonWidget),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );
    return (box.decoration as BoxDecoration).color!;
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets(
    'inactivo es un círculo blanco; activo, amarillo con corazón lleno',
    (tester) async {
      final harness = _Harness(tester);
      await harness.pump();
      expect(harness.circleColor, AppColors.surface);
      await tester.tap(find.byType(FavoriteHeartButtonWidget));
      await tester.pump(const Duration(milliseconds: 50));
      expect(harness.circleColor, AppColors.accent);
      harness.cubit.dismissMessage();
    },
  );

  testWidgets('el toque alterna el favorito y no llega a la tarjeta', (
    tester,
  ) async {
    final harness = _Harness(tester);
    await harness.pump();
    await tester.tap(find.byType(FavoriteHeartButtonWidget));
    await tester.pump(const Duration(milliseconds: 50));
    expect(harness.cardTaps, 0);
    expect(await harness.store.readAll(), hasLength(1));
    await tester.tap(find.byType(FavoriteHeartButtonWidget));
    await tester.pump(const Duration(milliseconds: 50));
    expect(harness.cardTaps, 0);
    expect(await harness.store.readAll(), isEmpty);
    harness.cubit.dismissMessage();
  });

  testWidgets('el área táctil mide 44 y el círculo, menos', (tester) async {
    final harness = _Harness(tester);
    await harness.pump();
    final touch = tester.getSize(
      find
          .descendant(
            of: find.byType(FavoriteHeartButtonWidget),
            matching: find.byType(SizedBox),
          )
          .first,
    );
    expect(touch, const Size(44, 44));
    expect(FavoritesConfig.heartCircleSize, lessThan(touch.width));
  });

  testWidgets('da retroalimentación háptica ligera al tocarlo', (tester) async {
    final harness = _Harness(tester);
    await harness.pump();
    await tester.tap(find.byType(FavoriteHeartButtonWidget));
    await tester.pump(const Duration(milliseconds: 50));
    expect(harness.haptics, ['HapticFeedbackType.selectionClick']);
    harness.cubit.dismissMessage();
  });

  testWidgets('con un onTap propio lo usa en lugar de alternar', (
    tester,
  ) async {
    final harness = _Harness(tester);
    await harness.pump(custom: true);
    await tester.tap(find.byType(FavoriteHeartButtonWidget));
    await tester.pump(const Duration(milliseconds: 50));
    expect(harness.customTaps, 1);
    expect(await harness.store.readAll(), isEmpty);
    expect(harness.cardTaps, 0);
  });

  group('animación de escala', () {
    double scaleOf(WidgetTester tester) => tester
        .widget<Transform>(
          find.descendant(
            of: find.byType(FavoriteHeartButtonWidget),
            matching: find.byType(Transform),
          ),
        )
        .transform
        .getMaxScaleOnAxis();

    testWidgets('al activar sube y vuelve a 1', (tester) async {
      final harness = _Harness(tester);
      await harness.pump(disableAnimations: false);
      expect(scaleOf(tester), 1.0);
      await tester.tap(find.byType(FavoriteHeartButtonWidget));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(
        const Duration(milliseconds: FavoritesConfig.heartPopMilliseconds ~/ 2),
      );
      expect(scaleOf(tester), greaterThan(1.1));
      await tester.pump(
        const Duration(milliseconds: FavoritesConfig.heartPopMilliseconds),
      );
      expect(scaleOf(tester), closeTo(1.0, 0.001));
      harness.cubit.dismissMessage();
    });

    testWidgets('con disableAnimations no hay escala', (tester) async {
      final harness = _Harness(tester);
      await harness.pump();
      await tester.tap(find.byType(FavoriteHeartButtonWidget));
      await tester.pump(const Duration(milliseconds: 20));
      expect(scaleOf(tester), 1.0);
      harness.cubit.dismissMessage();
    });

    testWidgets('un corazón ya activo al aparecer no anima', (tester) async {
      final harness = _Harness(tester);
      await harness.pump(disableAnimations: false, initial: [testFavorite()]);
      expect(scaleOf(tester), 1.0);
    });
  });

  group('mensaje de favoritos', () {
    testWidgets('se ve sobre la pantalla y "Deshacer" restaura', (
      tester,
    ) async {
      final store = InMemoryFavoritesDatasource([testFavorite()]);
      final cubit = buildFavoritesCubit(datasource: store);
      addTearDown(cubit.close);
      await tester.pumpWidget(
        BlocProvider<FavoritesCubit>.value(
          value: cubit,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: FavoritesMessageHost(bottomInset: 80, child: child!),
            ),
            home: const Scaffold(body: SizedBox.expand()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byType(Material), findsWidgets);
      expect(find.text(AppTexts.favoriteUndoLabel), findsNothing);

      await cubit.remove(testFavorite());
      await tester.pump();
      expect(
        find.text(AppTexts.favoriteRemovedNamedMessage('Camry')),
        findsOneWidget,
      );
      // Queda sobre el borde inferior, por encima del menú.
      final bottom = tester.getBottomLeft(find.byType(TextButton)).dy;
      expect(bottom, lessThanOrEqualTo(600 - 80));

      await tester.tap(find.text(AppTexts.favoriteUndoLabel));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text(AppTexts.favoriteUndoLabel), findsNothing);
      expect(await store.readAll(), hasLength(1));
    });
  });

  group('ráfaga de corazoncitos', () {
    Finder burst() => find.byWidgetPredicate(
      (widget) =>
          widget is CustomPaint && widget.painter is FavoriteBurstPainter,
    );

    testWidgets('solo al activar: sale, no bloquea toques y se retira sola', (
      tester,
    ) async {
      final harness = _Harness(tester);
      await harness.pump(disableAnimations: false);
      expect(burst(), findsNothing);
      await tester.tap(find.byType(FavoriteHeartButtonWidget));
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 200));
      expect(burst(), findsOneWidget);
      // Va en el Overlay (fuera de la tarjeta) y no recibe toques.
      expect(
        find.ancestor(of: burst(), matching: find.byType(IgnorePointer)),
        findsWidgets,
      );
      await tester.pump(
        const Duration(milliseconds: FavoritesConfig.burstMilliseconds),
      );
      await tester.pump(
        const Duration(milliseconds: FavoritesConfig.burstMilliseconds),
      );
      await tester.pump();
      expect(burst(), findsNothing);
      harness.cubit.dismissMessage();
    });

    testWidgets('al quitar el favorito no hay ráfaga', (tester) async {
      final harness = _Harness(tester);
      await harness.pump(disableAnimations: false, initial: [testFavorite()]);
      await tester.tap(find.byType(FavoriteHeartButtonWidget));
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 200));
      expect(await harness.store.readAll(), isEmpty);
      expect(burst(), findsNothing);
      harness.cubit.dismissMessage();
    });

    testWidgets('con disableAnimations solo cambia el estado', (tester) async {
      final harness = _Harness(tester);
      await harness.pump();
      await tester.tap(find.byType(FavoriteHeartButtonWidget));
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 200));
      expect(harness.circleColor, AppColors.accent);
      expect(burst(), findsNothing);
      harness.cubit.dismissMessage();
    });

    test('las partículas son de 6 a 8, variadas y siempre las mismas', () {
      final first = favoriteBurstParticles();
      final second = favoriteBurstParticles();
      expect(first.length, inInclusiveRange(6, 8));
      expect(first.map((p) => p.size).toSet().length, greaterThan(3));
      expect(first.map((p) => p.driftX).toSet().length, first.length);
      for (final (index, particle) in first.indexed) {
        expect(particle.size, second[index].size);
        expect(particle.driftX, second[index].driftX);
        expect(particle.rise, second[index].rise);
      }
      expect(FavoritesConfig.burstMilliseconds, inInclusiveRange(600, 800));
    });

    testWidgets('el painter dibuja a mitad y no dibuja al inicio', (
      tester,
    ) async {
      Future<void> paintAt(double progress) => tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomPaint(
            size: const Size(120, 120),
            painter: FavoriteBurstPainter(
              progress: progress,
              particles: favoriteBurstParticles(),
            ),
          ),
        ),
      );
      await paintAt(0.0);
      await paintAt(0.5);
      await paintAt(1.0);
      expect(tester.takeException(), isNull);
    });
  });
}
