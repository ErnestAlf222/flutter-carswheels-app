import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/features/detail/domain/domain.dart';
import 'package:cars_wheels_app/features/detail/presentation/cubits/gallery_state.dart';
import 'package:cars_wheels_app/features/photos/photos.dart';

/// Carga las fotos del modelo y guarda cuál se está viendo.
class DetailGalleryCubit extends Cubit<GalleryState> {
  DetailGalleryCubit(this.resolveGallery) : super(const GalleryState());

  final ResolveModelGalleryUseCase resolveGallery;

  // Marca de la última carga pedida; descarta los resultados de cargas viejas.
  final List<Object> _latestToken = [];

  /// Muestra al instante la foto de la lista y luego completa la galería.
  Future<void> load(DetailArgsEntity args) async {
    if (isClosed) return;
    final token = Object();
    _latestToken
      ..clear()
      ..add(token);
    final initial = args.photo;
    final initialPhotos = [?initial];
    emit(GalleryState(photos: initialPhotos, isLoading: true));
    final List<PhotoEntity> gallery;
    try {
      gallery = await resolveGallery(
        brand: args.brand,
        modelName: args.groupName,
        year: args.year,
      );
    } on Object {
      _emitIfLatest(token, GalleryState(photos: initialPhotos));
      return;
    }
    final extras = gallery.where(
      (photo) => initial == null || photo.sourceUrl != initial.sourceUrl,
    );
    _emitIfLatest(token, GalleryState(photos: [...initialPhotos, ...extras]));
  }

  /// Cambia la foto actual; ignora índices inválidos o repetidos.
  void selectPage(int index) {
    final isValid = index >= 0 && index < state.photos.length;
    if (!isValid || index == state.currentIndex) return;
    emit(
      GalleryState(
        photos: state.photos,
        currentIndex: index,
        isLoading: state.isLoading,
      ),
    );
  }

  void _emitIfLatest(Object token, GalleryState result) {
    final isLatest = _latestToken.isNotEmpty && _latestToken.first == token;
    if (isClosed || !isLatest) return;
    emit(result);
  }
}
