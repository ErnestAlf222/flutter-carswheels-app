import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';
import 'package:cars_wheels_app/features/brand_logos/infrastructure/mappers/brand_logos_mapper.dart';
import 'package:cars_wheels_app/features/brand_logos/infrastructure/models/brand_logos_manifest_model.dart';

/// Repositorio de logos que consulta el manifiesto una sola vez con éxito.
///
/// El manifiesto es de una versión fijada y no cambia: si está en disco no se
/// pide a la red, y así los logos aparecen también sin conexión.
class BrandLogosRepositoryImpl implements BrandLogosRepository {
  BrandLogosRepositoryImpl(
    this._datasource, {
    this._store,
    this._namer = const LogoFileNamer(),
  });

  final BrandLogosDatasource _datasource;
  final LogoFileStore? _store;
  final LogoFileNamer _namer;
  // Se llena en la primera consulta exitosa; si falla, se reintenta.
  final Map<String, String> _cachedUrls = {};

  @override
  Future<Map<String, String>> getLogoUrlsByBrand() async {
    if (_cachedUrls.isEmpty) {
      final manifest =
          await _readSavedManifest() ?? await _fetchAndSaveManifest();
      _cachedUrls.addAll(BrandLogosMapper.toLogoUrls(manifest));
    }
    return Map.unmodifiable(_cachedUrls);
  }

  String? get _manifestName =>
      _namer.manifestFileNameFor(LogosConfig.logosBaseUrl);

  // Manifiesto guardado; uno ilegible se descarta y se pide de nuevo.
  Future<Map<String, String>?> _readSavedManifest() async {
    final store = _store;
    final name = _manifestName;
    if (store == null || name == null) return null;
    final saved = await store.read(name);
    if (saved == null) return null;
    try {
      final manifest = BrandLogosManifestModel.fromJson(jsonDecode(saved))
          .fileNamesByBrand;
      if (manifest.isNotEmpty) return manifest;
    } on Object {
      // Cae al descarte de abajo.
    }
    await store.discard(name);
    return null;
  }

  Future<Map<String, String>> _fetchAndSaveManifest() async {
    final manifest = await _datasource.fetchManifest();
    final store = _store;
    final name = _manifestName;
    if (store != null && name != null && manifest.isNotEmpty) {
      await store.write(name, jsonEncode(manifest));
    }
    return manifest;
  }
}
