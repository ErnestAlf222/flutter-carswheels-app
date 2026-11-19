import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/datasources/commons_logo_cache_datasource.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/datasources/commons_logo_datasource.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/entities/cached_commons_logo_entity.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/entities/commons_logo_entity.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/services/commons_logo_selector.dart';

/// Resuelve el logo de respaldo de una marca: caché primero, luego Commons.
class ResolveCommonsLogoUseCase {
  const ResolveCommonsLogoUseCase({
    required this.cache,
    required this.datasource,
    required this.selector,
    required this.clock,
  });

  final CommonsLogoCacheDatasource cache;
  final CommonsLogoDatasource datasource;
  final CommonsLogoSelector selector;

  /// Reloj inyectado para controlar el tiempo en las pruebas.
  final DateTime Function() clock;

  /// Nulo si no hay logo aceptable; con la red caída relanza y no guarda nada.
  Future<CommonsLogoEntity?> call(String brandName) async {
    final key = _keyFor(brandName);
    final cached = await cache.read(key);
    if (cached != null && _isFresh(cached)) return cached.logo;
    try {
      final candidates = await datasource.searchLogos(brandName);
      final logo = selector.select(brandName, candidates);
      await cache.write(
        key,
        CachedCommonsLogoEntity(logo: logo, savedAt: clock()),
      );
      return logo;
    } on AppFailure {
      // Con la red caída sirve un logo vencido si lo hay.
      if (cached != null && !cached.isMiss) return cached.logo;
      rethrow;
    }
  }

  String _keyFor(String brandName) => [
    LogosConfig.commonsLogoCacheKeyVersion,
    LogosConfig.commonsLogoCacheKeyTag,
    TextNormalizer.normalize(brandName),
  ].join(LogosConfig.commonsLogoCacheKeySeparator);

  bool _isFresh(CachedCommonsLogoEntity entry) {
    final days = entry.isMiss
        ? LogosConfig.commonsLogoMissTimeToLiveDays
        : LogosConfig.commonsLogoTimeToLiveDays;
    return clock().difference(entry.savedAt) < Duration(days: days);
  }
}
