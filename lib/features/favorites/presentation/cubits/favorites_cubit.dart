import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cars_wheels_app/core/config/favorites_config.dart';
import 'package:cars_wheels_app/features/favorites/domain/domain.dart';
import 'package:cars_wheels_app/features/favorites/presentation/cubits/favorites_state.dart';

/// Favoritos de la app; vive a nivel de app para que cualquier corazón lo consulte.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit({
    required this.observeFavorites,
    required this.getFavorites,
    required this.toggleFavorite,
    required this.removeFavorite,
    required this.restoreFavorite,
    required this.completeSnapshot,
    required this.snapshotSource,
    this.clock = DateTime.now,
    this.messageDuration = const Duration(
      milliseconds: FavoritesConfig.messageDurationMilliseconds,
    ),
    this.undoDuration = const Duration(
      milliseconds: FavoritesConfig.undoDurationMilliseconds,
    ),
  }) : super(const FavoritesLoading()) {
    _subscription = observeFavorites().listen(
      _onFavorites,
      // Sin lectura posible la pantalla sigue con la lista vacía.
      onError: (Object _) => _onFavorites(const []),
    );
  }

  final ObserveFavoritesUseCase observeFavorites;
  final GetFavoritesUseCase getFavorites;
  final ToggleFavoriteUseCase toggleFavorite;
  final RemoveFavoriteUseCase removeFavorite;
  final RestoreFavoriteUseCase restoreFavorite;
  final CompleteFavoriteSnapshotUseCase completeSnapshot;
  final FavoriteSnapshotSource snapshotSource;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;
  final Duration messageDuration;
  final Duration undoDuration;

  // Recursos cancelables y el último favorito quitado, para "Deshacer".
  StreamSubscription<List<FavoriteEntity>>? _subscription;
  Timer? _messageTimer;
  FavoriteEntity? _lastRemoved;

  // Últimas instantáneas conocidas por clave: al volver a guardar un modelo que se
  // quitó no se pierden sus datos aunque ahora no se puedan resolver (otro mercado).
  final Map<String, FavoriteSnapshotEntity> _knownSnapshots = {};

  // Escrituras en curso: mientras hay alguna, los eventos del disco se ignoran.
  final Set<Object> _writing = {};

  List<FavoriteEntity> get _current {
    final state = this.state;
    return state is FavoritesLoaded ? state.favorites : const [];
  }

  /// Alterna el favorito de un modelo; el corazón responde sin esperar al disco.
  Future<void> toggle(
    FavoriteIdentity identity, {
    FavoriteSnapshotEntity initialSnapshot = FavoriteSnapshotEntity.empty,
  }) async {
    final existing = _current
        .where((favorite) => favorite.key == identity.key)
        .firstOrNull;
    final adding = existing == null;
    if (existing != null) _knownSnapshots[identity.key] = existing.snapshot;
    final known = _knownSnapshots[identity.key];
    final seed = known != null && !known.isEmpty ? known : initialSnapshot;
    _emitList(
      adding
          ? [
              FavoriteEntity(
                identity: identity,
                savedAt: clock(),
                snapshot: seed,
              ),
              ..._current,
            ]
          : [
              for (final favorite in _current)
                if (favorite.key != identity.key) favorite,
            ],
    );
    final result = await _write(
      () => toggleFavorite(identity, initialSnapshot: seed),
    );
    if (isClosed) return;
    switch (result) {
      case FavoriteAdded():
        _showMessage(FavoriteMessageKind.saved, messageDuration);
        unawaited(_completeSnapshot(result.favorite));
      case FavoriteRemoved():
        _showMessage(FavoriteMessageKind.removed, messageDuration);
    }
  }

  /// Quita un favorito desde Favoritos, con "Deshacer" durante unos segundos.
  Future<void> remove(FavoriteEntity favorite) async {
    _lastRemoved = favorite;
    _emitList([
      for (final item in _current)
        if (item.key != favorite.key) item,
    ]);
    _showMessage(
      FavoriteMessageKind.removedWithUndo,
      undoDuration,
      subject: favorite.modelName,
    );
    await _write(() => removeFavorite(favorite.key));
  }

  /// Devuelve el último favorito quitado a su posición.
  Future<void> undo() async {
    final favorite = _lastRemoved;
    if (favorite == null) return;
    _lastRemoved = null;
    _emitList(
      ObserveFavoritesUseCase.sortRecent([
        for (final item in _current)
          if (item.key != favorite.key) item,
        favorite,
      ]),
    );
    dismissMessage();
    await _write(() => restoreFavorite(favorite));
  }

  /// Oculta el mensaje antes de que venza.
  void dismissMessage() {
    _messageTimer?.cancel();
    final current = state;
    if (isClosed || current is! FavoritesLoaded || current.message == null) {
      return;
    }
    emit(current.copyWith(clearMessage: true));
  }

  Future<void> _completeSnapshot(FavoriteEntity favorite) async {
    try {
      final snapshot = await snapshotSource.snapshotOf(favorite.identity);
      if (isClosed || snapshot == null || snapshot.isEmpty) return;
      await completeSnapshot(
        favorite.key,
        snapshot.withVariantsIfMissing(favorite.snapshot.variantNames),
      );
    } on Object {
      // Si no se resuelve, la tarjeta se queda con lo que ya hay: sin inventar.
    }
  }

  // Corre una escritura; al terminar la última se alinea con lo guardado.
  Future<T> _write<T>(Future<T> Function() action) async {
    final token = Object();
    _writing.add(token);
    try {
      return await action();
    } finally {
      _writing.remove(token);
      if (_writing.isEmpty && !isClosed) await _resync();
    }
  }

  Future<void> _resync() async {
    try {
      _onFavorites(await getFavorites());
    } on Object {
      // Sin lectura se queda con lo que ya muestra.
    }
  }

  void _onFavorites(List<FavoriteEntity> favorites) {
    if (isClosed || _writing.isNotEmpty) return;
    final current = state;
    emit(
      current is FavoritesLoaded
          ? current.copyWith(favorites: favorites)
          : FavoritesLoaded(favorites: favorites),
    );
  }

  void _emitList(List<FavoriteEntity> favorites) {
    final current = state;
    emit(
      current is FavoritesLoaded
          ? current.copyWith(favorites: favorites)
          : FavoritesLoaded(favorites: favorites),
    );
  }

  void _showMessage(
    FavoriteMessageKind kind,
    Duration duration, {
    String? subject,
  }) {
    final current = state;
    final previousId = current is FavoritesLoaded ? current.messageId : 0;
    final list = current is FavoritesLoaded ? current.favorites : const [];
    emit(
      FavoritesLoaded(
        favorites: [...list],
        message: kind,
        messageSubject: subject,
        messageId: previousId + 1,
      ),
    );
    _messageTimer?.cancel();
    _messageTimer = Timer(duration, dismissMessage);
  }

  @override
  Future<void> close() async {
    _messageTimer?.cancel();
    await _subscription?.cancel();
    return super.close();
  }
}
