import 'package:cars_wheels_app/core/core.dart';

/// Convierte el manifiesto en URLs completas por marca normalizada.
class BrandLogosMapper {
  const BrandLogosMapper._();

  static Map<String, String> toLogoUrls(Map<String, String> fileNamesByBrand) =>
      {
        for (final entry in fileNamesByBrand.entries)
          TextNormalizer.normalize(entry.key):
              '${LogosConfig.logosBaseUrl}${entry.value}',
      };
}
