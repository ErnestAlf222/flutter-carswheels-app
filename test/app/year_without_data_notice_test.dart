import 'package:cars_wheels_app/app/market_catalog/year_without_data_notice.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

CatalogLoaded _loaded({int year = 2026, String? dropped}) => CatalogLoaded(
  year: year,
  brands: const [BrandEntity(name: 'Audi')],
  availableYears: const [2027, 2026],
  droppedBrand: dropped,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('cuándo hay aviso de año sin datos', () {
    test('solo con una marca perdida por el cambio de año', () {
      expect(isCatalogYearGap(_loaded(), _loaded(dropped: 'Bugatti')), isTrue);
      expect(isCatalogYearGap(_loaded(), _loaded()), isFalse);
      expect(isCatalogYearGap(const CatalogLoading(), _loaded()), isFalse);
    });

    test('el mismo aviso no se repite con cambios de otra cosa', () {
      final shown = _loaded(year: 2027, dropped: 'Bugatti');
      expect(isCatalogYearGap(shown, shown), isFalse);
    });
  });

  testWidgets('muestra marca y año reales, sin bloquear', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showYearWithoutDataNotice(
                ScaffoldMessenger.of(context),
                brand: 'Bugatti',
                year: 2027,
              ),
              child: const Text('año'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('año'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text(AppTexts.yearWithoutDataNotice('Bugatti', 2027)),
      findsOneWidget,
    );
    expect(find.text('Bugatti no tiene registros para 2027'), findsOneWidget);
    // El contenido de abajo sigue recibiendo toques.
    expect(find.text('año').hitTestable(), findsOneWidget);
  });
}
