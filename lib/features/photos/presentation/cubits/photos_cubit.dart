import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/domain.dart';
import 'package:cars_wheels_app/features/photos/presentation/cubits/photo_request.dart';
import 'package:cars_wheels_app/features/photos/presentation/cubits/photo_slot.dart';
import 'package:cars_wheels_app/features/photos/presentation/cubits/photos_state.dart';

/// Pide las fotos de los modelos y guarda el resultado de cada una.
class PhotosCubit extends Cubit<PhotosState> {
  PhotosCubit({
    required this.resolveModelPhoto,
    required this.cancelPendingPhotos,
    required this.keyBuilder,
  }) : super(const PhotosState());

  final ResolveModelPhotoUseCase resolveModelPhoto;
  final CancelPendingPhotosUseCase cancelPendingPhotos;
  final PhotoKeyBuilder keyBuilder;

  // Marca del último pedido por clave; descarta resultados de pedidos viejos.
  final Map<String, Object> _latestRequestByKey = {};

  /// Clave de foto de un pedido.
  String keyFor(PhotoRequest request) => keyBuilder.build(
    brand: request.brand,
    modelName: request.model,
    year: request.year,
  );

  /// Pide en orden las fotos que no están, sin esperar una por una.
  void requestPhotos(List<PhotoRequest> requests) {
    final toResolve = <String, PhotoRequest>{};
    for (final request in requests) {
      final key = keyFor(request);
      if (toResolve.containsKey(key)) continue;
      final slot = state.slots[key];
      if (slot == null || slot is PhotoFailed) toResolve[key] = request;
    }
    if (toResolve.isEmpty) return;
    emit(
      state.withSlots({
        for (final key in toResolve.keys) key: const PhotoLoading(),
      }),
    );
    for (final entry in toResolve.entries) {
      _resolve(entry.key, entry.value);
    }
  }

  /// Cancela lo pendiente; lo que seguía cargando queda listo para pedirse de nuevo.
  void cancelPending() {
    cancelPendingPhotos();
    final cancelled = <String, PhotoSlot>{
      for (final entry in state.slots.entries)
        if (entry.value is PhotoLoading) entry.key: const PhotoFailed(),
    };
    if (cancelled.isEmpty) return;
    emit(state.withSlots(cancelled));
  }

  // Lanza la resolución y emite su resultado si sigue siendo el pedido vigente.
  Future<void> _resolve(String key, PhotoRequest request) async {
    final requestToken = Object();
    _latestRequestByKey[key] = requestToken;
    final PhotoSlot result;
    try {
      final photo = await resolveModelPhoto(
        brand: request.brand,
        modelName: request.model,
        year: request.year,
      );
      result = photo == null ? const PhotoMissing() : PhotoFound(photo);
    } on CancelledFailure {
      // Cancelada a propósito: cancelPending ya dejó el espacio como fallido.
      return;
    } catch (_) {
      _emitResult(key, requestToken, const PhotoFailed());
      return;
    }
    _emitResult(key, requestToken, result);
  }

  void _emitResult(String key, Object requestToken, PhotoSlot result) {
    if (isClosed || _latestRequestByKey[key] != requestToken) return;
    emit(state.withSlots({key: result}));
  }
}
