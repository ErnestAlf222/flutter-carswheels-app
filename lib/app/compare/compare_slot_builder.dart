import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/search/search.dart';

/// Arma el vehículo del comparador desde Detalle o desde un resultado de búsqueda.
class CompareSlotBuilder {
  const CompareSlotBuilder._();

  /// Clave del grupo: su nombre sin mayúsculas ni acentos.
  static String groupKeyOf(String groupName) =>
      TextNormalizer.normalize(groupName);

  /// Vehículo de Detalle; [versionKey] nulo significa la versión predeterminada.
  static CompareSlotEntity fromDetail(
    DetailArgsEntity args,
    String? versionKey,
  ) => CompareSlotEntity(
    marketCode: args.market.code,
    year: args.year,
    brand: args.brand,
    groupKey: groupKeyOf(args.groupName),
    modelName: args.groupName,
    versionKey: versionKey,
  );

  /// Vehículo de un resultado; nulo si el resultado es solo una marca.
  static CompareSlotEntity? fromResult(SearchResultEntity result) {
    final groupName = result.groupName;
    if (groupName == null) return null;
    return CompareSlotEntity(
      marketCode: result.marketCode,
      year: result.year,
      brand: result.brand,
      groupKey: groupKeyOf(groupName),
      modelName: groupName,
    );
  }
}
