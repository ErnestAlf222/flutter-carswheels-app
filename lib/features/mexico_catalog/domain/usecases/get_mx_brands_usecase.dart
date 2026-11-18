import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/entities/mx_brand_entity.dart';
import 'package:cars_wheels_app/features/mexico_catalog/domain/repositories/mexico_catalog_repository.dart';

/// Obtiene las marcas de un año con su cantidad de filas, ordenadas por nombre.
class GetMxBrandsUseCase {
  const GetMxBrandsUseCase(this.repository);

  final MexicoCatalogRepository repository;

  Future<List<MxBrandEntity>> call(int year) async {
    final catalog = await repository.fetchYear(year);
    final counts = <String, int>{};
    final names = <String, String>{};
    for (final vehicle in catalog.vehicles) {
      final key = TextNormalizer.normalize(vehicle.brand);
      names.putIfAbsent(key, () => vehicle.brand);
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return [
      for (final entry in counts.entries)
        MxBrandEntity(name: names[entry.key]!, vehicleCount: entry.value),
    ]..sort(
      (a, b) =>
          TextNormalizer.normalize(a.name)
              .compareTo(TextNormalizer.normalize(b.name)),
    );
  }
}
