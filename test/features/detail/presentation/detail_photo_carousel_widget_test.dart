import 'package:cached_network_image/cached_network_image.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/detail_test_support.dart';

/// Router falso para comprobar la navegación al visor.
class MockGoRouter extends Mock implements GoRouter {}

/// Anota las precargas en vez de ir a la red.
class _RecordingPrefetcher extends PhotoPrefetcher {
  _RecordingPrefetcher();

  final List<String> sources = [];

  @override
  Future<void> prefetchLarge(BuildContext context, PhotoEntity photo) async {
    sources.add(photo.sourceUrl);
  }
}

PhotoEntity _photo(
  int index, {
  bool isReference = false,
  String? author,
  double? aspectRatio,
}) => testPhoto(
  url: 'https://upload.test/x/y/960px-foto$index.jpg',
  source: 'fuente-$index',
  author: author ?? 'Autor $index',
  isReference: isReference,
  aspectRatio: aspectRatio,
);

void main() {
  setUpAll(() {
    disableFontFetching();
    registerFallbackValue(0);
  });

  Widget carousel(
    GalleryState state, {
    MockDetailGalleryCubit? cubit,
    PhotoPrefetcher prefetcher = const PhotoPrefetcher(),
    bool disableAnimations = true,
    String? heroTag = 'tag',
  }) => detailHost(
    Center(
      child: SizedBox(
        width: 300,
        child: DetailPhotoCarouselWidget(brandName: 'Toyota', heroTag: heroTag),
      ),
    ),
    galleryCubit: cubit ?? buildMockGalleryCubit(state),
    prefetcher: prefetcher,
    disableAnimations: disableAnimations,
  );

  Finder cardFinder() => find.byWidgetPredicate(
    (widget) =>
        widget is Container &&
        widget.constraints?.maxHeight == UiConfig.detailPhotoHeight,
  );

  Finder dots() => find.byType(AnimatedContainer);

  Finder chipBox() => find
      .ancestor(
        of: find.text(AppTexts.referencePhotoLabel),
        matching: find.byType(DecoratedBox),
      )
      .first;

  testWidgets('sin fotos y cargando muestra el placeholder de carga', (
    tester,
  ) async {
    await tester.pumpWidget(carousel(const GalleryState(isLoading: true)));
    final placeholder = tester.widget<PhotoPlaceholderWidget>(
      find.byType(PhotoPlaceholderWidget),
    );
    expect(placeholder.kind, PhotoPlaceholderKind.loading);
    expect(find.byType(PageView), findsNothing);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byType(Hero), findsNothing);
    expect(dots(), findsNothing);
    expect(find.textContaining('Foto:'), findsNothing);
  });

  testWidgets('sin fotos y sin cargar muestra el placeholder vacío con logo', (
    tester,
  ) async {
    await tester.pumpWidget(carousel(const GalleryState()));
    final placeholder = tester.widget<PhotoPlaceholderWidget>(
      find.byType(PhotoPlaceholderWidget),
    );
    expect(placeholder.kind, PhotoPlaceholderKind.empty);
    final logo = tester.widget<BrandLogoWidget>(find.byType(BrandLogoWidget));
    expect(logo.brandName, 'Toyota');
    expect(logo.size, UiConfig.photoEmptyLogoSize);
    expect(find.text(AppTexts.noPhotoTitle), findsOneWidget);
    expect(find.textContaining('Foto:'), findsNothing);
    expect(dots(), findsNothing);
  });

  testWidgets('la tarjeta es blanca, de 220, esquinas de 32 y sombra suave', (
    tester,
  ) async {
    await tester.pumpWidget(carousel(GalleryState(photos: [_photo(1)])));
    final container = tester.widget<Container>(cardFinder());
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.card);
    expect(decoration.borderRadius, BorderRadius.circular(32));
    expect(decoration.boxShadow, AppShadows.soft);
    expect(container.clipBehavior, Clip.antiAlias);
    expect(tester.getSize(cardFinder()).height, 220);
    expect(UiConfig.detailPhotoHeight, 220);
  });

  testWidgets('en el encabezado la tarjeta queda a 20 del borde', (
    tester,
  ) async {
    await tester.pumpWidget(
      detailHost(
        const DetailHeroHeaderWidget(
          args: DetailArgsEntity(
            brand: 'Toyota',
            groupName: 'Corolla',
            year: 2020,
            variantNames: ['Corolla'],
            photo: null,
            heroTag: 'tag',
          ),
        ),
        galleryCubit: buildMockGalleryCubit(GalleryState(photos: [_photo(1)])),
      ),
    );
    final card = tester.getRect(cardFinder());
    expect(card.left, 20);
    expect(UiConfig.detailPhotoSideMargin, 20);
    expect(card.top, UiConfig.detailPhotoTop);
  });

  testWidgets('una foto: sin puntos, con Hero en la página 0 y crédito', (
    tester,
  ) async {
    await tester.pumpWidget(carousel(GalleryState(photos: [_photo(1)])));
    expect(find.byType(PageView), findsOneWidget);
    expect(dots(), findsNothing);
    expect(tester.widget<Hero>(find.byType(Hero)).tag, 'tag');
    expect(find.text('Foto: Autor 1 · CC BY 4.0'), findsOneWidget);
    expect(find.byType(ImageFiltered), findsNothing);
  });

  testWidgets('sin heroTag no hay Hero', (tester) async {
    await tester.pumpWidget(
      carousel(GalleryState(photos: [_photo(1)]), heroTag: null),
    );
    expect(find.byType(Hero), findsNothing);
  });

  testWidgets('varias fotos: un punto por foto con el activo marcado', (
    tester,
  ) async {
    await tester.pumpWidget(
      carousel(GalleryState(photos: [_photo(1), _photo(2), _photo(3)])),
    );
    expect(dots(), findsNWidgets(3));
    final colors = [
      for (final dot in tester.widgetList<AnimatedContainer>(dots()))
        (dot.decoration! as BoxDecoration).color,
    ];
    expect(colors, [
      AppColors.galleryDotActive,
      AppColors.galleryDotInactive,
      AppColors.galleryDotInactive,
    ]);
    final size = tester.getSize(dots().first);
    expect(size, const Size(UiConfig.galleryDotSize, UiConfig.galleryDotSize));
    for (final position in [1, 2, 3]) {
      expect(
        find.bySemanticsLabel(AppTexts.photoPositionSemanticLabel(position, 3)),
        findsOneWidget,
      );
    }
  });

  testWidgets('los puntos usan el fondo oscuro de la galería', (tester) async {
    await tester.pumpWidget(
      carousel(GalleryState(photos: [_photo(1), _photo(2)])),
    );
    final pill = tester.widget<Container>(
      find.ancestor(of: dots().first, matching: find.byType(Container)).first,
    );
    expect(
      (pill.decoration! as BoxDecoration).color,
      AppColors.galleryDotsBackground,
    );
  });

  testWidgets('los puntos quedan centrados y a 8 del borde inferior', (
    tester,
  ) async {
    await tester.pumpWidget(
      carousel(GalleryState(photos: [_photo(1), _photo(2)])),
    );
    final card = tester.getRect(cardFinder());
    final pill = tester.getRect(
      find.ancestor(of: dots().first, matching: find.byType(Container)).first,
    );
    expect(pill.center.dx, closeTo(card.center.dx, 0.01));
    expect(card.bottom - pill.bottom, UiConfig.galleryDotsBottomInset);
  });

  testWidgets('el punto activo y el crédito siguen a la foto actual', (
    tester,
  ) async {
    await tester.pumpWidget(
      carousel(
        GalleryState(
          photos: [
            _photo(1),
            _photo(2, isReference: true, author: 'Segunda'),
          ],
          currentIndex: 1,
        ),
      ),
    );
    final colors = [
      for (final dot in tester.widgetList<AnimatedContainer>(dots()))
        (dot.decoration! as BoxDecoration).color,
    ];
    expect(colors.last, AppColors.galleryDotActive);
    expect(find.text('Foto: Segunda · CC BY 4.0'), findsOneWidget);
    expect(find.textContaining('Autor 1'), findsNothing);
  });

  testWidgets('sin autor usa el texto de autor no indicado', (tester) async {
    await tester.pumpWidget(
      carousel(GalleryState(photos: [_photo(1, author: '  ')])),
    );
    expect(
      find.text(
        AppTexts.photoCreditLabel(AppTexts.authorMissingLabel, 'CC BY 4.0'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('el crédito admite hasta 2 líneas y va centrado', (tester) async {
    await tester.pumpWidget(
      carousel(GalleryState(photos: [_photo(1, author: 'Autor ' * 20)])),
    );
    final text = tester.widget<Text>(find.textContaining('Foto: Autor'));
    expect(text.maxLines, UiConfig.photoCreditMaxLines);
    expect(text.maxLines, 2);
    expect(text.textAlign, TextAlign.center);
  });

  testWidgets('la cápsula de referencia solo aparece con isReference', (
    tester,
  ) async {
    await tester.pumpWidget(carousel(GalleryState(photos: [_photo(1)])));
    expect(find.text(AppTexts.referencePhotoLabel), findsNothing);
    await tester.pumpWidget(
      carousel(GalleryState(photos: [_photo(1, isReference: true)])),
    );
    expect(find.text(AppTexts.referencePhotoLabel), findsOneWidget);
    expect(find.byIcon(Symbols.info), findsOneWidget);
    final decoration = tester.widget<DecoratedBox>(chipBox()).decoration;
    expect(
      decoration,
      BoxDecoration(
        color: AppColors.photoChipBackground,
        borderRadius: BorderRadius.circular(UiConfig.photoChipRadius),
      ),
    );
    final card = tester.getRect(cardFinder());
    final chip = tester.getRect(chipBox());
    expect(chip.left - card.left, UiConfig.photoChipInset);
    expect(chip.top - card.top, UiConfig.photoChipInset);
    // El crédito ya no lleva la etiqueta de referencia.
    expect(find.text('Foto: Autor 1 · CC BY 4.0'), findsOneWidget);
  });

  testWidgets('solo la página 0 lleva el Hero', (tester) async {
    await tester.pumpWidget(
      carousel(
        GalleryState(
          photos: [_photo(1), _photo(2), _photo(3)],
          currentIndex: 1,
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(Hero), findsNothing);
  });

  testWidgets('deslizar llama a selectPage y precarga la foto siguiente', (
    tester,
  ) async {
    final cubit = buildMockGalleryCubit(
      GalleryState(photos: [_photo(1), _photo(2), _photo(3)]),
    );
    final prefetcher = _RecordingPrefetcher();
    await tester.pumpWidget(
      carousel(const GalleryState(), cubit: cubit, prefetcher: prefetcher),
    );
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    verify(() => cubit.selectPage(1)).called(1);
    expect(prefetcher.sources, ['fuente-3']);
  });

  testWidgets('en la última foto no se precarga nada', (tester) async {
    final cubit = buildMockGalleryCubit(
      GalleryState(photos: [_photo(1), _photo(2)]),
    );
    final prefetcher = _RecordingPrefetcher();
    await tester.pumpWidget(
      carousel(const GalleryState(), cubit: cubit, prefetcher: prefetcher),
    );
    await tester.drag(find.byType(PageView), const Offset(-300, 0));
    await tester.pumpAndSettle();
    verify(() => cubit.selectPage(1)).called(1);
    expect(prefetcher.sources, isEmpty);
  });

  testWidgets('la imagen grande usa la URL de 960 y su placeholder la de 330', (
    tester,
  ) async {
    await tester.pumpWidget(carousel(GalleryState(photos: [_photo(1)])));
    final images = tester
        .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
        .toList();
    expect(images.every((image) => image.fit == BoxFit.cover), isTrue);
    expect(
      images.map((image) => image.imageUrl),
      contains(_photo(1).thumbnailUrl),
    );
    final placeholder = images.where(
      (image) => image.imageUrl.contains(
        '/${PhotosConfig.listThumbnailWidthPixels}px-',
      ),
    );
    expect(placeholder, hasLength(1));
    expect(
      placeholder.single.imageUrl,
      'https://upload.test/x/y/${PhotosConfig.listThumbnailWidthPixels}px-foto1.jpg',
    );
    expect(placeholder.single.httpHeaders, PhotosConfig.requestHeaders);
    expect(placeholder.single.alignment, Alignment.center);
  });

  testWidgets('proporción 1.5: cover llena la tarjeta sin fondo difuminado', (
    tester,
  ) async {
    await tester.pumpWidget(
      carousel(GalleryState(photos: [_photo(1, aspectRatio: 1.5)])),
    );
    expect(find.byType(ImageFiltered), findsNothing);
    final large = tester
        .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
        .firstWhere((image) => image.imageUrl.contains('960px'));
    expect(large.fit, BoxFit.cover);
    expect(large.alignment, Alignment.center);
  });

  testWidgets('proporción 3.0: contain con el fondo difuminado', (
    tester,
  ) async {
    await tester.pumpWidget(
      carousel(GalleryState(photos: [_photo(1, aspectRatio: 3.0)])),
    );
    expect(find.byType(ImageFiltered), findsOneWidget);
    final images = tester
        .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
        .toList();
    final large = images.firstWhere((i) => i.imageUrl.contains('960px'));
    expect(large.fit, BoxFit.contain);
    final blurred = images.where(
      (i) => i.fit == BoxFit.cover && i.imageUrl.contains('330px'),
    );
    expect(blurred, hasLength(1));
  });

  testWidgets(
    'el cambio a la grande es un fundido, salvo con disableAnimations',
    (tester) async {
      await tester.pumpWidget(
        carousel(GalleryState(photos: [_photo(1)]), disableAnimations: false),
      );
      final animated = tester
          .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
          .firstWhere((image) => image.imageUrl.contains('960px'));
      expect(
        animated.fadeInDuration,
        const Duration(milliseconds: AnimationConfig.fadeDurationMilliseconds),
      );
      await tester.pumpWidget(carousel(GalleryState(photos: [_photo(1)])));
      final still = tester
          .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
          .firstWhere((image) => image.imageUrl.contains('960px'));
      expect(still.fadeInDuration, Duration.zero);
      expect(still.fadeOutDuration, Duration.zero);
    },
  );

  group('visor', () {
    testWidgets('tocar la foto abre el visor con las fotos y el índice', (
      tester,
    ) async {
      final router = MockGoRouter();
      when(() => router.push<int>(any(), extra: any(named: 'extra')))
          .thenAnswer((_) async => null);
      final photos = [_photo(1), _photo(2)];
      await tester.pumpWidget(
        InheritedGoRouter(
          goRouter: router,
          child: carousel(GalleryState(photos: photos, currentIndex: 1)),
        ),
      );
      await tester.tap(find.byType(PageView));
      await tester.pump();
      final captured =
          verify(
                () => router.push<int>(
                  RoutesConfig.photoViewer,
                  extra: captureAny(named: 'extra'),
                ),
              ).captured.single
              as PhotoViewerArgsEntity;
      expect(captured.photos, photos);
      expect(captured.initialIndex, 1);
    });

    testWidgets('el índice devuelto mueve el carrusel y llama a selectPage', (
      tester,
    ) async {
      final router = MockGoRouter();
      when(() => router.push<int>(any(), extra: any(named: 'extra')))
          .thenAnswer((_) async => 1);
      final cubit = buildMockGalleryCubit(
        GalleryState(photos: [_photo(1), _photo(2)]),
      );
      await tester.pumpWidget(
        InheritedGoRouter(
          goRouter: router,
          child: carousel(const GalleryState(), cubit: cubit),
        ),
      );
      await tester.tap(find.byType(PageView));
      await tester.pumpAndSettle();
      verify(() => cubit.selectPage(1)).called(greaterThanOrEqualTo(1));
      final controller = tester
          .widget<PageView>(find.byType(PageView))
          .controller;
      expect(controller!.page, 1);
    });

    testWidgets('la foto tiene semántica de botón para ver en grande', (
      tester,
    ) async {
      await tester.pumpWidget(carousel(GalleryState(photos: [_photo(1)])));
      expect(
        find.bySemanticsLabel(AppTexts.expandPhotoSemanticLabel),
        findsOneWidget,
      );
    });
  });
}
