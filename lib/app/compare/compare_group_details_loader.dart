import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/market/market.dart';

/// Carga las versiones de un vehículo del comparador con los casos de uso de
/// Detalle y del catálogo, para reutilizar sus cachés.
///
/// Recuerda en memoria las versiones de cada vehículo mientras la app vive:
/// pedirlas otra vez (otra columna, la hoja de versiones, volver a la pantalla)
/// no repite las peticiones de catálogo, que Detalle no guarda en disco.
class CompareGroupDetailsLoader {
  CompareGroupDetailsLoader({
    required this.getModelGroups,
    required this.loadGroupDetails,
    required this.currentMarket,
  });

  final GetModelGroupsUseCase getModelGroups;
  final LoadGroupDetailsUseCase loadGroupDetails;
  final Market Function() currentMarket;

  // Cargas en curso o terminadas, por vehículo; las fallas se olvidan.
  final Map<String, Future<GroupDetailsEntity>> _loads = {};

  /// Nulo si el vehículo no es del mercado vigente; lanza si la carga falla.
  Future<GroupDetailsEntity?> load(CompareSlotEntity slot) async {
    final market = Market.fromCode(slot.marketCode);
    // Los casos de uso del catálogo trabajan con el mercado vigente.
    if (market == null || market != currentMarket()) return null;
    final key = [
      slot.marketCode,
      slot.year,
      slot.brand,
      slot.modelName,
    ].join(CompareConfig.identitySeparator);
    final load = _loads[key] ??= _fetch(slot, market);
    try {
      return await load;
    } catch (_) {
      // Una falla no se queda guardada: el siguiente intento vuelve a pedir.
      if (identical(_loads[key], load)) _loads.remove(key);
      rethrow;
    }
  }

  Future<GroupDetailsEntity> _fetch(
    CompareSlotEntity slot,
    Market market,
  ) async {
    final groups = await getModelGroups(slot.year, slot.brand);
    final group = groups
        .where((candidate) => candidate.name == slot.modelName)
        .firstOrNull;
    return loadGroupDetails(
      DetailArgsEntity(
        brand: slot.brand,
        groupName: slot.modelName,
        year: slot.year,
        variantNames: [
          for (final variant in group?.variants ?? const <ModelEntity>[])
            variant.name,
        ],
        photo: null,
        heroTag: slot.identity,
        market: market,
      ),
    );
  }
}
