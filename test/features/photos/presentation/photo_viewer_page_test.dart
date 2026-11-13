import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

PhotoEntity _photo(int index, {bool isReference = false}) => PhotoEntity(
  thumbnailUrl: 'https://upload.test/x/y/960px-foto$index.jpg',
  authorName: 'Autor $index',
  licenseName: 'CC BY 4.0',
  sourceUrl: 'fuente-$index',
  isReference: isReference,
);

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late GoRouter router;
  late Completer<int?> result;

  // Abre el visor desde una pantalla de inicio y guarda lo que devuelve.
  Future<void> openViewer(
    WidgetTester tester,
    List<PhotoEntity> photos, {
    int initialIndex = 0,
  }) async {
    result = Completer<int?>();
    router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('inicio')),
        GoRoute(
          path: RoutesConfig.photoViewer,
          builder: (_, _) => PhotoViewerPage(
            args: PhotoViewerArgsEntity(photos, initialIndex: initialIndex),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
      ),
    );
    await tester.pump();
    unawaited(router.push<int>(RoutesConfig.photoViewer).then(result.complete));
    await tester.pump();
    await tester.pump();
  }

  Finder zoomers() => find.byType(InteractiveViewer);

  testWidgets('empieza en el índice inicial con su crédito', (tester) async {
    await openViewer(tester, [
      _photo(1),
      _photo(2),
      _photo(3),
    ], initialIndex: 1);
    expect(find.text('Foto: Autor 2 · CC BY 4.0'), findsOneWidget);
    expect(find.text('Foto: Autor 1 · CC BY 4.0'), findsNothing);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.photoViewerBackground);
  });

  testWidgets('InteractiveViewer usa los límites de config', (tester) async {
    await openViewer(tester, [_photo(1)]);
    final viewer = tester.widget<InteractiveViewer>(zoomers());
    expect(viewer.minScale, 1.0);
    expect(viewer.maxScale, UiConfig.photoViewerMaxScale);
    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage).first,
    );
    expect(image.fit, BoxFit.contain);
    expect(image.httpHeaders, PhotosConfig.requestHeaders);
    expect(image.imageUrl, _photo(1).thumbnailUrl);
  });

  testWidgets('deslizar cambia el crédito y el punto activo', (tester) async {
    await openViewer(tester, [_photo(1), _photo(2)]);
    expect(
      find.bySemanticsLabel(AppTexts.photoPositionSemanticLabel(1, 2)),
      findsOneWidget,
    );
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('Foto: Autor 2 · CC BY 4.0'), findsOneWidget);
    expect(find.text('Foto: Autor 1 · CC BY 4.0'), findsNothing);
    final dots = tester.widgetList<Container>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration! as BoxDecoration).shape == BoxShape.circle &&
            widget.constraints?.maxWidth == UiConfig.galleryDotSize,
      ),
    );
    final colors = [
      for (final dot in dots) (dot.decoration! as BoxDecoration).color,
    ];
    expect(colors, [AppColors.galleryDotInactive, AppColors.onGradient]);
  });

  testWidgets('con una sola foto no hay puntos', (tester) async {
    await openViewer(tester, [_photo(1)]);
    expect(
      find.bySemanticsLabel(AppTexts.photoPositionSemanticLabel(1, 1)),
      findsNothing,
    );
  });

  testWidgets('la foto de referencia lo indica en el pie', (tester) async {
    await openViewer(tester, [_photo(1, isReference: true)]);
    expect(find.text(AppTexts.referencePhotoLabel), findsOneWidget);
    expect(find.text('Foto: Autor 1 · CC BY 4.0'), findsOneWidget);
  });

  testWidgets('el botón de cerrar devuelve el índice actual', (tester) async {
    await openViewer(tester, [_photo(1), _photo(2)]);
    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(
      find.bySemanticsLabel(AppTexts.photoViewerCloseLabel),
      findsOneWidget,
    );
    final icon = tester.widget<Icon>(find.byIcon(Symbols.close));
    expect(icon.color, AppColors.onGradient);
    expect(
      tester.getSize(find.byIcon(Symbols.close).first),
      isNot(const Size(0, 0)),
    );
    await tester.tap(find.byIcon(Symbols.close));
    await tester.pumpAndSettle();
    expect(await result.future, 1);
    expect(find.text('inicio'), findsOneWidget);
  });

  testWidgets('el gesto de atrás también devuelve el índice actual', (
    tester,
  ) async {
    await openViewer(tester, [
      _photo(1),
      _photo(2),
      _photo(3),
    ], initialIndex: 2);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(await result.future, 2);
    expect(find.text('inicio'), findsOneWidget);
  });
}
