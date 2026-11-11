import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/catalog/presentation/widgets/widgets.dart';
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

    testWidgets('seleccionado añade el anillo y la sombra de acento', (
      tester,
    ) async {
      await tester.pumpWidget(tile(selected: true, onTap: () {}));
      final shadows = decorationOf(tester).boxShadow!;
      expect(shadows.first.spreadRadius, CarouselConfig.selectedRingWidth);
      expect(shadows.length, 1 + AppShadows.accent.length);
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

    testWidgets('muestra 4 tiles aunque haya más marcas', (tester) async {
      stubCatalog(
        CatalogLoaded(
          year: 2026,
          availableYears: const [2026],
          brands: _brands(10),
        ),
      );
      await tester.pumpWidget(carousel());
      await tester.pumpAndSettle();
      expect(find.byType(BrandTileWidget), findsNWidgets(4));
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

    testWidgets('las flechas llaman al cubit', (tester) async {
      stubCatalog(
        CatalogLoaded(
          year: 2026,
          availableYears: const [2026],
          brands: _brands(10),
        ),
      );
      when(() => catalogCubit.showPreviousBrands()).thenReturn(null);
      when(() => catalogCubit.showNextBrands()).thenReturn(null);
      await tester.pumpWidget(carousel());
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel(AppTexts.previousBrandsLabel));
      await tester.tap(find.bySemanticsLabel(AppTexts.nextBrandsLabel));
      verify(() => catalogCubit.showPreviousBrands()).called(1);
      verify(() => catalogCubit.showNextBrands()).called(1);
    });

    testWidgets('la flecha tiene área tocable de 48 y círculo de 32', (
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
    });

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
