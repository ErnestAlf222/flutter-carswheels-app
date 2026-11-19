/// Guarda el código del último mercado elegido.
abstract class MarketPreferenceDatasource {
  /// Nulo si todavía no se ha guardado ninguno.
  Future<String?> read();

  Future<void> write(String code);
}
