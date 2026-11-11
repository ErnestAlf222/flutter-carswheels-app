import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';
import 'package:cars_wheels_app/features/brand_logos/infrastructure/models/brand_logos_manifest_model.dart';

/// Manifiesto de logos servido desde el CDN.
class BrandLogosCdnDatasource implements BrandLogosDatasource {
  const BrandLogosCdnDatasource(this._dio);

  final Dio _dio;

  @override
  Future<Map<String, String>> fetchManifest() async {
    try {
      final response = await _dio.get<Object?>(
        '${LogosConfig.logosBaseUrl}${LogosConfig.manifestFileName}',
      );
      return BrandLogosManifestModel.fromJson(response.data).fileNamesByBrand;
    } on DioException catch (exception) {
      throw DioFailureMapper.map(exception);
    }
  }
}
