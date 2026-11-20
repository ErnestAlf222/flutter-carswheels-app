import 'dart:async';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

// Responde que hay conexión: la verificación al abrir no cambia nada.
class _NeverProbe implements ConnectionProbe {
  @override
  Future<bool> isReachable() async => true;
}

void main() {
  late NetworkSignals signals;
  late ConnectivityCubit cubit;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // Se arma dentro de cada prueba: así sus eventos corren en el reloj falso.
  void buildCubit() {
    signals = NetworkSignals();
    cubit = ConnectivityCubit(
      signals: signals,
      probe: _NeverProbe(),
      judge: ConnectionJudge(slowFailuresToGoOffline: 2),
      backoff: const ReconnectBackoff(
        initialDelay: Duration(minutes: 30),
        maxDelay: Duration(minutes: 30),
        factor: 1,
      ),
      restoredNoticeDuration: const Duration(seconds: 2),
    );
  }

  // Cada prueba arma su cubit y lo cierra al terminar: sin temporizadores sueltos.
  void bandTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      buildCubit();
      await body(tester);
      await tester.pumpWidget(const SizedBox());
      // El reloj de la prueba es falso: se cierra sin esperar a un futuro real.
      unawaited(cubit.close());
      unawaited(signals.close());
      await tester.pump();
    });
  }

  Future<void> pumpBand(
    WidgetTester tester, {
    String? offlineLabel,
    double textScale = 1.0,
    bool disableAnimations = false,
    bool withCubit = true,
    Size size = const Size(360, 640),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final band = CustomScrollView(
      slivers: [
        offlineLabel == null
            ? const ConnectivityBandSliver()
            : ConnectivityBandSliver(offlineLabel: offlineLabel),
        const SliverToBoxAdapter(child: Text('contenido')),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: disableAnimations,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: Scaffold(
          body: withCubit
              ? BlocProvider<ConnectivityCubit>.value(value: cubit, child: band)
              : band,
        ),
      ),
    );
  }

  Future<void> goOffline(WidgetTester tester) async {
    signals.report(NetworkSignal.unreachable);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  bandTest('en línea no hay banda', (tester) async {
    await pumpBand(tester);
    expect(find.text(AppTexts.offlineBandLabel), findsNothing);
    expect(find.text(AppTexts.onlineRestoredLabel), findsNothing);
  });

  bandTest('al caer la conexión aparece la banda delgada', (tester) async {
    await pumpBand(tester);
    await goOffline(tester);
    expect(find.text(AppTexts.offlineBandLabel), findsOneWidget);
    // Delgada: una sola línea de texto, no una pantalla ni un loader.
    final height = tester
        .getSize(find.byType(ConnectivityBandWidget, skipOffstage: false))
        .height;
    expect(height, lessThan(48));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('contenido'), findsOneWidget);
  });

  bandTest('al volver se transforma en "Conexión restablecida" y se va', (
    tester,
  ) async {
    await pumpBand(tester);
    await goOffline(tester);
    signals.report(NetworkSignal.reachable);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.onlineRestoredLabel), findsOneWidget);
    expect(find.text(AppTexts.offlineBandLabel), findsNothing);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text(AppTexts.onlineRestoredLabel), findsNothing);
    expect(
      tester
          .getSize(find.byType(ConnectivityBandWidget, skipOffstage: false))
          .height,
      0,
    );
  });

  bandTest('Favoritos usa su texto: lo guardado sigue disponible', (
    tester,
  ) async {
    await pumpBand(tester, offlineLabel: AppTexts.offlineFavoritesBandLabel);
    await goOffline(tester);
    expect(find.text(AppTexts.offlineFavoritesBandLabel), findsOneWidget);
    expect(find.text(AppTexts.offlineBandLabel), findsNothing);
  });

  bandTest('con disableAnimations el cambio es inmediato', (tester) async {
    await pumpBand(tester, disableAnimations: true);
    signals.report(NetworkSignal.unreachable);
    await tester.pump();
    expect(find.text(AppTexts.offlineBandLabel), findsOneWidget);
  });

  bandTest('sin cubit de conexión no muestra nada ni falla', (tester) async {
    await pumpBand(tester, withCubit: false);
    expect(find.text('contenido'), findsOneWidget);
    expect(
      find.byType(ConnectivityBandWidget, skipOffstage: false),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  bandTest('sin desbordes a 360 dp y texto a 1.3, con el texto largo', (
    tester,
  ) async {
    await pumpBand(
      tester,
      textScale: 1.3,
      offlineLabel: AppTexts.offlineFavoritesBandLabel,
    );
    await goOffline(tester);
    expect(tester.takeException(), isNull);
    expect(find.text(AppTexts.offlineFavoritesBandLabel), findsOneWidget);
  });

  bandTest('ConnectivityRestoreListener recarga una sola vez por regreso', (
    tester,
  ) async {
    int restored = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ConnectivityCubit>.value(
          value: cubit,
          child: ConnectivityRestoreListener(
            onRestored: () => restored++,
            child: const SizedBox(),
          ),
        ),
      ),
    );
    signals.report(NetworkSignal.unreachable);
    await tester.pump();
    expect(restored, 0);
    signals.report(NetworkSignal.reachable);
    await tester.pump();
    // Más respuestas buenas, el aviso que se retira y otro rebuild: nada se repite.
    signals.report(NetworkSignal.reachable);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(restored, 1);
    // Una segunda caída y regreso sí cuenta como otra restauración.
    signals.report(NetworkSignal.unreachable);
    await tester.pump();
    signals.report(NetworkSignal.reachable);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(restored, 2);
  });

  bandTest('el error sin conexión lo dice claro, con un solo Reintentar', (
    tester,
  ) async {
    int retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ConnectivityCubit>.value(
          value: cubit,
          child: Scaffold(
            body: ConnectivityErrorStateWidget(onRetry: () => retries++),
          ),
        ),
      ),
    );
    expect(find.text(AppTexts.errorStateTitle), findsOneWidget);
    signals.report(NetworkSignal.unreachable);
    await tester.pump();
    expect(find.text(AppTexts.offlineStateTitle), findsOneWidget);
    expect(find.text(AppTexts.errorStateTitle), findsNothing);
    expect(find.text(AppTexts.retryButtonLabel), findsOneWidget);
    await tester.tap(find.text(AppTexts.retryButtonLabel));
    expect(retries, 1);
  });
}
