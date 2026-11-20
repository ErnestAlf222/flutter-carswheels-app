import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Resúmenes que se llenan desde la instantánea guardada, sin pedir nada a la red.
class SnapshotSummariesCubit extends SummariesCubit {
  SnapshotSummariesCubit({
    required super.resolveGroupSummary,
    required super.cancelPendingSummaries,
    required super.keyBuilder,
  });

  /// Coloca los espacios dados como si ya se hubieran resuelto.
  void seed(Map<String, SummarySlot> slots) => emit(state.withSlots(slots));
}

/// Fotos que se llenan desde la instantánea guardada, sin pedir nada a la red.
class SnapshotPhotosCubit extends PhotosCubit {
  SnapshotPhotosCubit({
    required super.resolveModelPhoto,
    required super.cancelPendingPhotos,
    required super.keyBuilder,
  });

  /// Coloca los espacios dados como si ya se hubieran resuelto.
  void seed(Map<String, PhotoSlot> slots) => emit(state.withSlots(slots));
}

/// Crea los cubits de las tarjetas de Favoritos; los entrega la capa app.
class FavoriteCardCubitsFactory {
  const FavoriteCardCubitsFactory({
    required this.createPhotos,
    required this.createSummaries,
  });

  final SnapshotPhotosCubit Function() createPhotos;
  final SnapshotSummariesCubit Function() createSummaries;
}
