import 'package:cars_wheels_app/features/search/domain/entities/recent_search_entity.dart';

/// Almacén de las búsquedas recientes.
abstract class RecentSearchesDatasource {
  /// Todas, la más reciente primero.
  Future<List<RecentSearchEntity>> readAll();

  /// Reemplaza todo lo guardado por la lista dada.
  Future<void> replaceAll(List<RecentSearchEntity> searches);
}
