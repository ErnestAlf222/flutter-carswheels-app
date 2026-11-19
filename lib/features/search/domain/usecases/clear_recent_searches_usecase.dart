import 'package:cars_wheels_app/features/search/domain/datasources/recent_searches_datasource.dart';

/// Borra todas las búsquedas recientes.
class ClearRecentSearchesUseCase {
  const ClearRecentSearchesUseCase(this.datasource);

  final RecentSearchesDatasource datasource;

  Future<void> call() => datasource.replaceAll(const []);
}
