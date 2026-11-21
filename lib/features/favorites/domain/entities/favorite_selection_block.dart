/// Por qué un favorito no se puede elegir para comparar.
enum FavoriteSelectionBlock {
  /// Se puede elegir.
  none,

  /// Ya hay elegidos de otro mercado: la comparación es por mercado.
  otherMarket,

  /// La comparación de su mercado ya está llena.
  noCapacity,

  /// Ya se eligió todo lo que cabe en la comparación de su mercado.
  limitReached,
}
