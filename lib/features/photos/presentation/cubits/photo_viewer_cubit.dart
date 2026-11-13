import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/features/photos/presentation/cubits/photo_viewer_state.dart';

/// Guarda cuál foto se ve en el visor a pantalla completa.
class PhotoViewerCubit extends Cubit<PhotoViewerState> {
  PhotoViewerCubit({required int initialIndex, required this.photoCount})
    : super(PhotoViewerState(currentIndex: initialIndex));

  final int photoCount;

  /// Cambia la foto actual; ignora índices inválidos o repetidos.
  void selectPage(int index) {
    final isValid = index >= 0 && index < photoCount;
    if (!isValid || index == state.currentIndex) return;
    emit(PhotoViewerState(currentIndex: index));
  }
}
