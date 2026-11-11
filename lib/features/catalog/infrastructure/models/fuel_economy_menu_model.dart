import 'package:cars_wheels_app/core/core.dart';

/// Respuesta de menú de FuelEconomy: los textos de sus items.
class FuelEconomyMenuModel {
  const FuelEconomyMenuModel({required this.itemTexts});

  /// Acepta menuItem como lista, objeto único o ausente; otra forma falla.
  factory FuelEconomyMenuModel.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const ParsingFailure('El cuerpo del menú no es un objeto JSON');
    }
    final rawItems = json[FuelEconomyConfig.menuItemKey];
    if (rawItems == null) return const FuelEconomyMenuModel(itemTexts: []);
    if (rawItems is List<dynamic>) {
      return FuelEconomyMenuModel(itemTexts: rawItems.map(_readText).toList());
    }
    return FuelEconomyMenuModel(itemTexts: [_readText(rawItems)]);
  }

  final List<String> itemTexts;

  // Lee el texto de un item o falla si no tiene la forma esperada.
  static String _readText(Object? item) {
    if (item is Map<String, dynamic>) {
      final text = item[FuelEconomyConfig.itemTextKey];
      if (text is String) return text;
    }
    throw const ParsingFailure('Un item del menú no tiene texto válido');
  }
}
