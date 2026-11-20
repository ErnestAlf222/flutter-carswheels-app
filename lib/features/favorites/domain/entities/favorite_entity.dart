import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_identity.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_snapshot_entity.dart';

/// Un modelo guardado: su identidad, cuándo se guardó y su instantánea.
class FavoriteEntity extends Equatable {
  const FavoriteEntity({
    required this.identity,
    required this.savedAt,
    this.snapshot = FavoriteSnapshotEntity.empty,
  });

  final FavoriteIdentity identity;
  final DateTime savedAt;
  final FavoriteSnapshotEntity snapshot;

  String get key => identity.key;
  String get marketCode => identity.marketCode;
  int get year => identity.year;
  String get brand => identity.brand;
  String get modelName => identity.modelName;

  /// Copia con otra instantánea; la identidad y la fecha se conservan.
  FavoriteEntity withSnapshot(FavoriteSnapshotEntity snapshot) =>
      FavoriteEntity(identity: identity, savedAt: savedAt, snapshot: snapshot);

  @override
  List<Object?> get props => [identity, savedAt, snapshot];
}
