import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  PhotoViewerCubit build({int initial = 1}) =>
      PhotoViewerCubit(initialIndex: initial, photoCount: 3);

  test('arranca en el índice inicial', () {
    expect(build(initial: 2).state, const PhotoViewerState(currentIndex: 2));
    expect(const PhotoViewerState().currentIndex, 0);
  });

  blocTest<PhotoViewerCubit, PhotoViewerState>(
    'selectPage con un índice válido y distinto emite',
    build: build,
    act: (cubit) => cubit.selectPage(2),
    expect: () => [const PhotoViewerState(currentIndex: 2)],
  );

  blocTest<PhotoViewerCubit, PhotoViewerState>(
    'selectPage ignora índices repetidos y fuera de rango',
    build: build,
    act: (cubit) {
      cubit.selectPage(1);
      cubit.selectPage(-1);
      cubit.selectPage(3);
    },
    expect: () => <PhotoViewerState>[],
  );
}
