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

// Ancho extremo: más que cualquier pantalla, como un logo horizontal muy largo.
const double _extremeLogoWidth = 900.0;

Future<void> _pumpBar(
  WidgetTester tester, {
  required double width,
  required double textScale,
  required String brandName,
  required Widget logo,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 800);
  addTearDown(tester.view.reset);
  final cubit = buildMarketCubit();
  addTearDown(cubit.close);
  await tester.pumpWidget(
    MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: BlocProvider<MarketCubit>.value(
        value: cubit,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: UiConfig.pageHorizontalPadding,
            ),
            child: SizedBox(
              height: UiConfig.headerCompactHeight,
              child: BrandCompactBarWidget(
                brandName: brandName,
                logo: logo,
                selector: MarketYearSelectorWidget(
                  years: const [2026, 2025],
                  year: 2026,
                  onYearSelected: (_) {},
                  tone: MarketSelectorTone.onLight,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  // Espera las tipografías empaquetadas: el primer cuadro usa la de respaldo.
  await tester.runAsync(GoogleFonts.pendingFonts);
  // El desborde del primer cuadro es de la tipografía de respaldo; no cuenta.
  tester.takeException();
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  for (final width in [360.0, 390.0]) {
    for (final name in ['BYD', 'Build Your Dreams Automotive Group']) {
      testWidgets(
        'logo de ancho extremo a $width dp y texto 1.3 ($name) no desborda',
        (tester) async {
          await _pumpBar(
            tester,
            width: width,
            textScale: 1.3,
            brandName: name,
            logo: Container(
              key: const ValueKey('wide-logo'),
              width: _extremeLogoWidth,
              height: UiConfig.headerCompactLogoSize,
              color: AppColors.photoPlaceholder,
            ),
          );
          // Un RenderFlex overflow llegaría como excepción de la prueba.
          expect(tester.takeException(), isNull);
          // El logo se dibuja escalado: se mide la caja que lo contiene.
          final logo = tester.getSize(
            find.ancestor(
              of: find.byKey(const ValueKey('wide-logo')),
              matching: find.byType(FittedBox),
            ),
          );
          expect(
            logo.width,
            lessThanOrEqualTo(UiConfig.headerCompactLogoMaxWidth),
          );
          expect(
            logo.height,
            lessThanOrEqualTo(UiConfig.headerCompactLogoMaxHeight),
          );
          // La píldora conserva su tamaño y queda dentro de la pantalla.
          final pill = tester.getRect(find.byType(MarketYearSelectorWidget));
          expect(pill.height, MarketConfig.selectorHeight);
          expect(
            pill.right,
            lessThanOrEqualTo(width - UiConfig.pageHorizontalPadding + 0.01),
          );
        },
      );
    }
  }

  testWidgets('la píldora mide lo mismo con un logo ancho que con uno normal', (
    tester,
  ) async {
    await _pumpBar(
      tester,
      width: 360,
      textScale: 1.3,
      brandName: 'BYD',
      logo: const SizedBox(width: 40, height: 40),
    );
    final normal = tester.getSize(find.byType(MarketYearSelectorWidget));
    await _pumpBar(
      tester,
      width: 360,
      textScale: 1.3,
      brandName: 'BYD',
      logo: const SizedBox(width: _extremeLogoWidth, height: 40),
    );
    expect(tester.getSize(find.byType(MarketYearSelectorWidget)), normal);
  });

  testWidgets('la barra real del encabezado de Marcas no desborda (BYD, 360)', (
    tester,
  ) async {
    final catalog = _MockCatalogCubit();
    whenListen(
      catalog,
      const Stream<CatalogState>.empty(),
      initialState: const CatalogLoading(),
    );
    final logos = _MockBrandLogosCubit();
    whenListen(
      logos,
      const Stream<BrandLogosState>.empty(),
      initialState: const BrandLogosInitial(),
    );
    when(() => logos.urlFor(any())).thenReturn(null);
    final market = buildMarketCubit();
    addTearDown(market.close);
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(360, 800);
    addTearDown(tester.view.reset);
    const delegate = BrandHeaderDelegate(
      year: 2026,
      availableYears: [2026, 2025],
      brandCount: 6,
      selectedIndex: 0,
      windowStart: 0,
      brandName: 'Build Your Dreams',
      isRefreshing: false,
      snapDuration: Duration.zero,
      onYearSelected: _noop,
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.3)),
          child: child!,
        ),
        home: MultiBlocProvider(
          providers: [
            BlocProvider<CatalogCubit>.value(value: catalog),
            BlocProvider<BrandLogosCubit>.value(value: logos),
            BlocProvider<MarketCubit>.value(value: market),
          ],
          child: Scaffold(
            body: Builder(
              builder: (context) => SizedBox(
                height: delegate.maxExtent,
                child: delegate.build(
                  context,
                  delegate.maxExtent - delegate.minExtent,
                  true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(BrandCompactBarWidget), findsOneWidget);
    // La barra compacta usa el selector para fondo blanco.
    expect(
      tester
          .widget<MarketYearSelectorWidget>(
            find.byType(MarketYearSelectorWidget),
          )
          .tone,
      MarketSelectorTone.onLight,
    );
  });
}

void _noop(int _) {}
