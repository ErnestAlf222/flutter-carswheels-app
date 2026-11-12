import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/photos/domain/datasources/photos_datasource.dart';
import 'package:cars_wheels_app/features/photos/domain/entities/photo_candidate_entity.dart';
import 'package:cars_wheels_app/features/photos/infrastructure/mappers/commons_candidate_mapper.dart';
import 'package:cars_wheels_app/features/photos/infrastructure/models/commons_search_model.dart';

/// Fotos sobre la API de Wikimedia Commons.
class CommonsPhotosDatasource implements PhotosDatasource {
  const CommonsPhotosDatasource({required this.dio, required this.queue});

  final Dio dio;
  final RateLimitedQueue queue;

  @override
  Future<List<PhotoCandidateEntity>> searchCandidates(String searchTerm) {
    return queue.enqueue(() => _search(searchTerm));
  }

  // Una petición; traduce los errores de Dio para que la cola los vea.
  Future<List<PhotoCandidateEntity>> _search(String searchTerm) async {
    try {
      final response = await dio.get<Object?>(
        ApiConfig.commonsApiUrl,
        queryParameters: {
          ...PhotosConfig.commonsRequestParameters,
          PhotosConfig.searchTermParameter: searchTerm,
          PhotosConfig.searchLimitParameter: PhotosConfig.searchResultLimit,
          PhotosConfig.thumbnailWidthParameter:
              PhotosConfig.thumbnailWidthPixels,
        },
      );
      return CommonsSearchModel.fromJson(response.data).pages
          .map(CommonsCandidateMapper.toCandidate)
          .toList();
    } on DioException catch (exception) {
      throw DioFailureMapper.map(exception);
    }
  }
}
