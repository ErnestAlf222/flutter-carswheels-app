import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_model_group_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_vehicle_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_version_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/services/mx_model_name_cleaner.dart';

// Nombre base de un modelo y si pertenece a una familia protegida o absorbente.
typedef _BaseName = ({List<String> words, bool isProtected});

/// Agrupa las filas de una marca por prefijo de palabras completas del nombre limpio.
///
/// Sigue las reglas de ModelGrouper (nombre base más corto, familias protegidas,
/// bases absorbentes) pero con las tablas de México: ModelGrouper lee estáticamente
/// las de FuelEconomy y trabaja con ModelEntity.
class MxModelGrouper {
  const MxModelGrouper({this.cleaner = const MxModelNameCleaner()});

  final MxModelNameCleaner cleaner;

  /// Agrupa las filas de una marca y ordena los grupos por nombre.
  List<MxModelGroupEntity> group(String brand, List<MxVehicleEntity> vehicles) {
    final brandKey = TextNormalizer.normalize(brand);
    final bases = [
      for (final vehicle in vehicles) _baseName(vehicle.model, brandKey),
    ];
    final candidates = <String, List<String>>{
      for (final base in bases) _key(base.words): base.words,
    };
    final membersByRoot = <String, List<MxVersionEntity>>{};
    for (int index = 0; index < vehicles.length; index++) {
      final base = bases[index];
      final root = base.isProtected
          ? _key(base.words)
          : _shortestPrefixKey(base.words, candidates);
      final vehicle = vehicles[index];
      membersByRoot
          .putIfAbsent(root, () => [])
          .add(
            MxVersionEntity(
              label: cleaner.stripBrandPrefix(brand, vehicle.rawModel),
              vehicle: vehicle,
            ),
          );
    }
    final groups =
        [
          for (final entry in membersByRoot.entries)
            MxModelGroupEntity(
              name: candidates[entry.key]!.join(' '),
              versions: entry.value,
            ),
        ]..sort((a, b) {
          final byKey = _key(_split(a.name)).compareTo(_key(_split(b.name)));
          return byKey != 0 ? byKey : a.name.compareTo(b.name);
        });
    return groups;
  }

  // Llave de comparación: cada palabra normalizada, separadas por un espacio.
  static String _key(List<String> words) =>
      words.map(TextNormalizer.normalize).join(' ');

  static List<String> _split(String text) => text
      .split(RegExp(MexicoModelConfig.wordSeparatorPattern))
      .where((word) => word.isNotEmpty)
      .toList();

  // Aplica las bases absorbentes y las familias protegidas al nombre limpio.
  static _BaseName _baseName(String model, String brandKey) {
    final words = _split(model);
    if (words.isEmpty) return (words: [model], isProtected: false);
    final absorbing = _longestPrefix(
      words,
      MexicoModelConfig.absorbingModelBases[brandKey],
    );
    if (absorbing != null) return (words: absorbing, isProtected: true);
    final family = _longestPrefix(
      words,
      MexicoModelConfig.protectedModelFamilies[brandKey],
    );
    return family == null
        ? (words: words, isProtected: false)
        : (words: family, isProtected: true);
  }

  // La entrada de la tabla más larga con la que empieza el nombre, si hay alguna.
  static List<String>? _longestPrefix(List<String> words, List<String>? table) {
    if (table == null) return null;
    final wordsKey = _key(words);
    final matches =
        [
          for (final entry in table.map(_split))
            if (_isWordPrefix(_key(entry), wordsKey)) entry,
        ]..sort((a, b) {
          final byLength = b.length.compareTo(a.length);
          return byLength != 0 ? byLength : a.join(' ').compareTo(b.join(' '));
        });
    return matches.isEmpty ? null : matches.first;
  }

  // Llave del nombre base más corto que es prefijo por palabras completas.
  static String _shortestPrefixKey(
    List<String> words,
    Map<String, List<String>> candidates,
  ) {
    final wordsKey = _key(words);
    final prefixes =
        [
          for (final key in candidates.keys)
            if (_isWordPrefix(key, wordsKey)) key,
        ]..sort((a, b) {
          final byWords = a.split(' ').length.compareTo(b.split(' ').length);
          return byWords != 0 ? byWords : a.compareTo(b);
        });
    return prefixes.first;
  }

  // Verdadero si prefix es igual a key o la abre seguido de una palabra nueva.
  static bool _isWordPrefix(String prefix, String key) =>
      key == prefix || key.startsWith('$prefix ');
}
