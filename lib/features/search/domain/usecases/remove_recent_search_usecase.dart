import 'package:cars_wheels_app/features/search/domain/datasources/recent_searches_datasource.dart';

/// Borra una búsqueda reciente por su clave.
class RemoveRecentSearchUseCase {
  const RemoveRecentSearchUseCase(this.datasource);

  final RecentSearchesDatasource datasource;

  Future<void> call(String key) async {
    final current = await datasource.readAll();
    await datasource.replaceAll([
      for (final search in current)
        if (search.key != key) search,
    ]);
  }
}
