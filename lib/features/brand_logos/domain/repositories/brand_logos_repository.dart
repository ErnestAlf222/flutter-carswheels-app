/// Acceso a las URLs de los logos de marcas.
abstract class BrandLogosRepository {
  /// Nombre de marca normalizado → URL completa del logo.
  Future<Map<String, String>> getLogoUrlsByBrand();
}
