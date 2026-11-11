/// Fuente de datos del manifiesto de logos.
abstract class BrandLogosDatasource {
  /// Nombre de marca → nombre de archivo del logo.
  Future<Map<String, String>> fetchManifest();
}
