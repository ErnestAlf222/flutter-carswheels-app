import 'package:cars_wheels_app/features/search/domain/entities/search_group_entity.dart';
import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';

/// Origen del catálogo para el índice; lo implementa la capa app.
abstract class SearchCatalogSource {
  /// Nombres de las marcas del mercado y año.
  Future<List<String>> fetchBrands(SearchScopeEntity scope);

  /// Grupos de modelo (con sus variantes) de una marca del mercado y año.
  Future<List<SearchGroupEntity>> fetchGroups(
    SearchScopeEntity scope,
    String brand,
  );
}
