import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/favorites/domain/domain.dart';

/// Qué dice el mensaje transitorio de favoritos.
enum FavoriteMessageKind {
  /// Se guardó un modelo.
  saved,

  /// Se quitó un modelo desde un corazón.
  removed,

  /// Se quitó desde Favoritos: lleva el nombre y la acción de deshacer.
  removedWithUndo,

  /// Se agregaron favoritos a la comparación; el sujeto es la cantidad.
  addedToCompare,
}

/// Estado de los favoritos a nivel de app.
sealed class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Se están leyendo los favoritos guardados.
class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

/// Lista ordenada del más reciente al más antiguo, con su conjunto de claves.
class FavoritesLoaded extends FavoritesState {
  FavoritesLoaded({
    required this.favorites,
    this.message,
    this.messageSubject,
    this.messageId = 0,
    this.sortMode = FavoriteSortMode.recent,
  }) : keys = {for (final favorite in favorites) favorite.key};

  final List<FavoriteEntity> favorites;

  /// Claves de identidad, para que cada corazón consulte su estado.
  final Set<String> keys;
  final FavoriteMessageKind? message;

  /// Nombre del modelo del mensaje, si lo lleva.
  final String? messageSubject;

  /// Cambia con cada mensaje nuevo, aunque sea el mismo texto.
  final int messageId;

  /// Orden elegido en Favoritos; se conserva durante la sesión.
  final FavoriteSortMode sortMode;

  bool isFavorite(String key) => keys.contains(key);

  FavoritesLoaded copyWith({
    List<FavoriteEntity>? favorites,
    FavoriteMessageKind? message,
    String? messageSubject,
    int? messageId,
    FavoriteSortMode? sortMode,
    bool clearMessage = false,
  }) => FavoritesLoaded(
    favorites: favorites ?? this.favorites,
    message: clearMessage ? null : message ?? this.message,
    messageSubject: clearMessage ? null : messageSubject ?? this.messageSubject,
    messageId: messageId ?? this.messageId,
    sortMode: sortMode ?? this.sortMode,
  );

  @override
  List<Object?> get props => [
    favorites,
    message,
    messageSubject,
    messageId,
    sortMode,
  ];
}
