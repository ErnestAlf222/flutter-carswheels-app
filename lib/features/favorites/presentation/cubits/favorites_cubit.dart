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
    this.attachPhoto,
    this.deletePhoto,
    this.measurePhoto,
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

  /// Foto local de cada favorito; sin ellos solo queda la referencia de red.
  final AttachFavoritePhotoUseCase? attachPhoto;
  final DeleteFavoritePhotoUseCase? deletePhoto;

  /// Completa el tamaño de las fotos guardadas antes de medirlas.
  final MeasureFavoritePhotoUseCase? measurePhoto;

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

  // Favoritos cuya foto ya se intentó medir: una sola vez por sesión.
  final Set<String> _measured = {};

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
    if (existing != null) {
      // El archivo local se borra al quitarlo: se recuerda solo la referencia.
      final photo = existing.snapshot.photo;
      _knownSnapshots[identity.key] = existing.snapshot.withPhoto(
        photo?.withLocalFileName(null),
      );
    }
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
        unawaited(_completeAndAttach(result.favorite));
      case FavoriteRemoved():
        _showMessage(FavoriteMessageKind.removed, messageDuration);
        // Sin "Deshacer": el archivo de su foto ya no hace falta.
        unawaited(_discardPhotoOf(result.favorite));
    }
  }

  /// Quita un favorito desde Favoritos, con "Deshacer" durante unos segundos.
  Future<void> remove(FavoriteEntity favorite) async {
    // Un favorito quitado antes ya no se puede deshacer: su foto se borra.
    _commitRemoval();
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

  /// Cambia el orden de la lista; se conserva mientras la app siga abierta.
  void setSortMode(FavoriteSortMode mode) {
    final current = state;
    if (current is! FavoritesLoaded || current.sortMode == mode) return;
    emit(current.copyWith(sortMode: mode));
  }

  /// Oculta el mensaje antes de que venza.
  void dismissMessage() {
    _messageTimer?.cancel();
    // Sin el mensaje ya no se puede deshacer: la foto del favorito se borra.
    _commitRemoval();
    final current = state;
    if (isClosed || current is! FavoritesLoaded || current.message == null) {
      return;
    }
    emit(current.copyWith(clearMessage: true));
  }

  // Pasó el plazo de "Deshacer": el archivo de la foto del favorito se borra.
  void _commitRemoval() {
    final removed = _lastRemoved;
    _lastRemoved = null;
    if (removed != null) unawaited(_discardPhotoOf(removed));
  }

  Future<void> _discardPhotoOf(FavoriteEntity favorite) async {
    try {
      await deletePhoto?.call(favorite);
    } on Object {
      // Si no se pudo borrar ahora, la limpieza de huérfanos lo hará al iniciar.
    }
  }

  // Completa la instantánea y después baja la foto, sin bloquear el corazón.
  Future<void> _completeAndAttach(FavoriteEntity favorite) async {
    await _completeSnapshot(favorite);
    if (isClosed) return;
    try {
      await attachPhoto?.call(favorite.key);
    } on Object {
      // Sin descarga queda la referencia de red: la tarjeta sigue igual.
    }
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
    _measurePending(favorites);
  }

  // Mide, sin bloquear, las fotos locales que aún no tienen tamaño.
  void _measurePending(List<FavoriteEntity> favorites) {
    final measure = measurePhoto;
    if (measure == null) return;
    for (final favorite in favorites) {
      final photo = favorite.snapshot.photo;
      if (photo == null ||
          photo.localFileName == null ||
          photo.hasDimensions ||
          !_measured.add(favorite.key)) {
        continue;
      }
      unawaited(_measureOne(measure, favorite.key));
    }
  }

  Future<void> _measureOne(
    MeasureFavoritePhotoUseCase measure,
    String key,
  ) async {
    try {
      await measure(key);
    } on Object {
      // Sin tamaño la tarjeta usa la proporción por defecto.
    }
  }

  /// Avisa que se agregaron [count] autos a la comparación.
  void announceAddedToCompare(int count) {
    _showMessage(
      FavoriteMessageKind.addedToCompare,
      messageDuration,
      subject: '$count',
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
    // Otro mensaje tapa el "Deshacer" pendiente: ya no hay vuelta atrás.
    if (kind != FavoriteMessageKind.removedWithUndo) _commitRemoval();
    final current = state;
    final previousId = current is FavoritesLoaded ? current.messageId : 0;
    final list = current is FavoritesLoaded ? current.favorites : const [];
    emit(
      FavoritesLoaded(
        favorites: [...list],
        message: kind,
        messageSubject: subject,
        messageId: previousId + 1,
        sortMode: current is FavoritesLoaded
            ? current.sortMode
            : FavoriteSortMode.recent,
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
