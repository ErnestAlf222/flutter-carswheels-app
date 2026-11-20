import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/market/market.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/detail_test_support.dart';
import '../../../support/mx_detail_test_support.dart';

class _MockLoad extends Mock implements LoadGroupDetailsUseCase {}

class _MockSafety extends Mock implements ResolveGroupSafetyUseCase {}

GroupDetailsEntity _mx(List<String> models, {int defaultIndex = 0}) =>
    GroupDetailsEntity(
      versions: [
        for (final model in models)
          testVersion(mxDetail(model), variantName: model, label: model),
      ],
      defaultIndex: defaultIndex,
    );

void main() {
  late _MockLoad load;
  late MockResolveModelGalleryUseCase gallery;
  late _MockSafety safety;

  setUpAll(() {
    disableFontFetching();
    registerFallbackValue(testArgs());
  });
  setUp(() {
    load = _MockLoad();
    gallery = MockResolveModelGalleryUseCase();
    safety = _MockSafety();
    when(
      () => gallery(
        brand: any(named: 'brand'),
        modelName: any(named: 'modelName'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async => const []);
  });

  Future<void> pumpPage(WidgetTester tester, Market market) async {
    final args = testArgs(market: market);
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('inicio')),
        GoRoute(
          path: RoutesConfig.detail,
          builder: (_, _) => DetailPage(
            args: args,
            onCompare: (context, _, _) => context.go(RoutesConfig.compare),
          ),
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
    await tester.pump(const Duration(seconds: 1));
  }

  group('Detalle de México', () {
    testWidgets('gasolina: cifras, filas, emisiones y atribución', (
      tester,
    ) async {
      when(() => load(any())).thenAnswer((_) async => _mx(['COROLLA']));
      await pumpPage(tester, Market.mexico);
      expect(find.byType(DetailMxFiguresCardWidget), findsOneWidget);
      expect(find.text(AppTexts.detailCityCaption), findsOneWidget);
      expect(find.text(AppTexts.detailCombinedCaption), findsOneWidget);
      expect(find.text('19.1'), findsOneWidget);
      expect(find.text(AppTexts.detailFuelRowLabel), findsOneWidget);
      expect(find.text('Gasolina'), findsOneWidget);
      expect(find.text('1,987 cm³ (2.0 L)'), findsOneWidget);
      expect(find.text('198 hp @ 6600 rpm'), findsOneWidget);
      expect(find.text('13.0:1'), findsOneWidget);
      expect(find.text(AppTexts.emissionsTitle), findsOneWidget);
      expect(find.text(AppTexts.conueeAttribution), findsOneWidget);
    });

    testWidgets('no muestra estrellas, recalls, puntajes ni clase, ni "—" de '
        'ellas', (tester) async {
      when(() => load(any())).thenAnswer((_) async => _mx(['COROLLA']));
      await pumpPage(tester, Market.mexico);
      expect(find.byType(SafetyStarsWidget), findsNothing);
      expect(find.text(AppTexts.detailSafetyCaption), findsNothing);
      expect(find.text(AppTexts.detailRecallsLabel), findsNothing);
      expect(find.text(AppTexts.fuelScoreLabel), findsNothing);
      expect(find.text(AppTexts.emissionsScoreLabel), findsNothing);
      expect(find.text(AppTexts.detailClassRowLabel), findsNothing);
      expect(find.text(AppTexts.detailDriveRowLabel), findsNothing);
      expect(find.text(AppTexts.detailAnnualCostCaption), findsNothing);
      // Con todos los datos presentes no sobra ningún guion.
      expect(find.text(AppTexts.noDataLabel), findsNothing);
    });

    testWidgets('no consulta la seguridad de NHTSA', (tester) async {
      when(() => load(any())).thenAnswer((_) async => _mx(['COROLLA']));
      await pumpPage(tester, Market.mexico);
      verifyZeroInteractions(safety);
    });

    testWidgets('eléctrico: potencia y torque, nunca km/l ni emisiones', (
      tester,
    ) async {
      when(() => load(any())).thenAnswer((_) async => _mx(['LYRIQ F']));
      await pumpPage(tester, Market.mexico);
      final card = find.byType(DetailFiguresCardWidget);
      expect(
        find.descendant(of: card, matching: find.text('503 hp')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: card, matching: find.text('710 N·m')),
        findsOneWidget,
      );
      expect(find.text(AppTexts.kmPerLiterUnit), findsNothing);
      expect(find.text(AppTexts.detailCityCaption), findsNothing);
      expect(find.text(AppTexts.detailCombinedCaption), findsNothing);
      expect(find.text(AppTexts.emissionsTitle), findsNothing);
      expect(find.text(AppTexts.conueeAttribution), findsOneWidget);
    });

    testWidgets('enchufable: sin km/l pero con emisiones', (tester) async {
      when(() => load(any()))
          .thenAnswer((_) async => _mx(['OUTLANDER PHEV SE PLUS']));
      await pumpPage(tester, Market.mexico);
      expect(find.text(AppTexts.detailCombinedCaption), findsNothing);
      expect(find.text('131 hp'), findsOneWidget);
      expect(find.text(AppTexts.emissionsTitle), findsOneWidget);
    });

    testWidgets('con menos de dos cifras la tarjeta de cifras se oculta', (
      tester,
    ) async {
      // El eléctrico de Hyundai trae "0@0": solo queda una cifra o ninguna.
      when(() => load(any()))
          .thenAnswer((_) async => _mx(['IONIQ 5 LIMITED TECH']));
      await pumpPage(tester, Market.mexico);
      expect(find.byType(DetailMxFiguresCardWidget), findsOneWidget);
      expect(find.byType(DetailFiguresCardWidget), findsNothing);
      expect(find.text(AppTexts.conueeAttribution), findsOneWidget);
    });

    testWidgets('la atribución no aparece mientras carga', (tester) async {
      when(() => load(any()))
          .thenAnswer((_) => Completer<GroupDetailsEntity>().future);
      await pumpPage(tester, Market.mexico);
      expect(find.text(AppTexts.conueeAttribution), findsNothing);
    });

    testWidgets('la barra inferior sigue con corazón y comparar', (
      tester,
    ) async {
      when(() => load(any())).thenAnswer((_) async => _mx(['COROLLA']));
      await pumpPage(tester, Market.mexico);
      expect(find.byType(DetailBottomBarWidget), findsOneWidget);
      expect(find.text(AppTexts.compareWithOtherLabel), findsOneWidget);
    });

    testWidgets('el botón de versión usa la etiqueta y abre la hoja', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 1200);
      addTearDown(tester.view.reset);
      when(() => load(any()))
          .thenAnswer((_) async => _mx(['COROLLA', 'COROLLA HIBRIDO']));
      await pumpPage(tester, Market.mexico);
      expect(find.text('Versión (2 disponibles)'), findsOneWidget);
      await tester.tap(find.text('Versión (2 disponibles)'));
      await tester.pumpAndSettle();
      expect(find.text('COROLLA HIBRIDO'), findsOneWidget);
      // km/l combinado a la derecha de cada versión.
      expect(find.text('31.3'), findsOneWidget);
      await tester.tap(find.text('COROLLA HIBRIDO'));
      await tester.pumpAndSettle();
      expect(find.text('31.3'), findsWidgets);
    });
  });

  group('Detalle de EE. UU. no cambia', () {
    setUp(() {
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
    });

    testWidgets('sigue con seguridad, recalls, clase y sin atribución', (
      tester,
    ) async {
      when(() => load(any())).thenAnswer(
        (_) async => GroupDetailsEntity(
          versions: [testVersion(testDetail())],
          defaultIndex: 0,
        ),
      );
      await pumpPage(tester, Market.unitedStates);
      expect(find.text(AppTexts.detailSafetyCaption), findsOneWidget);
      expect(find.text(AppTexts.detailRecallsLabel), findsOneWidget);
      expect(find.text(AppTexts.detailClassRowLabel), findsOneWidget);
      expect(find.text(AppTexts.conueeAttribution), findsNothing);
      verify(
        () => safety.resolveSafety(
          year: any(named: 'year'),
          make: any(named: 'make'),
          model: any(named: 'model'),
        ),
      ).called(1);
    });
  });
}
