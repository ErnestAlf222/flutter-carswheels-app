/// Texto de logos y manifiesto guardado en disco; la capa de datos lo implementa.
abstract class LogoFileStore {
  /// Contenido del archivo; nulo si no existe o es ilegible (se descarta).
  Future<String?> read(String fileName);

  /// Guarda el texto; no hace nada si pasa del tamaño máximo por archivo.
  Future<void> write(String fileName, String content);

  /// Borra un archivo que resultó inválido; sin efecto si no existe.
  Future<void> discard(String fileName);
}
