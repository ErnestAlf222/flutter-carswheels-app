import 'package:cars_wheels_app/core/core.dart';

/// Respuesta de búsqueda de Commons: las páginas que traen imageinfo.
class CommonsSearchModel {
  const CommonsSearchModel({required this.pages});

  /// Sin la clave query (sin resultados) devuelve una lista vacía.
  factory CommonsSearchModel.fromJson(Object? json) {
    if (json is! Map<String, dynamic>) {
      throw const ParsingFailure('La respuesta de Commons no es un objeto');
    }
    final query = json[PhotosConfig.queryKey];
    if (query == null) return const CommonsSearchModel(pages: []);
    if (query is! Map<String, dynamic>) {
      throw const ParsingFailure('La clave query de Commons es inválida');
    }
    final rawPages = query[PhotosConfig.pagesKey];
    if (rawPages == null) return const CommonsSearchModel(pages: []);
    // Las páginas vienen como objeto cuyas claves son identificadores.
    if (rawPages is! Map<String, dynamic>) {
      throw const ParsingFailure('Las páginas de Commons no son un objeto');
    }
    final pages = rawPages.values.map(_readPage).toList();
    return CommonsSearchModel(pages: pages.where(_hasImageInfo).toList());
  }

  final List<Map<String, dynamic>> pages;

  static Map<String, dynamic> _readPage(Object? page) {
    if (page is Map<String, dynamic>) return page;
    throw const ParsingFailure('Una página de Commons no es un objeto');
  }

  static bool _hasImageInfo(Map<String, dynamic> page) {
    final info = page[PhotosConfig.imageInfoKey];
    if (info == null) return false;
    if (info is List<dynamic>) return info.isNotEmpty;
    throw const ParsingFailure('El imageinfo de Commons no es una lista');
  }
}
