import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogCubit extends MockCubit<CatalogState>
    implements CatalogCubit {}

/// Envuelve la app con un CatalogCubit en estado inicial.
Widget _app(GoRouter router) {
  final cubit = _MockCatalogCubit();
  when(() => cubit.state).thenReturn(const CatalogInitial());
  return BlocProvider<CatalogCubit>.value(
    value: cubit,
    child: MaterialApp.router(routerConfig: router),
  );
}

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
        child: _app(router),
      ),
    );
    await tester.pumpAndSettle();
    const expected = {
      RoutesConfig.home: AppTexts.brandsSectionTitle,
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
    await tester.pumpWidget(_app(router));
    await tester.pumpAndSettle();
    router.go(RoutesConfig.search);
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.searchPageTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
