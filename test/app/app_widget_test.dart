import 'package:cars_wheels_app/app/app.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakePhotoCache implements PhotoCacheDatasource {
  @override
  Future<CachedPhotoEntity?> read(String key) async => null;

  @override
  Future<void> write(String key, CachedPhotoEntity entry) async {}
}

class _FakeSummaryCache implements SummaryCacheDatasource {
  @override
  Future<CachedSummaryEntity?> read(String key) async => null;

  @override
  Future<void> write(String key, CachedSummaryEntity entry) async {}
}

App _buildApp() => App(
  dependencies: AppDependencies.create(
    photoCache: _FakePhotoCache(),
    summaryCache: _FakeSummaryCache(),
  ),
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App muestra la pantalla de inicio', (tester) async {
    await tester.pumpWidget(_buildApp());
    // Deja pasar el tiempo mínimo del loader para no dejar temporizadores.
    await tester.pump(
      const Duration(
        milliseconds: UiConfig.initialLoaderMinimumVisibleMilliseconds,
      ),
    );
    await tester.pumpAndSettle();
    // En pruebas toda petición HTTP falla: la carga inicial termina en error.
    expect(find.byType(ErrorStateWidget), findsOneWidget);
  });

  testWidgets('MaterialApp no muestra la cinta de depuración', (tester) async {
    await tester.pumpWidget(_buildApp());
    await tester.pump(
      const Duration(
        milliseconds: UiConfig.initialLoaderMinimumVisibleMilliseconds,
      ),
    );
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.debugShowCheckedModeBanner, isFalse);
    expect(AppConfig.showDebugBanner, isFalse);
  });
}
