import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class _MockBrandLogosCubit extends MockCubit<BrandLogosState>
    implements BrandLogosCubit {}

// Una fila de fichas donde solo la marca [selected] está activa.
Widget _row({
  required BrandLogosCubit logos,
  required String selected,
  double textScale = 1.0,
  double width = 360,
  bool reduceMotion = false,
}) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      size: Size(width, 800),
      textScaler: TextScaler.linear(textScale),
      disableAnimations: reduceMotion,
    ),
    child: child!,
  ),
  home: BlocProvider<BrandLogosCubit>.value(
    value: logos,
    child: Scaffold(
      body: SizedBox(
        width: width,
        child: Row(
          children: [
            for (final name in const ['Audi', 'Bmw', 'Kia'])
              Expanded(
                child: BrandTileWidget(
                  brandName: name,
                  selected: name == selected,
                  onTap: () {},
                ),
              ),
          ],
        ),
      ),
    ),
  ),
);

double _scaleOf(WidgetTester tester, String name) => tester
    .widget<AnimatedScale>(
      find.descendant(
        of: find.ancestor(
          of: find.text(name),
          matching: find.byType(BrandTileWidget),
        ),
        matching: find.byType(AnimatedScale),
      ),
    )
    .scale;

void main() {
  late _MockBrandLogosCubit logos;

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  setUp(() {
    logos = _MockBrandLogosCubit();
    when(() => logos.state).thenReturn(const BrandLogosInitial());
    when(() => logos.urlFor(any())).thenReturn(null);
  });

  testWidgets('solo la marca activa está escalada', (tester) async {
    await tester.pumpWidget(_row(logos: logos, selected: 'Bmw'));
    await tester.pumpAndSettle();
    expect(_scaleOf(tester, 'Bmw'), CarouselConfig.selectedScale);
    expect(_scaleOf(tester, 'Audi'), 1.0);
    expect(_scaleOf(tester, 'Kia'), 1.0);
  });

  testWidgets('la anterior se restablece al cambiar de marca', (tester) async {
    await tester.pumpWidget(_row(logos: logos, selected: 'Audi'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_row(logos: logos, selected: 'Kia'));
    await tester.pumpAndSettle();
    expect(_scaleOf(tester, 'Audi'), 1.0);
    expect(_scaleOf(tester, 'Kia'), CarouselConfig.selectedScale);
    final transform = tester.widget<Transform>(
      find
          .descendant(
            of: find.ancestor(
              of: find.text('Kia'),
              matching: find.byType(BrandTileWidget),
            ),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(transform.transform.storage[0], closeTo(1.1, 0.001));
  });

  testWidgets('no cambia el espacio que ocupa la ficha', (tester) async {
    await tester.pumpWidget(_row(logos: logos, selected: 'Audi'));
    await tester.pumpAndSettle();
    final before = tester.getSize(find.byType(BrandTileWidget).at(1));
    await tester.pumpWidget(_row(logos: logos, selected: 'Bmw'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(BrandTileWidget).at(1)), before);
  });

  testWidgets('con movimiento reducido el cambio es inmediato', (tester) async {
    await tester.pumpWidget(
      _row(logos: logos, selected: 'Audi', reduceMotion: true),
    );
    await tester.pumpWidget(
      _row(logos: logos, selected: 'Kia', reduceMotion: true),
    );
    await tester.pump();
    expect(_scaleOf(tester, 'Kia'), CarouselConfig.selectedScale);
    final transform = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(BrandTileWidget).at(2),
            matching: find.byType(Transform),
          )
          .first,
    );
    expect(transform.transform.storage[0], closeTo(1.1, 0.001));
  });

  testWidgets('sin desbordes a 360 dp y texto 1.3', (tester) async {
    await tester.pumpWidget(
      _row(logos: logos, selected: 'Bmw', textScale: 1.3),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
