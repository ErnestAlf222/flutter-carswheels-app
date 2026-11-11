import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';
import 'package:cars_wheels_app/features/brand_logos/infrastructure/mappers/brand_logos_mapper.dart';

/// Repositorio de logos que consulta el manifiesto una sola vez con éxito.
class BrandLogosRepositoryImpl implements BrandLogosRepository {
  BrandLogosRepositoryImpl(this._datasource);

  final BrandLogosDatasource _datasource;
  // Se llena en la primera consulta exitosa; si falla, se reintenta.
  final Map<String, String> _cachedUrls = {};

  @override
  Future<Map<String, String>> getLogoUrlsByBrand() async {
    if (_cachedUrls.isEmpty) {
      final manifest = await _datasource.fetchManifest();
      _cachedUrls.addAll(BrandLogosMapper.toLogoUrls(manifest));
    }
    return Map.unmodifiable(_cachedUrls);
  }
}
