import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
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

class _MockLoad extends Mock implements LoadGroupDetailsUseCase {}

class _MockSafety extends Mock implements ResolveGroupSafetyUseCase {}

class _NeverProbe implements ConnectionProbe {
  @override
  Future<bool> isReachable() async => true;
}

GroupDetailsEntity _details() => GroupDetailsEntity(
  versions: [testVersion(testDetail(id: 1, combinedKmPerLiter: 14.6))],
  defaultIndex: 0,
);

void main() {
  late _MockLoad load;
  late _MockSafety safety;
  late MockResolveModelGalleryUseCase gallery;
  late NetworkSignals signals;
  late ConnectivityCubit connectivity;
  late int safetyCalls;

  setUpAll(() {
    disableFontFetching();
    registerFallbackValue(testArgs());
  });

  setUp(() {
    load = _MockLoad();
    safety = _MockSafety();
    gallery = MockResolveModelGalleryUseCase();
    safetyCalls = 0;
    when(
      () => gallery(
        brand: any(named: 'brand'),
        modelName: any(named: 'modelName'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async => const []);
  });

  // Seguridad: sin red falla; con red responde "sin datos".
  void stubSafety({required bool Function() offline}) {
    when(
      () => safety.resolveSafety(
        year: any(named: 'year'),
        make: any(named: 'make'),
        model: any(named: 'model'),
      ),
    ).thenAnswer((_) async {
      safetyCalls++;
      if (offline()) throw const NetworkFailure('sin red');
      return null;
    });
    when(
      () => safety.resolveRecalls(
        year: any(named: 'year'),
        make: any(named: 'make'),
        model: any(named: 'model'),
      ),
    ).thenAnswer((_) async {
      if (offline()) throw const NetworkFailure('sin red');
      return null;
    });
  }

  Future<void> pumpDetail(WidgetTester tester, {PhotoEntity? photo}) async {
    signals = NetworkSignals();
    connectivity = ConnectivityCubit(
      signals: signals,
      probe: _NeverProbe(),
      judge: ConnectionJudge(slowFailuresToGoOffline: 2),
      backoff: const ReconnectBackoff(
        initialDelay: Duration(hours: 1),
        maxDelay: Duration(hours: 1),
        factor: 1,
      ),
      restoredNoticeDuration: const Duration(seconds: 2),
    );
    final args = testArgs(photo: photo ?? testPhoto());
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('inicio')),
        GoRoute(
          path: RoutesConfig.detail,
          builder: (_, _) =>
              DetailPage(args: args, onCompare: (context, args, versionKey) {}),
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
        child: MultiBlocProvider(
          providers: [
            BlocProvider<BrandLogosCubit>.value(
              value: buildMockBrandLogosCubit(),
            ),
            BlocProvider<ConnectivityCubit>.value(value: connectivity),
          ],
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

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    unawaited(connectivity.close());
    unawaited(signals.close());
    await tester.pump();
  }

  testWidgets('abre con lo guardado y avisa qué no está disponible sin red', (
    tester,
  ) async {
    when(() => load(any())).thenAnswer((_) async => _details());
    stubSafety(offline: () => true);
    await pumpDetail(tester);
    signals.report(NetworkSignal.unreachable);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    // Versiones guardadas: se ve el contenido, no un error.
    expect(find.byType(VersionSelectorButtonWidget), findsOneWidget);
    expect(find.text(AppTexts.errorStateTitle), findsNothing);
    expect(find.text(AppTexts.offlineBandLabel), findsOneWidget);
    expect(find.text(AppTexts.offlineDetailNotice), findsOneWidget);
    await finish(tester);
  });

  testWidgets(
    'sin versiones guardadas dice que falta la conexión, sin errores crudos',
    (tester) async {
      when(() => load(any()))
          .thenAnswer((_) async => throw const NetworkFailure('sin red'));
      stubSafety(offline: () => true);
      await pumpDetail(tester);
      signals.report(NetworkSignal.unreachable);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(AppTexts.offlineStateTitle), findsOneWidget);
      expect(find.text(AppTexts.errorStateTitle), findsNothing);
      expect(find.text(AppTexts.retryButtonLabel), findsOneWidget);
      expect(find.textContaining('NetworkFailure'), findsNothing);
      await finish(tester);
    },
  );

  testWidgets('al volver la conexión se completa solo, una vez y sin loader', (
    tester,
  ) async {
    bool offline = true;
    int loads = 0;
    when(() => load(any())).thenAnswer((_) async {
      loads++;
      if (offline) throw const NetworkFailure('sin red');
      return _details();
    });
    stubSafety(offline: () => offline);
    await pumpDetail(tester);
    signals.report(NetworkSignal.unreachable);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(loads, 1);
    expect(find.text(AppTexts.offlineStateTitle), findsOneWidget);

    offline = false;
    signals.report(NetworkSignal.reachable);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(loads, 2);
    expect(find.byType(VersionSelectorButtonWidget), findsOneWidget);
    expect(find.text(AppTexts.offlineStateTitle), findsNothing);
    expect(find.byType(AppLoader), findsNothing);
    // La banda se transformó y el aviso de lo no disponible ya no está.
    expect(find.text(AppTexts.offlineDetailNotice), findsNothing);
    // La seguridad se pide una sola vez, ya con red (el contenido recién apareció).
    expect(safetyCalls, 1);
    // Otras respuestas buenas no recargan otra vez.
    signals.report(NetworkSignal.reachable);
    await tester.pump(const Duration(seconds: 3));
    expect(loads, 2);
    await finish(tester);
  });

  testWidgets(
    'con versiones guardadas, al volver se repone la seguridad una vez',
    (tester) async {
      bool offline = true;
      when(() => load(any())).thenAnswer((_) async => _details());
      stubSafety(offline: () => offline);
      await pumpDetail(tester);
      signals.report(NetworkSignal.unreachable);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(AppTexts.offlineDetailNotice), findsOneWidget);
      expect(safetyCalls, 1);

      offline = false;
      signals.report(NetworkSignal.reachable);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(safetyCalls, 2);
      expect(find.text(AppTexts.offlineDetailNotice), findsNothing);
      // Otra respuesta buena no repite la consulta.
      signals.report(NetworkSignal.reachable);
      await tester.pump(const Duration(seconds: 3));
      expect(safetyCalls, 2);
      await finish(tester);
    },
  );

  testWidgets('abierto desde Favoritos usa la foto guardada en el teléfono', (
    tester,
  ) async {
    when(() => load(any())).thenAnswer((_) async => _details());
    stubSafety(offline: () => false);
    await pumpDetail(
      tester,
      photo: const PhotoEntity(
        thumbnailUrl: 'https://ejemplo.test/a.jpg',
        authorName: 'Ana',
        licenseName: 'CC BY-SA 4.0',
        sourceUrl: 'https://ejemplo.test/origen',
        isReference: false,
        localPath: '/no/existe/foto.jpg',
      ),
    );
    final local = tester.widget<LocalFirstImageWidget>(
      find.byType(LocalFirstImageWidget).first,
    );
    expect(local.localPath, '/no/existe/foto.jpg');
    await finish(tester);
  });
}
