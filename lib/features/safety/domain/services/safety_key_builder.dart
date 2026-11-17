import 'package:cars_wheels_app/core/core.dart';

/// Arma las claves de caché de seguridad de un grupo.
class SafetyKeyBuilder {
  const SafetyKeyBuilder();

  String build(String kind, int year, String make, String model) {
    return [
      SafetyConfig.cacheKeyVersion,
      kind,
      '$year',
      TextNormalizer.normalize(make),
      TextNormalizer.normalize(model),
    ].join(SafetyConfig.cacheKeySeparator);
  }
}
