import 'package:cached_network_image/cached_network_image.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/photos_test_support.dart';

const String _url =
    'https://thumb.wikimedia.org/wikipedia/commons/thumb/9/9e/'
    'Civic.jpg/960px-Civic.jpg';

PhotoEntity _photo({bool isReference = false}) => PhotoEntity(
  thumbnailUrl: _url,
  authorName: 'autor',
  licenseName: 'CC BY 4.0',
  sourceUrl: 'fuente',
  isReference: isReference,
);

void main() {
  final key = photoKeyFor('Honda', 'Civic 4Dr', 2020);

  Widget host(
    Map<String, PhotoSlot> slots, {
    bool disableAnimations = false,
    Map<String, String> logoUrls = const {},
  }) => MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(disableAnimations: disableAnimations),
      child: child!,
    ),
    home: MultiBlocProvider(
      providers: [
        BlocProvider<PhotosCubit>.value(
          value: buildMockPhotosCubit(slots: slots),
        ),
        BlocProvider<BrandLogosCubit>.value(
          value: buildMockBrandLogosCubit(urls: logoUrls),
        ),
      ],
      child: const Scaffold(
        body: Center(
          child: ModelPhotoWidget(
            brand: 'Honda',
            model: 'Civic 4Dr',
            year: 2020,
            width: UiConfig.modelPhotoWidth,
            height: UiConfig.modelPhotoHeight,
            borderRadius: AppRadii.tile,
          ),
        ),
      ),
    ),
  );

  void expectFallback(WidgetTester tester) {
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Symbols.directions_car), findsOneWidget);
    final box = tester.widget<Container>(
      find.ancestor(
        of: find.byIcon(Symbols.directions_car),
        matching: find.byType(Container),
      ),
    );
    expect(box.color, AppColors.tint);
    expect(
      tester.getSize(find.byType(ModelPhotoWidget)),
      const Size(UiConfig.modelPhotoWidth, UiConfig.modelPhotoHeight),
    );
  }

  testWidgets('sin slot muestra el recuadro de respaldo', (tester) async {
    await tester.pumpWidget(host({}));
    expectFallback(tester);
  });

  testWidgets('Loading muestra el recuadro de respaldo', (tester) async {
    await tester.pumpWidget(host({key: const PhotoLoading()}));
    expectFallback(tester);
  });

  testWidgets('Missing muestra el recuadro de respaldo', (tester) async {
    await tester.pumpWidget(host({key: const PhotoMissing()}));
    expectFallback(tester);
  });

  testWidgets('Failed muestra el recuadro de respaldo', (tester) async {
    await tester.pumpWidget(host({key: const PhotoFailed()}));
    expectFallback(tester);
  });

  testWidgets('Found configura la imagen con miniatura, encabezados y radio', (
    tester,
  ) async {
    await tester.pumpWidget(host({key: PhotoFound(_photo())}));
    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(
      image.imageUrl,
      contains('/${PhotosConfig.listThumbnailWidthPixels}px-Civic.jpg'),
    );
    expect(image.httpHeaders, PhotosConfig.requestHeaders);
    expect(image.fit, BoxFit.cover);
    expect(image.alignment, Alignment.center);
    expect(
      image.fadeInDuration,
      const Duration(milliseconds: AnimationConfig.fadeDurationMilliseconds),
    );
    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(clip.borderRadius, BorderRadius.circular(AppRadii.tile));
    expect(find.bySemanticsLabel(AppTexts.referencePhotoLabel), findsNothing);
  });

  testWidgets('con disableAnimations la imagen aparece sin fundido', (
    tester,
  ) async {
    await tester.pumpWidget(
      host({key: PhotoFound(_photo())}, disableAnimations: true),
    );
    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    expect(image.fadeInDuration, Duration.zero);
  });

  testWidgets('una foto de referencia muestra la insignia con su etiqueta', (
    tester,
  ) async {
    await tester.pumpWidget(host({key: PhotoFound(_photo(isReference: true))}));
    final icon = tester.widget<Icon>(find.byIcon(Symbols.info));
    expect(icon.size, UiConfig.referenceBadgeSize);
    expect(find.bySemanticsLabel(AppTexts.referencePhotoLabel), findsOneWidget);
  });

  testWidgets('el error de carga de la imagen muestra el respaldo', (
    tester,
  ) async {
    await tester.pumpWidget(host({key: PhotoFound(_photo())}));
    final image = tester.widget<CachedNetworkImage>(
      find.byType(CachedNetworkImage),
    );
    final context = tester.element(find.byType(CachedNetworkImage));
    final error = image.errorWidget!(context, _url, Exception('falla'));
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<BrandLogosCubit>.value(
          value: buildMockBrandLogosCubit(),
          child: Scaffold(body: error),
        ),
      ),
    );
    expect(find.byIcon(Symbols.directions_car), findsOneWidget);
  });

  testWidgets('con logo de marca el respaldo muestra el logo y no el icono', (
    tester,
  ) async {
    await tester.pumpWidget(host({}, logoUrls: {'Honda': 'logo.png'}));
    expect(find.byIcon(Symbols.directions_car), findsNothing);
    final logo = tester.widget<BrandLogoWidget>(find.byType(BrandLogoWidget));
    expect(logo.brandName, 'Honda');
    expect(logo.size, UiConfig.brandFallbackLogoSize);
    final box = tester.widget<Container>(
      find
          .ancestor(
            of: find.byType(BrandLogoWidget),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(box.color, AppColors.tint);
    expect(box.alignment, Alignment.center);
  });
}
