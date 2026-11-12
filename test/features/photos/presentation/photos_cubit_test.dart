import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockResolve extends Mock implements ResolveModelPhotoUseCase {}

class _MockCancel extends Mock implements CancelPendingPhotosUseCase {}

const PhotoEntity _photo = PhotoEntity(
  thumbnailUrl: 'miniatura',
  authorName: 'autor',
  licenseName: 'CC BY 4.0',
  sourceUrl: 'fuente',
  isReference: false,
);

const PhotoRequest _civic4 = PhotoRequest(
  brand: 'Honda',
  model: 'Civic 4Dr',
  year: 2020,
);
const PhotoRequest _civic2 = PhotoRequest(
  brand: 'Honda',
  model: 'Civic 2Dr',
  year: 2020,
);
const PhotoRequest _accord = PhotoRequest(
  brand: 'Honda',
  model: 'Accord',
  year: 2020,
);

void main() {
  late _MockResolve resolve;
  late _MockCancel cancel;
  late PhotosCubit cubit;

  String key(PhotoRequest request) => cubit.keyFor(request);

  setUp(() {
    resolve = _MockResolve();
    cancel = _MockCancel();
    when(() => cancel()).thenReturn(null);
    cubit = PhotosCubit(
      resolveModelPhoto: resolve,
      cancelPendingPhotos: cancel,
      keyBuilder: const PhotoKeyBuilder(selector: PhotoCandidateSelector()),
    );
  });

  tearDown(() => cubit.close());

  void stubResolve(Future<PhotoEntity?> Function(String model) answer) {
    when(
      () => resolve(
        brand: any(named: 'brand'),
        modelName: any(named: 'modelName'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((call) => answer(call.namedArguments[#modelName] as String));
  }

  Future<PhotoEntity?> resolved(String model) async =>
      model == 'Accord' ? null : _photo;

  test('el lote con claves repetidas se resuelve una sola vez', () async {
    stubResolve(resolved);
    cubit.requestPhotos([_civic4, _civic2, _accord]);
    await Future<void>.delayed(Duration.zero);
    verify(() => resolve(brand: 'Honda', modelName: 'Civic 4Dr', year: 2020))
        .called(1);
    verify(() => resolve(brand: 'Honda', modelName: 'Accord', year: 2020))
        .called(1);
    verifyNoMoreInteractions(resolve);
  });

  blocTest<PhotosCubit, PhotosState>(
    'marca Loading en una sola emisión y luego Found o Missing',
    build: () {
      stubResolve(resolved);
      return cubit;
    },
    act: (cubit) => cubit.requestPhotos([_civic4, _accord]),
    wait: Duration.zero,
    expect: () => [
      isA<PhotosState>().having(
        (state) => state.slots.values.toList(),
        'slots',
        const [PhotoLoading(), PhotoLoading()],
      ),
      isA<PhotosState>().having(
        (state) => state.slots[key(_civic4)],
        'civic',
        const PhotoFound(_photo),
      ),
      isA<PhotosState>().having(
        (state) => state.slots[key(_accord)],
        'accord',
        const PhotoMissing(),
      ),
    ],
  );

  test('lanza las resoluciones en el orden de la lista', () async {
    final order = <String>[];
    stubResolve((model) async {
      order.add(model);
      return _photo;
    });
    cubit.requestPhotos([_accord, _civic4]);
    expect(order, ['Accord', 'Civic 4Dr']);
  });

  test('no repite lo que ya está Loading, Found o Missing', () async {
    final pending = Completer<PhotoEntity?>();
    stubResolve(
      (model) => model == 'Civic 4Dr' ? pending.future : resolved(model),
    );
    cubit.requestPhotos([_civic4, _accord]);
    await Future<void>.delayed(Duration.zero);
    cubit.requestPhotos([_civic4, _accord]);
    verify(
      () => resolve(
        brand: any(named: 'brand'),
        modelName: any(named: 'modelName'),
        year: any(named: 'year'),
      ),
    ).called(2);
    pending.complete(_photo);
  });

  test('reintenta un espacio Failed', () async {
    final attempts = <int>[];
    stubResolve((model) async {
      attempts.add(1);
      if (attempts.length == 1) throw const NetworkFailure('sin red');
      return _photo;
    });
    cubit.requestPhotos([_civic4]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic4)], const PhotoFailed());
    cubit.requestPhotos([_civic4]);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic4)], const PhotoFound(_photo));
  });

  test('cancelPending cancela y deja Failed lo que estaba Loading', () async {
    final pending = Completer<PhotoEntity?>();
    stubResolve((model) => pending.future);
    cubit.requestPhotos([_civic4]);
    cubit.cancelPending();
    verify(() => cancel()).called(1);
    expect(cubit.state.slots[key(_civic4)], const PhotoFailed());
    pending.completeError(const CancelledFailure('cancelada'));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic4)], const PhotoFailed());
  });

  test('una cancelación tardía no pisa un pedido más nuevo', () async {
    final first = Completer<PhotoEntity?>();
    final second = Completer<PhotoEntity?>();
    final completers = [first, second];
    stubResolve((model) => completers.removeAt(0).future);
    cubit.requestPhotos([_civic4]);
    cubit.cancelPending();
    cubit.requestPhotos([_civic4]);
    first.completeError(const CancelledFailure('cancelada'));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic4)], const PhotoLoading());
    second.complete(_photo);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic4)], const PhotoFound(_photo));
  });

  test('el resultado de un pedido viejo no sobrescribe al nuevo', () async {
    final first = Completer<PhotoEntity?>();
    final second = Completer<PhotoEntity?>();
    final completers = [first, second];
    stubResolve((model) => completers.removeAt(0).future);
    cubit.requestPhotos([_civic4]);
    cubit.cancelPending();
    cubit.requestPhotos([_civic4]);
    first.completeError(const NetworkFailure('sin red'));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic4)], const PhotoLoading());
    second.complete(null);
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.slots[key(_civic4)], const PhotoMissing());
  });

  test('cancelPending sin nada cargando no emite', () async {
    final emitted = <PhotosState>[];
    final subscription = cubit.stream.listen(emitted.add);
    cubit.cancelPending();
    await Future<void>.delayed(Duration.zero);
    expect(emitted, isEmpty);
    await subscription.cancel();
  });

  test('no emite después de close()', () async {
    final pending = Completer<PhotoEntity?>();
    stubResolve((model) => pending.future);
    cubit.requestPhotos([_civic4]);
    final emitted = <PhotosState>[];
    final subscription = cubit.stream.listen(emitted.add);
    await cubit.close();
    pending.complete(_photo);
    await Future<void>.delayed(Duration.zero);
    expect(emitted, isEmpty);
    await subscription.cancel();
  });
}
