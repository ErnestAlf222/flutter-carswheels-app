/// Mercado vigente para el comparador; lo implementa la capa app.
abstract class CompareMarketSource {
  /// Código del mercado activo ahora.
  String get marketCode;

  /// Emite el código cada vez que la persona cambia de mercado.
  Stream<String> get marketChanges;
}
