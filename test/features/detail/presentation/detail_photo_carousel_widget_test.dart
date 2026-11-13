import 'package:cached_network_image/cached_network_image.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/detail_test_support.dart';

/// Anota las precargas en vez de ir a la red.
class _RecordingPrefetcher extends PhotoPrefetcher {
  _RecordingPrefetcher();

  final List<String> sources = [];

  @override
  Future<void> prefetchLarge(BuildContext context, PhotoEntity photo) async {
    sources.add(photo.sourceUrl);
  }
}

PhotoEntity _photo(int index, {bool isReference = false, String? author}) =>
    testPhoto(
      url: 'https://upload.test/x/y/960px-foto$index.jpg',
      source: 'fuente-$index',
      author: author ?? 'Autor $index',
      isReference: isReference,
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

  testWidgets('sin fotos muestra el logo de respaldo y ni puntos ni crédito', (
    tester,
  ) async {
    await tester.pumpWidget(carousel(const GalleryState(isLoading: true)));
    expect(find.byType(BrandLogoWidget), findsOneWidget);
    expect(find.byType(PageView), findsNothing);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byType(Hero), findsNothing);
    expect(dots(), findsNothing);
    expect(find.textContaining('Foto:'), findsNothing);
  });

  testWidgets('la tarjeta es blanca, de 150, esquinas de 32 y sombra suave', (
    tester,
  ) async {
    await tester.pumpWidget(carousel(GalleryState(photos: [_photo(1)])));
    final container = tester.widget<Container>(cardFinder());
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AppColors.card);
    expect(decoration.borderRadius, BorderRadius.circular(32));
    expect(decoration.boxShadow, AppShadows.soft);
    expect(container.clipBehavior, Clip.antiAlias);
    expect(tester.getSize(cardFinder()).height, UiConfig.detailPhotoHeight);
  });

  testWidgets('una foto: sin puntos, con Hero en la página 0 y crédito', (
    tester,
  ) async {
    await tester.pumpWidget(carousel(GalleryState(photos: [_photo(1)])));
    expect(find.byType(PageView), findsOneWidget);
    expect(dots(), findsNothing);
    expect(tester.widget<Hero>(find.byType(Hero)).tag, 'tag');
    expect(find.text('Foto: Autor 1 · CC BY 4.0'), findsOneWidget);
    expect(find.byType(ImageFiltered), findsOneWidget);
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
    expect(
      find.text('${AppTexts.referencePhotoLabel} · Foto: Segunda · CC BY 4.0'),
      findsOneWidget,
    );
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
    final large = images.where((image) => image.fit == BoxFit.contain);
    expect(
      large.map((image) => image.imageUrl),
      contains(_photo(1).thumbnailUrl),
    );
    final placeholder = images.where(
      (image) =>
          image.fit == BoxFit.contain &&
          image.imageUrl.contains(
            '/${PhotosConfig.listThumbnailWidthPixels}px-',
          ),
    );
    expect(placeholder, hasLength(1));
    expect(
      placeholder.single.imageUrl,
      'https://upload.test/x/y/${PhotosConfig.listThumbnailWidthPixels}px-foto1.jpg',
    );
    expect(placeholder.single.httpHeaders, PhotosConfig.requestHeaders);
    // El fondo difuminado también usa la pequeña, cubriendo la tarjeta.
    final blurred = images.where((image) => image.fit == BoxFit.cover);
    expect(blurred.single.imageUrl, placeholder.single.imageUrl);
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
}
