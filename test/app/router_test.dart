import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/navigation/navigation.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';

import '../support/detail_test_support.dart';

class _MockLoad extends Mock implements LoadGroupDetailsUseCase {}

class _MockCatalogCubit extends MockCubit<CatalogState>
    implements CatalogCubit {}

class _MockModelsCubit extends MockCubit<ModelsState> implements ModelsCubit {}

class _MockBrandLogosCubit extends MockCubit<BrandLogosState>
    implements BrandLogosCubit {}

class _MockLogoPrecacheCubit extends MockCubit<LogoPrecacheState>
    implements LogoPrecacheCubit {}

/// Envuelve la app con los cubits que necesita la pantalla de inicio.
Widget _app(GoRouter router) {
  final load = _MockLoad();
  final gallery = MockResolveModelGalleryUseCase();
  when(
    () => gallery(
      brand: any(named: 'brand'),
      modelName: any(named: 'modelName'),
      year: any(named: 'year'),
    ),
  ).thenAnswer((_) async => const []);
  // Detalle nunca termina de cargar: se ve el esqueleto.
  when(() => load(any()))
      .thenAnswer((_) => Completer<GroupDetailsEntity>().future);
  final catalog = _MockCatalogCubit();
  final models = _MockModelsCubit();
  final logos = _MockBrandLogosCubit();
  final precache = _MockLogoPrecacheCubit();
  when(() => catalog.state).thenReturn(const CatalogInitial());
  when(() => models.state).thenReturn(const ModelsInitial());
  when(() => logos.state).thenReturn(const BrandLogosInitial());
  when(() => precache.state).thenReturn(const LogoPrecacheState());
  return MultiRepositoryProvider(
    providers: [
      RepositoryProvider<LoadGroupDetailsUseCase>.value(value: load),
      RepositoryProvider<ResolveModelGalleryUseCase>.value(value: gallery),
      RepositoryProvider<PhotoPrefetcher>.value(value: const PhotoPrefetcher()),
      RepositoryProvider<VehicleClassTranslator>.value(
        value: const VehicleClassTranslator(),
      ),
      RepositoryProvider<FuelTypeLabeler>.value(value: const FuelTypeLabeler()),
      RepositoryProvider<DriveLabeler>.value(value: const DriveLabeler()),
      RepositoryProvider<VersionDescriptorBuilder>.value(
        value: const VersionDescriptorBuilder(
          transmissionLabeler: TransmissionLabeler(),
        ),
      ),
    ],
    child: _blocs(router, catalog, models, logos, precache),
  );
}

Widget _blocs(
  GoRouter router,
  CatalogCubit catalog,
  ModelsCubit models,
  BrandLogosCubit logos,
  LogoPrecacheCubit precache,
) {
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
    registerFallbackValue(testArgs());
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

  group('pantalla Detalle', () {
    testWidgets('con DetailArgsEntity muestra Detalle y no el menú flotante', (
      tester,
    ) async {
      final router = buildAppRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _app(router),
        ),
      );
      await tester.pump();
      expect(find.byType(FloatingNavBar), findsOneWidget);
      unawaited(router.push<void>(RoutesConfig.detail, extra: testArgs()));
      await tester.pumpAndSettle();
      expect(find.byType(DetailPage), findsOneWidget);
      expect(find.text('TOYOTA · 2020'), findsOneWidget);
      // La ruta de flujo cubre el marco: el menú ya no está a la vista.
      expect(find.byType(FloatingNavBar).hitTestable(), findsNothing);
    });

    testWidgets('con un extra inválido redirige a inicio', (tester) async {
      final router = buildAppRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: _app(router),
        ),
      );
      await tester.pump();
      router.go(RoutesConfig.detail, extra: 'no soy argumentos');
      await tester.pumpAndSettle();
      expect(find.byType(DetailPage), findsNothing);
      expect(router.state.uri.path, RoutesConfig.home);
    });

    testWidgets('sin extra también redirige a inicio', (tester) async {
      final router = buildAppRouter();
      addTearDown(router.dispose);
      await tester.pumpWidget(_app(router));
      await tester.pump();
      router.go(RoutesConfig.detail);
      await tester.pumpAndSettle();
      expect(find.byType(DetailPage), findsNothing);
      expect(router.state.uri.path, RoutesConfig.home);
    });
  });
}
