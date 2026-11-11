import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('cada ruta muestra el título de su pantalla', (tester) async {
    final router = buildAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    const expected = {
      RoutesConfig.home: AppTexts.homePageTitle,
      RoutesConfig.search: AppTexts.searchPageTitle,
      RoutesConfig.compare: AppTexts.comparePageTitle,
      RoutesConfig.favorites: AppTexts.favoritesPageTitle,
      RoutesConfig.settings: AppTexts.settingsPageTitle,
    };
    for (final entry in expected.entries) {
      router.go(entry.key);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
    }
  });

  testWidgets('con animaciones activas la transición no lanza errores', (
    tester,
  ) async {
    final router = buildAppRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    router.go(RoutesConfig.search);
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.searchPageTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
