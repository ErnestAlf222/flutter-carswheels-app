import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/detail_test_support.dart';

void main() {
  late MockResolveModelGalleryUseCase resolve;
  final listPhoto = testPhoto(source: 'lista');
  final galleryPhotos = [
    testPhoto(source: 'a'),
    testPhoto(source: 'lista'),
    testPhoto(source: 'b'),
  ];

  setUp(() => resolve = MockResolveModelGalleryUseCase());

  void stub(Future<List<PhotoEntity>> Function() answer) {
    when(
      () => resolve(
        brand: any(named: 'brand'),
        modelName: any(named: 'modelName'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) => answer());
  }

  DetailGalleryCubit build() => DetailGalleryCubit(resolve);

  group('load', () {
    blocTest<DetailGalleryCubit, GalleryState>(
      'con foto de args: primero ella sola cargando y luego ella y la galería sin duplicar',
      build: build,
      setUp: () => stub(() async => galleryPhotos),
      act: (cubit) => cubit.load(testArgs(photo: listPhoto)),
      expect: () => [
        GalleryState(photos: [listPhoto], isLoading: true),
        GalleryState(photos: [listPhoto, galleryPhotos[0], galleryPhotos[2]]),
      ],
      verify: (_) => verify(
        () => resolve(brand: 'Toyota', modelName: 'Corolla', year: 2020),
      ).called(1),
    );

    blocTest<DetailGalleryCubit, GalleryState>(
      'sin foto de args: lista vacía cargando y luego la galería completa',
      build: build,
      setUp: () => stub(() async => galleryPhotos),
      act: (cubit) => cubit.load(testArgs()),
      expect: () => [
        const GalleryState(isLoading: true),
        GalleryState(photos: galleryPhotos),
      ],
    );

    blocTest<DetailGalleryCubit, GalleryState>(
      'galería vacía deja solo la foto de args',
      build: build,
      setUp: () => stub(() async => const []),
      act: (cubit) => cubit.load(testArgs(photo: listPhoto)),
      expect: () => [
        GalleryState(photos: [listPhoto], isLoading: true),
        GalleryState(photos: [listPhoto]),
      ],
    );

    blocTest<DetailGalleryCubit, GalleryState>(
      'un fallo vuelve al estado inicial sin cargar y sin error',
      build: build,
      setUp: () => stub(() async => throw const NetworkFailure('sin red')),
      act: (cubit) => cubit.load(testArgs(photo: listPhoto)),
      expect: () => [
        GalleryState(photos: [listPhoto], isLoading: true),
        GalleryState(photos: [listPhoto]),
      ],
    );

    blocTest<DetailGalleryCubit, GalleryState>(
      'una cancelación sin foto de args termina vacía',
      build: build,
      setUp: () => stub(() async => throw const CancelledFailure('cancelada')),
      act: (cubit) => cubit.load(testArgs()),
      expect: () => [const GalleryState(isLoading: true), const GalleryState()],
    );

    test('una carga vieja no pisa a la nueva', () async {
      final first = Completer<List<PhotoEntity>>();
      final second = Completer<List<PhotoEntity>>();
      final answers = [first, second];
      stub(() => answers.removeAt(0).future);
      final cubit = build();
      addTearDown(cubit.close);
      final emitted = <GalleryState>[];
      final subscription = cubit.stream.listen(emitted.add);
      addTearDown(subscription.cancel);
      unawaited(cubit.load(testArgs()));
      unawaited(cubit.load(testArgs(photo: listPhoto)));
      second.complete([testPhoto(source: 'nueva')]);
      await pumpEventQueue();
      first.complete([testPhoto(source: 'vieja')]);
      await pumpEventQueue();
      expect(cubit.state.photos.map((photo) => photo.sourceUrl), [
        'lista',
        'nueva',
      ]);
      expect(
        emitted.expand((state) => state.photos).map((photo) => photo.sourceUrl),
        isNot(contains('vieja')),
      );
    });

    test('no emite si se cierra antes de terminar', () async {
      final pending = Completer<List<PhotoEntity>>();
      stub(() => pending.future);
      final cubit = build();
      final emitted = <GalleryState>[];
      final subscription = cubit.stream.listen(emitted.add);
      unawaited(cubit.load(testArgs()));
      await pumpEventQueue();
      await cubit.close();
      pending.complete(galleryPhotos);
      await pumpEventQueue();
      await subscription.cancel();
      expect(emitted, [const GalleryState(isLoading: true)]);
    });

    test('load después de cerrar no hace nada', () async {
      final cubit = build();
      await cubit.close();
      await cubit.load(testArgs());
      verifyNever(
        () => resolve(
          brand: any(named: 'brand'),
          modelName: any(named: 'modelName'),
          year: any(named: 'year'),
        ),
      );
    });
  });

  group('selectPage', () {
    final loaded = GalleryState(photos: galleryPhotos);

    blocTest<DetailGalleryCubit, GalleryState>(
      'un índice válido distinto cambia la foto actual',
      build: build,
      seed: () => loaded,
      act: (cubit) => cubit.selectPage(2),
      expect: () => [GalleryState(photos: galleryPhotos, currentIndex: 2)],
    );

    blocTest<DetailGalleryCubit, GalleryState>(
      'índices inválidos o repetidos se ignoran',
      build: build,
      seed: () => loaded,
      act: (cubit) {
        cubit
          ..selectPage(-1)
          ..selectPage(3)
          ..selectPage(0);
      },
      expect: () => <GalleryState>[],
    );

    blocTest<DetailGalleryCubit, GalleryState>(
      'sin fotos no hay índice válido',
      build: build,
      act: (cubit) => cubit.selectPage(0),
      expect: () => <GalleryState>[],
    );
  });
}
