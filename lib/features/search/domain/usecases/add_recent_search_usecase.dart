import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/search/domain/datasources/recent_searches_datasource.dart';
import 'package:cars_wheels_app/features/search/domain/entities/recent_search_entity.dart';

/// Guarda una búsqueda reciente: sin duplicados, la repetida sube al inicio.
class AddRecentSearchUseCase {
  const AddRecentSearchUseCase({required this.datasource, required this.clock});

  final RecentSearchesDatasource datasource;
  final DateTime Function() clock;

  /// Devuelve false si el texto no llega al mínimo de caracteres.
  Future<bool> call(String text) async {
    final key = TextNormalizer.normalize(text);
    if (key.length < SearchConfig.minQueryLength) return false;
    final current = await datasource.readAll();
    final updated = [
      RecentSearchEntity(key: key, text: text.trim(), searchedAt: clock()),
      for (final search in current)
        if (search.key != key) search,
    ];
    await datasource.replaceAll(
      updated.take(SearchConfig.maxRecentSearches).toList(),
    );
    return true;
  }
}
