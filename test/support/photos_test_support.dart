import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:mocktail/mocktail.dart';

/// Cubit de fotos falso para pruebas de widgets.
class MockPhotosCubit extends MockCubit<PhotosState> implements PhotosCubit {}

class _FakePhotoRequest extends Fake implements PhotoRequest {}

/// Prepara el cubit falso con la clave real y los espacios dados.
MockPhotosCubit buildMockPhotosCubit({
  Map<String, PhotoSlot> slots = const {},
}) {
  registerFallbackValue(_FakePhotoRequest());
  const keyBuilder = PhotoKeyBuilder(selector: PhotoCandidateSelector());
  final cubit = MockPhotosCubit();
  when(() => cubit.state).thenReturn(PhotosState(slots: slots));
  when(() => cubit.keyFor(any())).thenAnswer((invocation) {
    final request = invocation.positionalArguments.first as PhotoRequest;
    return keyBuilder.build(
      brand: request.brand,
      modelName: request.model,
      year: request.year,
    );
  });
  when(() => cubit.requestPhotos(any())).thenReturn(null);
  when(() => cubit.cancelPending()).thenReturn(null);
  return cubit;
}

/// Clave de foto de la marca, modelo y año dados.
String photoKeyFor(String brand, String model, int year) =>
    const PhotoKeyBuilder(selector: PhotoCandidateSelector())
        .build(brand: brand, modelName: model, year: year);
