import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/favorites.dart';
import 'package:cars_wheels_app/features/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../support/favorites_test_support.dart';

const double _topInset = 44.0;
const Color _contentColor = Color(0xFFFF0000);

Widget _host(Widget home, {required GlobalKey boundary}) => RepaintBoundary(
  key: boundary,
  child: MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(padding: const EdgeInsets.only(top: _topInset)),
      child: child!,
    ),
    home: home,
  ),
);

// Color del píxel (x, y) ya pintado, en coordenadas lógicas.
Future<Color> _pixel(GlobalKey boundary, double x, double y) async {
  final render =
      boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await render.toImage();
  final data = (await image.toByteData())!;
  final index = (y.toInt() * image.width + x.toInt()) * 4;
  return Color.fromARGB(
    data.getUint8(index + 3),
    data.getUint8(index),
    data.getUint8(index + 1),
    data.getUint8(index + 2),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('la banda mide el área segura y es tinta con íconos claros', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      _host(
        const Scaffold(
          body: CustomScrollView(
            slivers: [
              StatusBarBandSliver(),
              SliverToBoxAdapter(child: SizedBox(height: 2000)),
            ],
          ),
        ),
        boundary: key,
      ),
    );
    final band = find.descendant(
      of: find.byType(StatusBarBandSliver),
      matching: find.byType(ColoredBox),
    );
    expect(tester.getSize(band).height, _topInset);
    expect(tester.widget<ColoredBox>(band).color, AppColors.ink);
    final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.descendant(
        of: find.byType(StatusBarBandSliver),
        matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
      ),
    );
    expect(region.value.statusBarIconBrightness, Brightness.light);
    expect(region.value.statusBarBrightness, Brightness.dark);
  });

  testWidgets(
    'tras desplazar, la banda sigue y el contenido no se pinta en ella',
    (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        _host(
          Scaffold(
            body: CustomScrollView(
              slivers: [
                const StatusBarBandSliver(),
                SliverList.builder(
                  itemCount: 40,
                  itemBuilder: (context, index) => const SizedBox(
                    height: 80,
                    child: ColoredBox(color: _contentColor),
                  ),
                ),
              ],
            ),
          ),
          boundary: key,
        ),
      );
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();
      final band = find.descendant(
        of: find.byType(StatusBarBandSliver),
        matching: find.byType(ColoredBox),
      );
      expect(band, findsOneWidget);
      expect(tester.getTopLeft(band).dy, 0);
      expect(tester.getSize(band).height, _topInset);
      await tester.runAsync(() async {
        // Con el contenido rojo debajo, la zona de la barra de estado sigue tinta.
        for (final y in [2.0, 20.0, _topInset - 2]) {
          expect(
            (await _pixel(key, 100, y)).toARGB32(),
            AppColors.ink.toARGB32(),
          );
        }
        // Justo debajo de la banda sí se ve el contenido.
        expect(
          (await _pixel(key, 100, _topInset + 10)).toARGB32(),
          _contentColor.toARGB32(),
        );
      });
    },
  );

  for (final (name, page) in [
    (
      'Favoritos',
      BlocProvider<FavoritesCubit>(
        create: (_) => buildFavoritesCubit(),
        child: FavoritesPage(
          selectorBuilder: (_) => const SizedBox.shrink(),
          gridBuilder: (_, _, _, _) =>
              const SliverToBoxAdapter(child: SizedBox.shrink()),
          onOpen: (_, _) {},
          onExplore: (_) {},
        ),
      ),
    ),
    ('Ajustes', const SettingsPage()),
  ]) {
    testWidgets(
      '$name: banda fija y contenido desplazado sin pintar bajo ella',
      (tester) async {
        final key = GlobalKey();
        await tester.pumpWidget(_host(page, boundary: key));
        expect(find.byType(StatusBarBandSliver), findsOneWidget);
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        final band = find.descendant(
          of: find.byType(StatusBarBandSliver),
          matching: find.byType(ColoredBox),
        );
        expect(tester.getTopLeft(band).dy, 0);
        expect(tester.getSize(band).height, _topInset);
        await tester.runAsync(() async {
          // Las tarjetas desplazadas (blancas) no tiñen la zona de la banda.
          expect(
            (await _pixel(key, 100, _topInset / 2)).toARGB32(),
            AppColors.ink.toARGB32(),
          );
        });
      },
    );
  }
}
