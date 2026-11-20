import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/datasources/vehicle_detail_cache_datasource.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/group_option_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_option_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/repositories/vehicle_specs_repository.dart';

// Resultado de leer una variante: sus opciones, o el fallo que lo impidió.
typedef _VariantOptions = ({
  List<VehicleOptionEntity>? options,
  AppFailure? failure,
});

/// Pide las opciones de todas las variantes de un grupo.
class GetGroupOptionsUseCase {
  const GetGroupOptionsUseCase(this.repository, {this.cache});

  final VehicleSpecsRepository repository;

  /// Versiones guardadas: sin red, Detalle se abre con las últimas conocidas.
  final GroupOptionsCacheDatasource? cache;

  /// Orden de las variantes y, dentro de cada una, el de la API.
  /// Omite las variantes que fallan; si todas fallan por red, relanza el fallo.
  Future<List<GroupOptionEntity>> call({
    required int year,
    required String brand,
    required List<String> variantNames,
  }) async {
    // Todas se lanzan a la vez; la cola limita la concurrencia real.
    final reads = await Future.wait([
      for (final name in variantNames) _read(year, brand, name),
    ]);
    final failures = [
      for (final read in reads)
        if (read.failure != null) read.failure!,
    ];
    final allFailedByNetwork =
        reads.isNotEmpty &&
        failures.length == reads.length &&
        failures.every((failure) => failure is NetworkFailure);
    if (allFailedByNetwork) throw failures.first;
    return [
      for (final (index, read) in reads.indexed)
        for (final option in read.options ?? <VehicleOptionEntity>[])
          GroupOptionEntity(variantName: variantNames[index], option: option),
    ];
  }

  String _cacheKey(int year, String brand, String name) => [
    VehicleSpecsConfig.groupOptionsCacheKeyVersion,
    '$year',
    brand,
    name,
  ].join(PhotosConfig.cacheKeySeparator);

  Future<void> _save(String key, List<VehicleOptionEntity> options) async {
    try {
      await cache?.write(key, options);
    } on Object {
      // Sin guardar, Detalle sigue funcionando; solo falta la copia sin red.
    }
  }

  Future<List<VehicleOptionEntity>?> _saved(String key) async {
    try {
      return await cache?.read(key);
    } on Object {
      return null;
    }
  }

  // Lee una variante; la cancelación se relanza y los demás fallos se guardan.
  Future<_VariantOptions> _read(int year, String brand, String name) async {
    final key = _cacheKey(year, brand, name);
    try {
      final options = await repository.getOptions(year, brand, name);
      if (options.isNotEmpty) await _save(key, options);
      return (options: options, failure: null);
    } on CancelledFailure {
      rethrow;
    } on AppFailure catch (failure) {
      // Sin red se usan las versiones guardadas, si las hay.
      if (failure is NetworkFailure) {
        final saved = await _saved(key);
        if (saved != null) return (options: saved, failure: null);
      }
      return (options: null, failure: failure);
    }
  }
}
