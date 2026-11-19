import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/detail_test_support.dart';

class _MockLoad extends Mock implements LoadGroupDetailsUseCase {}

class _MockSafety extends Mock implements ResolveGroupSafetyUseCase {}

GroupDetailsEntity _details({int count = 2, int defaultIndex = 0}) =>
    GroupDetailsEntity(
      versions: [
        testVersion(
          testDetail(id: 1, combinedKmPerLiter: 14.62, annualFuelCostUsd: 1750),
        ),
        if (count > 1)
          testVersion(
            testDetail(
              id: 2,
              transmission: 'Manual 6-spd',
              combinedKmPerLiter: 12.3,
              annualFuelCostUsd: 2100,
              fuelType: 'Premium',
              drive: 'All-Wheel Drive',
            ),
            variantName: 'Corolla LE',
          ),
      ],
      defaultIndex: defaultIndex,
    );

// La foto cargando pulsa sin fin: se avanza un tiempo fijo en vez de esperar.
const Duration _settle = Duration(seconds: 1);

void main() {
  late _MockLoad load;
  late MockResolveModelGalleryUseCase gallery;
  late _MockSafety safety;
  late GoRouter router;

  setUpAll(() {
    disableFontFetching();
    registerFallbackValue(testArgs());
  });
  setUp(() {
    load = _MockLoad();
    gallery = MockResolveModelGalleryUseCase();
    safety = _MockSafety();
    when(
      () => safety.resolveSafety(
        year: any(named: 'year'),
        make: any(named: 'make'),
        model: any(named: 'model'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => safety.resolveRecalls(
        year: any(named: 'year'),
        make: any(named: 'make'),
        model: any(named: 'model'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => gallery(
        brand: any(named: 'brand'),
        modelName: any(named: 'modelName'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async => const []);
  });

  Future<void> pumpPage(
    WidgetTester tester, {
    PhotoEntity? photo,
    bool withPhoto = true,
    bool disableAnimations = true,
  }) async {
    final args = testArgs(photo: withPhoto ? (photo ?? testPhoto()) : null);
    router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('inicio')),
        GoRoute(
          path: RoutesConfig.detail,
          builder: (_, _) => DetailPage(args: args),
        ),
        GoRoute(
          path: RoutesConfig.compare,
          builder: (_, _) => const Text('pantalla comparar'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<LoadGroupDetailsUseCase>.value(value: load),
          RepositoryProvider<ResolveModelGalleryUseCase>.value(value: gallery),
          RepositoryProvider<ResolveGroupSafetyUseCase>.value(value: safety),
          RepositoryProvider<PhotoPrefetcher>.value(
            value: const PhotoPrefetcher(),
          ),
          RepositoryProvider<VehicleClassTranslator>.value(
            value: const VehicleClassTranslator(),
          ),
          RepositoryProvider<FuelTypeLabeler>.value(
            value: const FuelTypeLabeler(),
          ),
          RepositoryProvider<DriveLabeler>.value(value: const DriveLabeler()),
          RepositoryProvider<VersionDescriptorBuilder>.value(
            value: const VersionDescriptorBuilder(
              transmissionLabeler: TransmissionLabeler(),
            ),
          ),
        ],
        child: BlocProvider<BrandLogosCubit>.value(
          value: buildMockBrandLogosCubit(),
          child: MaterialApp.router(
            routerConfig: router,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(disableAnimations: disableAnimations),
              child: child!,
            ),
          ),
        ),
      ),
    );
    unawaited(router.push<void>(RoutesConfig.detail));
    await tester.pump();
    await tester.pump();
  }

  testWidgets('cargando muestra el encabezado, el título y el esqueleto, '
      'nunca el AppLoader', (tester) async {
    final pending = Completer<GroupDetailsEntity>();
    when(() => load(any())).thenAnswer((_) => pending.future);
    await pumpPage(tester);
    expect(find.byType(DetailPhotoCarouselWidget), findsOneWidget);
    expect(find.text('TOYOTA · 2020'), findsOneWidget);
    expect(find.byType(DetailSkeletonWidget), findsOneWidget);
    expect(find.byType(AppLoader), findsNothing);
    // Sin cápsula de clase hasta que haya datos.
    expect(find.text('Compacto'), findsNothing);
    verify(() => load(any())).called(1);
  });

  testWidgets('la foto va a todo el ancho con el alto de config y el botón '
      'de volver', (tester) async {
    when(() => load(any())).thenAnswer((_) async => _details());
    await pumpPage(tester);
    await tester.pumpAndSettle();
    final photo = tester.getRect(find.byType(DetailPhotoCarouselWidget));
    final screen = tester.getRect(find.byType(DetailPage));
    expect(photo.left, screen.left);
    expect(photo.width, screen.width);
    expect(photo.height, UiConfig.detailPhotoHeight);
    expect(find.bySemanticsLabel(AppTexts.backLabel), findsOneWidget);
    // Panel claro que se superpone a la foto, con esquinas superiores.
    final panels = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .where(
          (box) =>
              (box.decoration as BoxDecoration).color == AppColors.background &&
              (box.decoration as BoxDecoration).borderRadius ==
                  const BorderRadius.vertical(
                    top: Radius.circular(HeaderConfig.detailPanelOverlap),
                  ),
        );
    expect(panels, hasLength(1));
    // La acción principal es el botón amarillo.
    expect(find.byType(AccentButton), findsOneWidget);
  });

  testWidgets('al hacer scroll queda una barra fija con volver y el nombre', (
    tester,
  ) async {
    // Pantalla baja para que el contenido sí alcance a contraer la foto.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 500);
    addTearDown(tester.view.reset);
    when(() => load(any())).thenAnswer((_) async => _details());
    await pumpPage(tester);
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -700));
    await tester.pumpAndSettle();
    final back = tester.getRect(find.byIcon(Symbols.chevron_left));
    expect(back.top, greaterThanOrEqualTo(0));
    expect(find.bySemanticsLabel(AppTexts.backLabel), findsOneWidget);
    final titles = tester.widgetList<Opacity>(
      find.ancestor(
        of: find.text('Corolla').first,
        matching: find.byType(Opacity),
      ),
    );
    expect(titles.any((opacity) => opacity.opacity == 1.0), isTrue);
  });

  testWidgets('cargado muestra cápsula, versión, cifras y filas', (
    tester,
  ) async {
    when(() => load(any())).thenAnswer((_) async => _details());
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.byType(DetailSkeletonWidget), findsNothing);
    expect(find.text('Versión (2 disponibles)'), findsOneWidget);
    expect(find.text('Automática CVT 10 vel. · 4 cil · 2.0 L'), findsOneWidget);
    expect(find.text('14.6'), findsOneWidget);
    expect(find.text(r'$1,750'), findsOneWidget);
    // La clase aparece en la cápsula y en su fila.
    expect(find.text('Compacto'), findsNWidgets(2));
    expect(find.text('Gasolina regular'), findsOneWidget);
    expect(find.text('Tracción delantera'), findsOneWidget);
    expect(find.byType(DetailBottomBarWidget), findsOneWidget);
    expect(find.byType(FloatingNavBar), findsNothing);
  });

  testWidgets('la seguridad carga aparte: el contenido no se reemplaza', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    final pendingRecalls = Completer<RecallSummaryEntity?>();
    when(() => load(any())).thenAnswer((_) async => _details());
    when(
      () => safety.resolveSafety(
        year: any(named: 'year'),
        make: any(named: 'make'),
        model: any(named: 'model'),
      ),
    ).thenAnswer(
      (_) async =>
          const GroupSafetyEntity(ratedCount: 2, minOverall: 4, maxOverall: 5),
    );
    when(
      () => safety.resolveRecalls(
        year: any(named: 'year'),
        make: any(named: 'make'),
        model: any(named: 'model'),
      ),
    ).thenAnswer((_) => pendingRecalls.future);
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.text('4–5'), findsOneWidget);
    expect(find.text('14.6'), findsOneWidget);
    expect(find.byType(DetailSkeletonWidget), findsNothing);
    // Los recalls siguen en camino: solo su fila muestra el esqueleto.
    expect(find.byType(SkeletonBarWidget), findsOneWidget);
    pendingRecalls.complete(
      const RecallSummaryEntity(
        recalls: [RecallEntity(campaignNumber: 'A', component: 'Airbag')],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 aviso'), findsOneWidget);
    expect(find.text('14.6'), findsOneWidget);
    await tester.tap(find.text('1 aviso'));
    await tester.pumpAndSettle();
    expect(find.byType(RecallsSheetWidget), findsOneWidget);
    expect(find.text('Airbag'), findsOneWidget);
  });

  testWidgets('con una sola versión el selector no responde', (tester) async {
    when(() => load(any())).thenAnswer((_) async => _details(count: 1));
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.byIcon(Symbols.expand_more), findsNothing);
    await tester.tap(find.byType(VersionSelectorButtonWidget));
    await tester.pumpAndSettle();
    expect(find.byType(VersionSheetWidget), findsNothing);
  });

  testWidgets('elegir otra versión desde la hoja actualiza sin AppLoader', (
    tester,
  ) async {
    when(() => load(any())).thenAnswer((_) async => _details());
    await pumpPage(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(VersionSelectorButtonWidget));
    await tester.pumpAndSettle();
    expect(find.byType(VersionSheetWidget), findsOneWidget);
    await tester.tap(find.text('Corolla LE'));
    await tester.pump();
    expect(find.byType(AppLoader), findsNothing);
    await tester.pumpAndSettle();
    expect(find.byType(VersionSheetWidget), findsNothing);
    expect(find.text('12.3'), findsOneWidget);
    expect(find.text('14.6'), findsNothing);
    expect(find.text(r'$2,100'), findsOneWidget);
    expect(find.text('Gasolina premium'), findsOneWidget);
    expect(find.text('Tracción integral'), findsOneWidget);
    expect(find.text('Manual 6 vel. · 4 cil · 2.0 L'), findsOneWidget);
    // Los datos se cargaron una sola vez.
    verify(() => load(any())).called(1);
  });

  GroupDetailsEntity efficiencyDetails() => GroupDetailsEntity(
    versions: [
      testVersion(
        testDetail(
          id: 1,
          cityKmPerLiter: 13.1,
          co2GramsPerKilometer: 160,
          fuelScore: 8,
        ),
      ),
      testVersion(
        testDetail(
          id: 2,
          powertrain: Powertrain.electric,
          combinedKmPerLiter: null,
          totalRangeKilometers: 531,
          co2GramsPerKilometer: 0,
        ),
        variantName: 'Corolla EV',
      ),
    ],
    defaultIndex: 0,
  );

  testWidgets('la tarjeta de consumo queda entre las filas y los recalls', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    when(() => load(any())).thenAnswer((_) async => efficiencyDetails());
    await pumpPage(tester);
    await tester.pumpAndSettle();
    final driveY = tester
        .getTopLeft(find.text(AppTexts.detailDriveRowLabel))
        .dy;
    final cardY = tester.getTopLeft(find.text(AppTexts.efficiencyTitle)).dy;
    final recallsY = tester
        .getTopLeft(find.text(AppTexts.detailRecallsLabel))
        .dy;
    expect(driveY, lessThan(cardY));
    expect(cardY, lessThan(recallsY));
    expect(find.text('13.1 km/l'), findsOneWidget);
  });

  testWidgets('cambiar de versión actualiza la tarjeta sin AppLoader', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    when(() => load(any())).thenAnswer((_) async => efficiencyDetails());
    await pumpPage(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(VersionSelectorButtonWidget));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Corolla EV'));
    await tester.pump();
    expect(find.byType(AppLoader), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('531 km'), findsOneWidget);
    expect(find.text('0 g/km'), findsOneWidget);
    expect(find.text('13.1 km/l'), findsNothing);
    expect(find.byType(DetailEfficiencyCardWidget), findsOneWidget);
  });

  testWidgets('sin versiones muestra el estado vacío', (tester) async {
    when(() => load(any())).thenAnswer(
      (_) async => const GroupDetailsEntity(versions: [], defaultIndex: 0),
    );
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.byType(DetailPhotoCarouselWidget), findsOneWidget);
    // Título del cuerpo y nombre de la barra compacta (transparente al inicio).
    expect(find.text('Corolla'), findsNWidgets(2));
    expect(find.byType(EmptyStateWidget), findsOneWidget);
  });

  testWidgets('el error ofrece reintentar y vuelve a cargar', (tester) async {
    // El encabezado es más alto: la pantalla de prueba crece para que el botón no quede tras la barra.
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.reset);
    final calls = <int>[];
    when(() => load(any())).thenAnswer((_) async {
      calls.add(1);
      if (calls.length == 1) throw const NetworkFailure('sin red');
      return _details();
    });
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.byType(ErrorStateWidget), findsOneWidget);
    expect(find.byType(DetailPhotoCarouselWidget), findsOneWidget);
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    await tester.pumpAndSettle();
    expect(calls, hasLength(2));
    expect(find.byType(ErrorStateWidget), findsNothing);
    expect(find.text('14.6'), findsOneWidget);
  });

  testWidgets('las secciones entran escalonadas solo en la primera carga', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.reset);
    when(() => load(any())).thenAnswer((_) async => _details());
    await pumpPage(tester, disableAnimations: false);
    await tester.pump(_settle);
    final entries = tester.widgetList<FadeInUp>(find.byType(FadeInUp)).toList();
    final delays = entries.map((entry) => entry.delay.inMilliseconds).toSet();
    // Título, versión, cifras y filas con el paso de config.
    expect(
      delays,
      containsAll([
        0,
        UiConfig.detailEntryStepMilliseconds,
        2 * UiConfig.detailEntryStepMilliseconds,
        3 * UiConfig.detailEntryStepMilliseconds,
      ]),
    );
    final before = [
      for (final element in find.byType(FadeInUp).evaluate())
        (element as StatefulElement).state,
    ];
    await tester.tap(find.byType(VersionSelectorButtonWidget));
    await tester.pump(_settle);
    await tester.tap(find.text('Corolla LE'));
    await tester.pump(_settle);
    final after = [
      for (final element in find.byType(FadeInUp).evaluate())
        (element as StatefulElement).state,
    ];
    // Al cambiar de versión las mismas entradas siguen montadas: no se repiten.
    expect(after, before);
    expect(find.text('12.3'), findsOneWidget);
    expect(find.byType(AppLoader), findsNothing);
  });

  testWidgets('con disableAnimations las secciones aparecen sin entrada', (
    tester,
  ) async {
    when(() => load(any())).thenAnswer((_) async => _details());
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.byType(FadeInUp), findsNothing);
    expect(find.text('14.6'), findsOneWidget);
  });

  testWidgets('Comparar con otro navega a la ruta de comparar', (tester) async {
    when(() => load(any())).thenAnswer((_) async => _details());
    await pumpPage(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppTexts.compareWithOtherLabel));
    await tester.pumpAndSettle();
    expect(find.text('pantalla comparar'), findsOneWidget);
    expect(router.state.uri.path, RoutesConfig.compare);
  });

  testWidgets('hay un solo corazón: el de la barra inferior', (tester) async {
    when(() => load(any())).thenAnswer((_) async => _details());
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.byIcon(Symbols.favorite), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(DetailBottomBarWidget),
        matching: find.byIcon(Symbols.favorite),
      ),
      findsOneWidget,
    );
  });

  testWidgets('la foto de args se muestra de inmediato, sin AppLoader', (
    tester,
  ) async {
    final pending = Completer<List<PhotoEntity>>();
    when(() => load(any())).thenAnswer((_) async => _details());
    when(
      () => gallery(
        brand: any(named: 'brand'),
        modelName: any(named: 'modelName'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) => pending.future);
    await pumpPage(tester);
    final urls = tester
        .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
        .map((image) => image.imageUrl);
    expect(urls, contains(testPhoto().thumbnailUrl));
    expect(find.byType(AppLoader), findsNothing);
    expect(find.text('Foto: Autora · CC BY 4.0'), findsOneWidget);
  });

  testWidgets('con args.photo nula la foto aparece cuando llega la galería', (
    tester,
  ) async {
    final pending = Completer<List<PhotoEntity>>();
    when(() => load(any())).thenAnswer((_) async => _details());
    when(
      () => gallery(
        brand: any(named: 'brand'),
        modelName: any(named: 'modelName'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) => pending.future);
    await pumpPage(tester, withPhoto: false);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byType(AppLoader), findsNothing);
    pending.complete([testPhoto(author: 'Galería')]);
    await tester.pump();
    await tester.pump();
    expect(find.byType(CachedNetworkImage), findsWidgets);
    expect(find.text('Foto: Galería · CC BY 4.0'), findsOneWidget);
    expect(find.byType(AppLoader), findsNothing);
  });
}
