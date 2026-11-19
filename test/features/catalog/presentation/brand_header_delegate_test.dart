import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/market_test_support.dart';

class _MockCatalogCubit extends MockCubit<CatalogState>
    implements CatalogCubit {}

class _MockBrandLogosCubit extends MockCubit<BrandLogosState>
    implements BrandLogosCubit {}

const _maxShrink = UiConfig.headerExpandedHeight - UiConfig.headerCompactHeight;
const _brandName = 'Marca0';

void _noop(int _) {}

BrandHeaderDelegate _delegate({
  int year = 2026,
  int selectedIndex = 0,
  int windowStart = 0,
  bool isRefreshing = false,
  Duration snapDuration = const Duration(
    milliseconds: AnimationConfig.headerSnapMilliseconds,
  ),
  ValueChanged<int>? onYearSelected,
}) => BrandHeaderDelegate(
  year: year,
  availableYears: const [2026, 2025, 2024],
  brandCount: 6,
  selectedIndex: selectedIndex,
  windowStart: windowStart,
  brandName: _brandName,
  isRefreshing: isRefreshing,
  snapDuration: snapDuration,
  onYearSelected: onYearSelected ?? _noop,
);

void main() {
  late _MockCatalogCubit catalogCubit;
  late _MockBrandLogosCubit logosCubit;
  late MarketCubit marketCubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    catalogCubit = _MockCatalogCubit();
    logosCubit = _MockBrandLogosCubit();
    marketCubit = buildMarketCubit();
    addTearDown(marketCubit.close);
    whenListen(
      catalogCubit,
      const Stream<CatalogState>.empty(),
      initialState: CatalogLoaded(
        year: 2026,
        availableYears: const [2026, 2025, 2024],
        brands: [
          for (int index = 0; index < 6; index++)
            BrandEntity(name: 'Marca$index'),
        ],
        selectedIndex: 0,
        windowStart: 0,
      ),
    );
    whenListen(
      logosCubit,
      const Stream<BrandLogosState>.empty(),
      initialState: const BrandLogosInitial(),
    );
    when(() => logosCubit.urlFor(any())).thenReturn(null);
  });

  Future<void> pumpDelegate(
    WidgetTester tester,
    BrandHeaderDelegate delegate,
    double shrinkOffset,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<CatalogCubit>.value(value: catalogCubit),
            BlocProvider<BrandLogosCubit>.value(value: logosCubit),
            BlocProvider<MarketCubit>.value(value: marketCubit),
          ],
          child: Scaffold(
            body: Builder(
              builder: (context) => SizedBox(
                height: delegate.maxExtent,
                child: delegate.build(context, shrinkOffset, false),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder compactTitle() => find.byWidgetPredicate(
    (widget) =>
        widget is Text &&
        widget.data == _brandName &&
        widget.style == AppTextStyles.cardTitle,
  );

  double opacityAbove(WidgetTester tester, Finder finder) => tester
      .widget<Opacity>(
        find.ancestor(of: finder, matching: find.byType(Opacity)).first,
      )
      .opacity;

  bool ignoringAbove(WidgetTester tester, Finder finder) => tester
      .widget<IgnorePointer>(
        find.ancestor(of: finder, matching: find.byType(IgnorePointer)).first,
      )
      .ignoring;

  testWidgets('sin encoger muestra el carrusel y oculta la barra compacta', (
    tester,
  ) async {
    await pumpDelegate(tester, _delegate(), 0);
    expect(opacityAbove(tester, find.byType(BrandCarouselWidget)), 1.0);
    expect(ignoringAbove(tester, find.byType(BrandCarouselWidget)), isFalse);
    expect(opacityAbove(tester, compactTitle()), 0.0);
    expect(ignoringAbove(tester, compactTitle()), isTrue);
  });

  testWidgets('encogido del todo muestra la barra y bloquea el carrusel', (
    tester,
  ) async {
    await pumpDelegate(tester, _delegate(), _maxShrink);
    expect(compactTitle(), findsOneWidget);
    expect(opacityAbove(tester, compactTitle()), 1.0);
    expect(ignoringAbove(tester, compactTitle()), isFalse);
    expect(opacityAbove(tester, find.byType(BrandCarouselWidget)), 0.0);
    expect(ignoringAbove(tester, find.byType(BrandCarouselWidget)), isTrue);
  });

  testWidgets('a mitad del fundido ambos contenidos tienen opacidad media', (
    tester,
  ) async {
    const middle =
        (AnimationConfig.headerContentFadeStart +
            AnimationConfig.headerContentFadeEnd) /
        2;
    await pumpDelegate(tester, _delegate(), _maxShrink * middle);
    expect(
      opacityAbove(tester, find.byType(BrandCarouselWidget)),
      closeTo(0.5, 0.001),
    );
    expect(opacityAbove(tester, compactTitle()), closeTo(0.5, 0.001));
  });

  testWidgets('elegir un año en el selector de la barra compacta lo notifica', (
    tester,
  ) async {
    final calls = <int>[];
    await pumpDelegate(
      tester,
      _delegate(onYearSelected: calls.add),
      _maxShrink,
    );
    await tester.tap(find.bySemanticsLabel(AppTexts.pickYearLabel).last);
    await tester.pump();
    await tester.tap(find.text('2025'));
    await tester.pump();
    expect(calls, [2025]);
  });

  test('las extensiones salen de la configuración', () {
    final delegate = _delegate();
    expect(delegate.maxExtent, UiConfig.headerExpandedHeight);
    expect(delegate.minExtent, UiConfig.headerCompactHeight);
  });

  test('la configuración de ajuste usa el rebote y la duración dada', () {
    final configuration = _delegate().snapConfiguration;
    expect(configuration.curve, AppCurves.reboundCurve);
    expect(
      configuration.duration,
      const Duration(milliseconds: AnimationConfig.headerSnapMilliseconds),
    );
    final instant = _delegate(snapDuration: Duration.zero).snapConfiguration;
    expect(instant.duration, Duration.zero);
  });

  test('shouldRebuild reacciona a cada dato y no a uno igual', () {
    final base = _delegate();
    expect(base.shouldRebuild(_delegate()), isFalse);
    expect(base.shouldRebuild(_delegate(year: 2025)), isTrue);
    expect(base.shouldRebuild(_delegate(selectedIndex: 1)), isTrue);
    expect(base.shouldRebuild(_delegate(windowStart: 1)), isTrue);
    expect(base.shouldRebuild(_delegate(isRefreshing: true)), isTrue);
    expect(base.shouldRebuild(_delegate(snapDuration: Duration.zero)), isTrue);
    expect(base.shouldRebuild(_delegate(onYearSelected: (_) {})), isTrue);
  });
}
