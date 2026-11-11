import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/domain/datasources/catalog_datasource.dart';
import 'package:cars_wheels_app/features/catalog/domain/entities/brand_entity.dart';
import 'package:cars_wheels_app/features/catalog/infrastructure/mappers/brand_mapper.dart';
import 'package:cars_wheels_app/features/catalog/infrastructure/models/fuel_economy_menu_model.dart';

/// Catálogo sobre la API de FuelEconomy.
class FuelEconomyCatalogDatasource implements CatalogDatasource {
  const FuelEconomyCatalogDatasource(this._dio);

  final Dio _dio;

  @override
  Future<List<int>> fetchYears() async {
    final menu = await _fetchMenu(FuelEconomyConfig.menuYearPath, null);
    return BrandMapper.toYears(menu.itemTexts);
  }

  @override
  Future<List<BrandEntity>> fetchBrands(int year) async {
    final menu = await _fetchMenu(FuelEconomyConfig.menuMakePath, {
      FuelEconomyConfig.yearQueryParameter: year,
    });
    return menu.itemTexts.map(BrandMapper.toBrand).toList();
  }

  // Pide un menú y traduce los errores de Dio a AppFailure.
  Future<FuelEconomyMenuModel> _fetchMenu(
    String path,
    Map<String, dynamic>? queryParameters,
  ) async {
    try {
      final response = await _dio.get<Object?>(
        path,
        queryParameters: queryParameters,
      );
      return FuelEconomyMenuModel.fromJson(response.data);
    } on DioException catch (exception) {
      throw DioFailureMapper.map(exception);
    }
  }
}
