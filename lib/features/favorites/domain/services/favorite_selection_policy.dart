import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_entity.dart';
import 'package:cars_wheels_app/features/favorites/domain/entities/favorite_selection_block.dart';

/// Reglas para elegir favoritos y compararlos: un solo mercado y la capacidad restante.
class FavoriteSelectionPolicy {
  const FavoriteSelectionPolicy({this.remainingByMarket = const {}});

  /// Cuántos autos más caben en la comparación de cada mercado; sin dato, todos.
  final Map<String, int> remainingByMarket;

  /// Lugares libres en la comparación del mercado.
  int remaining(String marketCode) =>
      remainingByMarket[marketCode] ?? CompareConfig.maxSlots;

  /// Mercado de lo elegido: el del primero; nulo si no hay nada elegido.
  String? lockedMarket(List<FavoriteEntity> selected) =>
      selected.isEmpty ? null : selected.first.marketCode;

  /// Qué impide elegir [candidate] estando ya elegidos [selected].
  FavoriteSelectionBlock blockFor(
    FavoriteEntity candidate,
    List<FavoriteEntity> selected,
  ) {
    final locked = lockedMarket(selected);
    if (locked != null && locked != candidate.marketCode) {
      return FavoriteSelectionBlock.otherMarket;
    }
    final free = remaining(candidate.marketCode);
    if (free <= 0) return FavoriteSelectionBlock.noCapacity;
    if (selected.length >= free) return FavoriteSelectionBlock.limitReached;
    return FavoriteSelectionBlock.none;
  }

  /// Con al menos un auto elegido ya se puede pulsar "Comparar".
  bool canCompare(List<FavoriteEntity> selected) => selected.isNotEmpty;

  /// Verdadero si, con lo ya agregado, la comparación aún no llega al mínimo para mostrarse.
  bool needsMoreCars(List<FavoriteEntity> selected) {
    final locked = lockedMarket(selected);
    if (locked == null) return false;
    final alreadyThere = CompareConfig.maxSlots - remaining(locked);
    return alreadyThere + selected.length < CompareConfig.minSlots;
  }
}
