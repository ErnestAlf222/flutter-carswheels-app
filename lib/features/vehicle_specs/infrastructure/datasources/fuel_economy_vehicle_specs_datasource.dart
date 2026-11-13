import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/datasources/vehicle_specs_datasource.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_option_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/domain/entities/vehicle_record_entity.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/mappers/vehicle_option_mapper.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/mappers/vehicle_record_mapper.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/models/fuel_economy_options_model.dart';
import 'package:cars_wheels_app/features/vehicle_specs/infrastructure/models/fuel_economy_vehicle_model.dart';

/// Vehículos sobre la API de FuelEconomy; cada petición pasa por la cola.
class FuelEconomyVehicleSpecsDatasource implements VehicleSpecsDatasource {
  const FuelEconomyVehicleSpecsDatasource({
    required this.dio,
    required this.queue,
  });

  final Dio dio;
  final ConcurrencyLimitedQueue queue;

  @override
  Future<List<int>> fetchOptionIds(int year, String brand, String model) async {
    final options = await fetchOptions(year, brand, model);
    return [for (final option in options) option.id];
  }

  @override
  Future<List<VehicleOptionEntity>> fetchOptions(
    int year,
    String brand,
    String model,
  ) {
    return queue.enqueue(() => _fetchOptions(year, brand, model));
  }

  @override
  Future<VehicleRecordEntity?> fetchVehicle(int id) {
    return queue.enqueue(() => _fetchVehicle(id));
  }

  Future<List<VehicleOptionEntity>> _fetchOptions(
    int year,
    String brand,
    String model,
  ) async {
    final data = await _get(VehicleSpecsConfig.optionsPath, {
      FuelEconomyConfig.yearQueryParameter: year,
      FuelEconomyConfig.makeQueryParameter: brand,
      VehicleSpecsConfig.modelQueryParameter: model,
    });
    return VehicleOptionMapper.toEntities(
      FuelEconomyOptionsModel.fromJson(data),
    );
  }

  Future<VehicleRecordEntity?> _fetchVehicle(int id) async {
    final path = VehicleSpecsConfig.vehiclePathTemplate.replaceAll(
      VehicleSpecsConfig.idPlaceholder,
      '$id',
    );
    final data = await _get(path, null);
    if (data == null) return null;
    return VehicleRecordMapper.toEntity(FuelEconomyVehicleModel.fromJson(data));
  }

  // Una petición; traduce los errores de Dio a AppFailure.
  Future<Object?> _get(
    String path,
    Map<String, dynamic>? queryParameters,
  ) async {
    try {
      final response = await dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (exception) {
      throw DioFailureMapper.map(exception);
    }
  }
}
