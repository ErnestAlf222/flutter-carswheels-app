import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/brand_logos_test_support.dart';
import '../../../support/photos_test_support.dart';

const PhotoEntity _photo = PhotoEntity(
  thumbnailUrl: 'https://upload.test/civic-960px.jpg',
  authorName: 'autor',
  licenseName: 'CC BY 4.0',
  sourceUrl: 'fuente',
  isReference: false,
);

void main() {
  final key = photoKeyFor('Honda', 'Civic', 2020);

  Widget host(PhotoSlot? slot, {String? heroTag}) => MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<PhotosCubit>.value(
          value: buildMockPhotosCubit(slots: {key: ?slot}),
        ),
        BlocProvider<BrandLogosCubit>.value(value: buildMockBrandLogosCubit()),
      ],
      child: Scaffold(
        body: ModelPhotoWidget(
          brand: 'Honda',
          model: 'Civic',
          year: 2020,
          width: UiConfig.modelPhotoWidth,
          height: UiConfig.modelPhotoHeight,
          borderRadius: AppRadii.tile,
          heroTag: heroTag,
        ),
      ),
    ),
  );

  testWidgets('con heroTag y PhotoFound hay un Hero con esa etiqueta', (
    tester,
  ) async {
    await tester.pumpWidget(host(const PhotoFound(_photo), heroTag: 'tag'));
    final hero = tester.widget<Hero>(find.byType(Hero));
    expect(hero.tag, 'tag');
    expect(hero.flightShuttleBuilder, isNotNull);
  });

  testWidgets('sin heroTag no hay Hero', (tester) async {
    await tester.pumpWidget(host(const PhotoFound(_photo)));
    expect(find.byType(Hero), findsNothing);
  });

  testWidgets('con heroTag pero sin foto no hay Hero', (tester) async {
    for (final slot in <PhotoSlot?>[
      null,
      const PhotoLoading(),
      const PhotoMissing(),
      const PhotoFailed(),
    ]) {
      await tester.pumpWidget(host(slot, heroTag: 'tag'));
      expect(find.byType(Hero), findsNothing);
    }
  });

  testWidgets('el vuelo interpola el radio entre la lista y Detalle', (
    tester,
  ) async {
    const animation = AlwaysStoppedAnimation<double>(0.5);
    const child = SizedBox(key: ValueKey('hijo'));
    late BuildContext context;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (built) {
            context = built;
            return const Hero(tag: 'tag', child: child);
          },
        ),
      ),
    );
    final heroContext = tester.element(find.byType(Hero));
    final push = PhotoHeroShuttle.builder(
      context,
      animation,
      HeroFlightDirection.push,
      heroContext,
      heroContext,
    );
    await tester.pumpWidget(MaterialApp(home: push));
    final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));
    expect(
      clip.borderRadius,
      BorderRadius.circular((AppRadii.tile + AppRadii.detailPhotoCard) / 2),
    );
    expect(find.byKey(const ValueKey('hijo')), findsOneWidget);
  });
}
