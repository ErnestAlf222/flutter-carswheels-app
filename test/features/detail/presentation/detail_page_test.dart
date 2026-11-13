import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
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

void main() {
  late _MockLoad load;
  late MockResolveModelGalleryUseCase gallery;
  late GoRouter router;

  setUpAll(() {
    disableFontFetching();
    registerFallbackValue(testArgs());
  });
  setUp(() {
    load = _MockLoad();
    gallery = MockResolveModelGalleryUseCase();
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
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
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
    expect(find.byType(DetailHeroHeaderWidget), findsOneWidget);
    expect(find.text('TOYOTA · 2020'), findsOneWidget);
    expect(find.byType(DetailSkeletonWidget), findsOneWidget);
    expect(find.byType(AppLoader), findsNothing);
    // Sin cápsula de clase hasta que haya datos.
    expect(find.text('Compacto'), findsNothing);
    verify(() => load(any())).called(1);
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

  testWidgets('sin versiones muestra el estado vacío', (tester) async {
    when(() => load(any())).thenAnswer(
      (_) async => const GroupDetailsEntity(versions: [], defaultIndex: 0),
    );
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.byType(DetailHeroHeaderWidget), findsOneWidget);
    expect(find.text('Corolla'), findsOneWidget);
    expect(find.byType(EmptyStateWidget), findsOneWidget);
  });

  testWidgets('el error ofrece reintentar y vuelve a cargar', (tester) async {
    final calls = <int>[];
    when(() => load(any())).thenAnswer((_) async {
      calls.add(1);
      if (calls.length == 1) throw const NetworkFailure('sin red');
      return _details();
    });
    await pumpPage(tester);
    await tester.pumpAndSettle();
    expect(find.byType(ErrorStateWidget), findsOneWidget);
    expect(find.byType(DetailHeroHeaderWidget), findsOneWidget);
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    await tester.pumpAndSettle();
    expect(calls, hasLength(2));
    expect(find.byType(ErrorStateWidget), findsNothing);
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
