import 'package:cars_wheels_app/core/core.dart';

/// Respuesta de opciones de FuelEconomy: los ids de los vehículos.
class FuelEconomyOptionsModel {
  const FuelEconomyOptionsModel({required this.ids});

  /// Acepta menuItem como lista, objeto único o ausente; otra forma falla.
  factory FuelEconomyOptionsModel.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const ParsingFailure('El cuerpo de opciones no es un objeto JSON');
    }
    final rawItems = json[FuelEconomyConfig.menuItemKey];
    if (rawItems == null) return const FuelEconomyOptionsModel(ids: []);
    final items = rawItems is List<dynamic> ? rawItems : [rawItems];
    return FuelEconomyOptionsModel(
      ids: items.map(_readId).whereType<int>().toList(),
    );
  }

  final List<int> ids;

  // Lee el id de un item; ignora los no numéricos y falla si no es un objeto.
  static int? _readId(Object? item) {
    if (item is! Map<String, dynamic>) {
      throw const ParsingFailure('Un item de opciones no es un objeto JSON');
    }
    final value = item[VehicleSpecsConfig.menuValueKey];
    return value == null ? null : int.tryParse('$value');
  }
}
