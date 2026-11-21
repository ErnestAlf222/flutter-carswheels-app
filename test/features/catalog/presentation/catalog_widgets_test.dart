import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogCubit extends MockCubit<CatalogState>
    implements CatalogCubit {}

class _MockBrandLogosCubit extends MockCubit<BrandLogosState>
    implements BrandLogosCubit {}

List<BrandEntity> _brands(int count) => [
  for (int index = 0; index < count; index++) BrandEntity(name: 'Marca$index'),
];

Widget _host({
  required CatalogCubit catalogCubit,
  required BrandLogosCubit logosCubit,
  required Widget child,
}) => MaterialApp(
  home: MultiBlocProvider(
    providers: [
      BlocProvider<CatalogCubit>.value(value: catalogCubit),
      BlocProvider<BrandLogosCubit>.value(value: logosCubit),
    ],
    child: Scaffold(body: child),
  ),
);

void main() {
  late _MockCatalogCubit catalogCubit;
  late _MockBrandLogosCubit logosCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    catalogCubit = _MockCatalogCubit();
    logosCubit = _MockBrandLogosCubit();
    when(() => logosCubit.state).thenReturn(const BrandLogosInitial());
    when(() => logosCubit.urlFor(any())).thenReturn(null);
  });

  void stubCatalog(CatalogState state) {
    when(() => catalogCubit.state).thenReturn(state);
    when(() => catalogCubit.loadBrands()).thenAnswer((_) async {});
  }

  group('BrandTileWidget', () {
    Widget tile({required bool selected, required VoidCallback onTap}) => _host(
      catalogCubit: catalogCubit,
      logosCubit: logosCubit,
      child: BrandTileWidget(
        brandName: 'Audi',
        selected: selected,
        onTap: onTap,
      ),
    );

    BoxDecoration decorationOf(WidgetTester tester) {
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(BrandTileWidget),
              matching: find.byType(Container),
            )
            .first,
      );
      return container.decoration! as BoxDecoration;
    }

    testWidgets('no seleccionado usa la sombra suave y llama onTap', (
      tester,
    ) async {
      int taps = 0;
      await tester.pumpWidget(tile(selected: false, onTap: () => taps++));
      expect(decorationOf(tester).boxShadow, AppShadows.soft);
      expect(find.text('Audi'), findsOneWidget);
      await tester.tap(find.byType(BrandTileWidget));
      expect(taps, 1);
    });

    testWidgets('seleccionado añade el anillo de tinta', (tester) async {
      await tester.pumpWidget(tile(selected: true, onTap: () {}));
      final shadows = decorationOf(tester).boxShadow!;
      expect(shadows.first.spreadRadius, CarouselConfig.selectedRingWidth);
      expect(shadows.length, 1);
      final name = tester.widget<Text>(find.text('Audi'));
      expect(name.style!.color, AppColors.ink);
      expect(name.style!.fontWeight, FontWeight.w700);
    });

    testWidgets('expone la etiqueta semántica', (tester) async {
      await tester.pumpWidget(tile(selected: false, onTap: () {}));
      expect(find.bySemanticsLabel(AppTexts.brandTileLabel('Audi')), findsOne);
    });
  });

  group('BrandCarouselWidget', () {
    Widget carousel() => _host(
      catalogCubit: catalogCubit,
      logosCubit: logosCubit,
      child: const BrandCarouselWidget(),
    );

    testWidgets('muestra 4 marcas completas y una asomando', (tester) async {
      stubCatalog(
        CatalogLoaded(
          year: 2026,
          availableYears: const [2026],
          brands: _brands(10),
        ),
      );
      await tester.pumpWidget(carousel());
      await tester.pumpAndSettle();
      // Cuatro completas más la quinta asomando por el borde.
      expect(find.byType(BrandTileWidget), findsNWidgets(5));
      final width = tester.getSize(find.byType(ListView)).width;
      final extent =
          width /
          (CarouselConfig.visibleBrandCount + CarouselConfig.peekFraction);
      for (final index in Iterable<int>.generate(4)) {
        final rect = tester.getRect(find.byType(BrandTileWidget).at(index));
        expect(rect.right, lessThanOrEqualTo(width));
        expect(rect.width, lessThanOrEqualTo(extent));
      }
    });

    testWidgets(
      'las flechas solo aparecen si hay más marcas que las visibles',
      (tester) async {
        stubCatalog(
          CatalogLoaded(
            year: 2026,
            availableYears: const [2026],
            brands: _brands(CarouselConfig.visibleBrandCount),
          ),
        );
        await tester.pumpWidget(carousel());
        await tester.pumpAndSettle();
        final hidden = tester
            .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
            .where((widget) => widget.opacity == 0);
        expect(hidden.length, 2);
      },
    );

    testWidgets('con más marcas que las visibles las dos flechas se ven', (
      tester,
    ) async {
      stubCatalog(
        CatalogLoaded(
          year: 2026,
          availableYears: const [2026],
          brands: _brands(10),
        ),
      );
      await tester.pumpWidget(carousel());
      await tester.pumpAndSettle();
      final shown = tester
          .widgetList<AnimatedOpacity>(find.byType(AnimatedOpacity))
          .where((widget) => widget.opacity == 1);
      expect(shown.length, greaterThanOrEqualTo(2));
    });

    testWidgets('con menos de 4 marcas muestra las que haya', (tester) async {
      stubCatalog(
        CatalogLoaded(
          year: 2026,
          availableYears: const [2026],
          brands: _brands(2),
        ),
      );
      await tester.pumpWidget(carousel());
      await tester.pumpAndSettle();
      expect(find.byType(BrandTileWidget), findsNWidgets(2));
    });

    testWidgets('la ventana es circular al final de la lista', (tester) async {
      stubCatalog(
        CatalogLoaded(
          year: 2026,
          availableYears: const [2026],
          brands: _brands(5),
          windowStart: 3,
        ),
      );
      await tester.pumpWidget(carousel());
      await tester.pumpAndSettle();
      expect(find.text('Marca3'), findsOneWidget);
      expect(find.text('Marca4'), findsOneWidget);
      expect(find.text('Marca0'), findsOneWidget);
      expect(find.text('Marca1'), findsOneWidget);
    });

    testWidgets(
      'al cambiar la ventana desde fuera la lista se desplaza a ella',
      (tester) async {
        final events = StreamController<CatalogState>.broadcast();
        addTearDown(events.close);
        CatalogLoaded window(int start) => CatalogLoaded(
          year: 2026,
          availableYears: const [2026],
          brands: _brands(10),
          windowStart: start,
        );
        whenListen(catalogCubit, events.stream, initialState: window(0));
        await tester.pumpWidget(carousel());
        await tester.pumpAndSettle();
        // La entrada es una sola, de la fila completa.
        expect(find.byType(AnimatedEntryWidget), findsOneWidget);
        expect(find.text('Marca0'), findsOneWidget);
        expect(find.text('Marca5'), findsNothing);

        events.add(window(1));
        await tester.pumpAndSettle();
        expect(find.byType(AnimatedEntryWidget), findsOneWidget);
        expect(find.text('Marca5'), findsOneWidget);
        expect(find.text('Marca0'), findsNothing);
      },
    );

    group('con el dedo y las flechas', () {
      // La activa va en el centro de la ventana, como la deja el cubit.
      CatalogLoaded loaded({int start = 0, int? selected}) => CatalogLoaded(
        year: 2026,
        availableYears: const [2026],
        brands: _brands(10),
        windowStart: start,
        selectedIndex: selected ?? (start + 2) % 10,
      );

      double offset(WidgetTester tester) => tester
          .state<ScrollableState>(find.byType(Scrollable))
          .position
          .pixels;

      setUp(() {
        when(() => catalogCubit.showBrandsFrom(any())).thenReturn(null);
        when(() => catalogCubit.selectBrand(any())).thenReturn(null);
      });

      testWidgets('arrastrar cambia el desplazamiento y avisa la ventana', (
        tester,
      ) async {
        stubCatalog(loaded());
        await tester.pumpWidget(carousel());
        await tester.pumpAndSettle();
        final before = offset(tester);
        await tester.drag(
          find.byType(BrandTileWidget).first,
          const Offset(-400, 0),
        );
        await tester.pumpAndSettle();
        expect(offset(tester), greaterThan(before));
        // Arrastrar a la izquierda muestra marcas posteriores.
        expect(find.text('Marca0'), findsNothing);
        final started =
            verify(() => catalogCubit.showBrandsFrom(captureAny()))
                    .captured
                    .single
                as int;
        expect(started, greaterThan(0));
      });

      testWidgets('arrastrar a la derecha vuelve y da la vuelta al inicio', (
        tester,
      ) async {
        stubCatalog(loaded());
        await tester.pumpWidget(carousel());
        await tester.pumpAndSettle();
        final before = offset(tester);
        await tester.drag(
          find.byType(BrandTileWidget).first,
          const Offset(200, 0),
        );
        await tester.pumpAndSettle();
        expect(offset(tester), lessThan(before));
        // Circular: antes de Marca0 viene la última.
        expect(find.text('Marca9'), findsOneWidget);
      });

      testWidgets('usa la física nativa de la plataforma y no queda bloqueada', (
        tester,
      ) async {
        stubCatalog(loaded());
        await tester.pumpWidget(carousel());
        await tester.pumpAndSettle();
        final scrollable = tester.widget<Scrollable>(find.byType(Scrollable));
        expect(scrollable.axisDirection, AxisDirection.right);
        // Sin física forzada: iOS rebota y Android estira según su plataforma.
        expect(scrollable.physics, isNull);
        expect(offset(tester), isNotNull);
      });

      testWidgets('las flechas desplazan una página de marcas', (tester) async {
        stubCatalog(loaded());
        await tester.pumpWidget(carousel());
        await tester.pumpAndSettle();
        final before = offset(tester);
        final width = tester.getSize(find.byType(ListView)).width;
        final page =
            width /
            (CarouselConfig.visibleBrandCount + CarouselConfig.peekFraction) *
            CarouselConfig.visibleBrandCount;
        await tester.tap(find.bySemanticsLabel(AppTexts.nextBrandsLabel));
        await tester.pumpAndSettle();
        expect(offset(tester) - before, closeTo(page, 1));
        expect(find.text('Marca4'), findsOneWidget);
        expect(find.text('Marca0'), findsNothing);
        verify(() => catalogCubit.showBrandsFrom(4)).called(1);
        await tester.tap(find.bySemanticsLabel(AppTexts.previousBrandsLabel));
        await tester.pumpAndSettle();
        expect(offset(tester), closeTo(before, 1));
        expect(find.text('Marca0'), findsOneWidget);
      });

      testWidgets('con disableAnimations la flecha salta sin animar', (
        tester,
      ) async {
        stubCatalog(loaded());
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: carousel(),
          ),
        );
        await tester.pumpAndSettle();
        final before = offset(tester);
        await tester.tap(find.bySemanticsLabel(AppTexts.nextBrandsLabel));
        await tester.pump();
        expect(offset(tester), greaterThan(before));
        expect(find.text('Marca4'), findsOneWidget);
      });

      testWidgets(
        'tocar una marca la selecciona y la seleccionada se resalta',
        (tester) async {
          stubCatalog(loaded(selected: 1));
          await tester.pumpWidget(carousel());
          await tester.pumpAndSettle();
          await tester.tap(find.text('Marca2'));
          verify(() => catalogCubit.selectBrand(2)).called(1);
          final selected = tester.widget<Text>(find.text('Marca1'));
          expect(selected.style!.fontWeight, FontWeight.w700);
          final other = tester.widget<Text>(find.text('Marca2'));
          expect(other.style!.fontWeight, isNot(FontWeight.w700));
        },
      );

      testWidgets('la lista no deja pasar lo horizontal al menú flotante', (
        tester,
      ) async {
        stubCatalog(loaded());
        final seen = <Axis>[];
        await tester.pumpWidget(
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              seen.add(notification.metrics.axis);
              return false;
            },
            child: carousel(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(
          find.byType(BrandTileWidget).first,
          const Offset(-100, 0),
        );
        await tester.pumpAndSettle();
        expect(seen, isNot(contains(Axis.horizontal)));
      });

      testWidgets('no choca con el scroll vertical de la página', (
        tester,
      ) async {
        stubCatalog(loaded());
        final page = ScrollController();
        addTearDown(page.dispose);
        await tester.pumpWidget(
          _host(
            catalogCubit: catalogCubit,
            logosCubit: logosCubit,
            child: CustomScrollView(
              controller: page,
              slivers: const [
                SliverToBoxAdapter(child: BrandCarouselWidget()),
                SliverToBoxAdapter(child: SizedBox(height: 2000)),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.drag(
          find.byType(BrandTileWidget).first,
          const Offset(0, -150),
        );
        await tester.pumpAndSettle();
        expect(page.offset, greaterThan(0));
        verifyNever(() => catalogCubit.showBrandsFrom(any()));
      });
    });

    testWidgets(
      'la flecha tiene área tocable de 44 y círculo con sombra de 36',
      (tester) async {
        stubCatalog(
          CatalogLoaded(
            year: 2026,
            availableYears: const [2026],
            brands: _brands(10),
          ),
        );
        await tester.pumpWidget(carousel());
        await tester.pumpAndSettle();
        final touchTargets = find.byType(InkWell);
        expect(touchTargets, findsNWidgets(2));
        for (final element in touchTargets.evaluate()) {
          expect(
            tester.getSize(find.byWidget(element.widget)),
            const Size.square(CarouselConfig.arrowTouchTargetSize),
          );
        }
        final circle = find.descendant(
          of: touchTargets.first,
          matching: find.byType(Container),
        );
        expect(
          tester.getSize(circle),
          const Size.square(CarouselConfig.arrowButtonSize),
        );
        final icon = tester.widget<Icon>(
          find.descendant(of: touchTargets.first, matching: find.byType(Icon)),
        );
        expect(icon.size, CarouselConfig.arrowIconSize);
      },
    );

    testWidgets('tocar un tile llama a selectBrand con su índice', (
      tester,
    ) async {
      stubCatalog(
        CatalogLoaded(
          year: 2026,
          availableYears: const [2026],
          brands: _brands(10),
        ),
      );
      when(() => catalogCubit.selectBrand(any())).thenReturn(null);
      await tester.pumpWidget(carousel());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marca2'));
      verify(() => catalogCubit.selectBrand(2)).called(1);
    });
  });
}
