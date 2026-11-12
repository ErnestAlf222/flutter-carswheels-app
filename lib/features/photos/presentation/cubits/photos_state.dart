import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/photos/presentation/cubits/photo_slot.dart';

/// Fotos de los modelos por clave de foto.
class PhotosState extends Equatable {
  const PhotosState({this.slots = const {}});

  final Map<String, PhotoSlot> slots;

  /// Copia con los espacios dados reemplazando a los de su clave.
  PhotosState withSlots(Map<String, PhotoSlot> changes) =>
      PhotosState(slots: {...slots, ...changes});

  @override
  List<Object?> get props => [slots];
}
