import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/navigation/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

class _MockCatalogCubit extends MockCubit<CatalogState>
    implements CatalogCubit {}

class _MockModelsCubit extends MockCubit<ModelsState> implements ModelsCubit {}

class _MockBrandLogosCubit extends MockCubit<BrandLogosState>
    implements BrandLogosCubit {}

class _MockLogoPrecacheCubit extends MockCubit<LogoPrecacheState>
    implements LogoPrecacheCubit {}

/// Envuelve la app con los cubits que necesita la pantalla de inicio.
Widget _app(GoRouter router) {
  final catalog = _MockCatalogCubit();
  final models = _MockModelsCubit();
  final logos = _MockBrandLogosCubit();
  final precache = _MockLogoPrecacheCubit();
  when(() => catalog.state).thenReturn(const CatalogInitial());
  when(() => models.state).thenReturn(const ModelsInitial());
  when(() => logos.state).thenReturn(const BrandLogosInitial());
  when(() => precache.state).thenReturn(const LogoPrecacheState());
  return MultiBlocProvider(
    providers: [
      BlocProvider<CatalogCubit>.value(value: catalog),
      BlocProvider<ModelsCubit>.value(value: models),
      BlocProvider<BrandLogosCubit>.value(value: logos),
      BlocProvider<LogoPrecacheCubit>.value(value: precache),
      BlocProvider<SectionLoaderCubit>(create: (_) => SectionLoaderCubit()),
    ],
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
    await tester.pump();
    const expected = {
      RoutesConfig.search: AppTexts.searchPageTitle,
      RoutesConfig.compare: AppTexts.comparePageTitle,
      RoutesConfig.favorites: AppTexts.favoritesPageTitle,
      RoutesConfig.settings: AppTexts.settingsPageTitle,
    };
    for (final entry in expected.entries) {
      router.go(entry.key);
      await tester.pump();
      await tester.pump(
        const Duration(
          milliseconds: AnimationConfig.sectionLoaderVisibleMilliseconds,
        ),
      );
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
    await tester.pump();
    router.go(RoutesConfig.search);
    await tester.pump();
    await tester.pump(
      const Duration(
        milliseconds: AnimationConfig.sectionLoaderVisibleMilliseconds,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.searchPageTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  group('aviso al cambiar de sección', () {
    bool loaderVisible(WidgetTester tester) => find
        .descendant(
          of: find.byType(SectionLoaderOverlay),
          matching: find.byType(AppLoader),
        )
        .evaluate()
        .isNotEmpty;

    testWidgets('al arrancar la app no aparece', (tester) async {
      final router = buildAppRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router));
      await tester.pump();
      expect(find.byType(SectionLoaderOverlay), findsOneWidget);
      expect(loaderVisible(tester), isFalse);
    });

    testWidgets('al navegar aparece y luego desaparece', (tester) async {
      final router = buildAppRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router));
      await tester.pump();
      router.go(RoutesConfig.search);
      await tester.pump();
      await tester.pump();
      expect(loaderVisible(tester), isTrue);
      await tester.pump(
        const Duration(
          milliseconds: AnimationConfig.sectionLoaderVisibleMilliseconds,
        ),
      );
      await tester.pumpAndSettle();
      expect(loaderVisible(tester), isFalse);
    });

    testWidgets('la capa cubre el contenido y el menú sigue encima y tocable', (
      tester,
    ) async {
      final router = buildAppRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router));
      await tester.pump();
      router.go(RoutesConfig.search);
      await tester.pump();
      await tester.pump();
      final layer = find.descendant(
        of: find.byType(SectionLoaderOverlay),
        matching: find.byType(ColoredBox),
      );
      expect(tester.widget<ColoredBox>(layer).color, AppColors.background);
      expect(
        tester.getSize(layer),
        tester.getSize(find.byType(Scaffold).first),
      );
      final nav = find.byType(FloatingNavBar);
      expect(nav, findsOneWidget);
      await tester.tap(find.byIcon(Symbols.home));
      await tester.pump();
      await tester.pump();
      expect(router.state.uri.toString(), RoutesConfig.home);
    });
  });
}
