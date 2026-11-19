import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';

/// Origen del catálogo para el índice; lo implementa la capa app.
abstract class SearchCatalogSource {
  /// Nombres de las marcas del mercado y año.
  Future<List<String>> fetchBrands(SearchScopeEntity scope);

  /// Nombres de los grupos de modelo de una marca del mercado y año.
  Future<List<String>> fetchGroupNames(SearchScopeEntity scope, String brand);
}
