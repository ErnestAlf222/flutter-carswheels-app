import 'package:cars_wheels_app/features/search/domain/datasources/recent_searches_datasource.dart';
import 'package:cars_wheels_app/features/search/domain/entities/recent_search_entity.dart';

/// Lista las búsquedas recientes, la más reciente primero.
class GetRecentSearchesUseCase {
  const GetRecentSearchesUseCase(this.datasource);

  final RecentSearchesDatasource datasource;

  Future<List<RecentSearchEntity>> call() => datasource.readAll();
}
