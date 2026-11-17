import 'package:cars_wheels_app/core/core.dart';

/// Empareja un modelo con los nombres de NHTSA: solo igualdad exacta o alias.
class NhtsaModelMatcher {
  const NhtsaModelMatcher({this.aliases = SafetyConfig.modelAliases});

  /// Alias por "marca|modelo" normalizados hacia nombres de NHTSA.
  final Map<String, List<String>> aliases;

  /// Nombres de NHTSA que corresponden al modelo; vacío si no se empareja.
  List<String> match(String make, String model, List<String> candidates) {
    final target = TextNormalizer.normalize(model);
    final exact = _withNormalizedName(candidates, {target});
    if (exact.isNotEmpty) return exact;
    final aliasKey = [
      TextNormalizer.normalize(make),
      target,
    ].join(SafetyConfig.aliasKeySeparator);
    final aliasNames = aliases[aliasKey];
    if (aliasNames == null) return const [];
    return _withNormalizedName(candidates, {
      for (final name in aliasNames) TextNormalizer.normalize(name),
    });
  }

  // Sin repetidos, en el orden de la API.
  List<String> _withNormalizedName(
    List<String> candidates,
    Set<String> normalizedNames,
  ) {
    final found = <String>[];
    for (final candidate in candidates) {
      final isMatch = normalizedNames.contains(
        TextNormalizer.normalize(candidate),
      );
      if (isMatch && !found.contains(candidate)) found.add(candidate);
    }
    return found;
  }
}
