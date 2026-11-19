import 'package:dio/dio.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/domain/domain.dart';

/// Logos de marcas sobre la API de Wikimedia Commons, con la cola de 300 ms.
class CommonsLogoDatasourceImpl implements CommonsLogoDatasource {
  const CommonsLogoDatasourceImpl({required this.dio, required this.queue});

  final Dio dio;
  final RateLimitedQueue queue;

  static final RegExp _tagPattern = RegExp(PhotosConfig.htmlTagPattern);

  @override
  Future<List<CommonsLogoCandidateEntity>> searchLogos(String brandName) =>
      queue.enqueue(() => _search(brandName));

  Future<List<CommonsLogoCandidateEntity>> _search(String brandName) async {
    try {
      final response = await dio.get<Object?>(
        ApiConfig.commonsApiUrl,
        queryParameters: {
          ...PhotosConfig.commonsRequestParameters,
          LogosConfig.commonsLogoMimeParameter:
              LogosConfig.commonsLogoImageInfoProperties,
          LogosConfig.commonsLogoMetadataFilterParameter:
              LogosConfig.commonsLogoMetadataFilter,
          PhotosConfig.searchTermParameter:
              '$brandName ${LogosConfig.commonsLogoSearchSuffix}',
          PhotosConfig.searchLimitParameter: LogosConfig.commonsLogoSearchLimit,
          PhotosConfig.thumbnailWidthParameter:
              LogosConfig.commonsLogoThumbnailWidthPixels,
        },
      );
      return parse(response.data);
    } on DioException catch (exception) {
      throw DioFailureMapper.map(exception);
    }
  }

  /// Páginas de la respuesta de Commons como candidatos; sin datos, vacío.
  static List<CommonsLogoCandidateEntity> parse(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const ParsingFailure('La respuesta de Commons no es un objeto');
    }
    final query = json[PhotosConfig.queryKey];
    if (query is! Map<String, dynamic>) return const [];
    final pages = query[PhotosConfig.pagesKey];
    if (pages is! Map<String, dynamic>) return const [];
    return [for (final page in pages.values) ?_toCandidate(page)];
  }

  // Una página sin los datos necesarios se salta, sin fallar.
  static CommonsLogoCandidateEntity? _toCandidate(Object? page) {
    if (page is! Map<String, dynamic>) return null;
    final infoList = page[PhotosConfig.imageInfoKey];
    if (infoList is! List<dynamic> || infoList.isEmpty) return null;
    final info = infoList.first;
    if (info is! Map<String, dynamic>) return null;
    final title = page[PhotosConfig.titleKey];
    final fileUrl = info[LogosConfig.commonsLogoUrlKey];
    final mime = info[LogosConfig.commonsLogoMimeKey];
    final source = info[PhotosConfig.descriptionUrlKey];
    if (title is! String ||
        fileUrl is! String ||
        mime is! String ||
        source is! String) {
      return null;
    }
    final thumbnail = info[PhotosConfig.thumbnailUrlKey];
    final metadata = info[PhotosConfig.extMetadataKey];
    final rank = page[PhotosConfig.rankKey];
    return CommonsLogoCandidateEntity(
      title: title,
      fileUrl: fileUrl,
      thumbnailUrl: thumbnail is String ? thumbnail : fileUrl,
      mime: mime,
      licenseName: _metadataValue(metadata, PhotosConfig.licenseKey),
      authorName: _metadataValue(
        metadata,
        PhotosConfig.artistKey,
      ).replaceAll(_tagPattern, '').trim(),
      sourceUrl: source,
      rank: rank is int ? rank : PhotosConfig.missingRank,
      categories: _metadataValue(metadata, LogosConfig.commonsCategoriesKey)
          .split(LogosConfig.commonsCategorySeparator)
          .where((category) => category.isNotEmpty)
          .toList(),
    );
  }

  static String _metadataValue(Object? metadata, String key) {
    if (metadata is! Map<String, dynamic>) return '';
    final entry = metadata[key];
    if (entry is! Map<String, dynamic>) return '';
    final value = entry[PhotosConfig.valueKey];
    return value is String ? value : '';
  }
}
