import 'package:cars_wheels_app/core/core.dart';

/// Una opción de FuelEconomy: id numérico del vehículo y su texto.
typedef FuelEconomyOptionItem = ({int id, String text});

/// Respuesta de opciones de FuelEconomy: los vehículos con su id y texto.
class FuelEconomyOptionsModel {
  const FuelEconomyOptionsModel({required this.items});

  /// Acepta menuItem como lista, objeto único o ausente; otra forma falla.
  factory FuelEconomyOptionsModel.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const ParsingFailure('El cuerpo de opciones no es un objeto JSON');
    }
    final rawItems = json[FuelEconomyConfig.menuItemKey];
    if (rawItems == null) return const FuelEconomyOptionsModel(items: []);
    final items = rawItems is List<dynamic> ? rawItems : [rawItems];
    return FuelEconomyOptionsModel(
      items: items.map(_readItem).whereType<FuelEconomyOptionItem>().toList(),
    );
  }

  final List<FuelEconomyOptionItem> items;

  /// Solo los ids, en el orden de la API.
  List<int> get ids => [for (final item in items) item.id];

  // Lee un item; ignora los de id no numérico y falla si no es un objeto.
  static FuelEconomyOptionItem? _readItem(Object? item) {
    if (item is! Map<String, dynamic>) {
      throw const ParsingFailure('Un item de opciones no es un objeto JSON');
    }
    final value = item[VehicleSpecsConfig.menuValueKey];
    final id = value == null ? null : int.tryParse('$value');
    if (id == null) return null;
    final text = item[FuelEconomyConfig.itemTextKey];
    return (id: id, text: text == null ? '' : '$text');
  }
}
