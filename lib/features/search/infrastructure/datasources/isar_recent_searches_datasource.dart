import 'package:isar_community/isar.dart';

import 'package:cars_wheels_app/features/search/domain/datasources/recent_searches_datasource.dart';
import 'package:cars_wheels_app/features/search/domain/entities/recent_search_entity.dart';
import 'package:cars_wheels_app/features/search/infrastructure/models/recent_search_model.dart';

/// Búsquedas recientes guardadas en Isar.
class IsarRecentSearchesDatasource implements RecentSearchesDatasource {
  const IsarRecentSearchesDatasource(this.isar);

  final Isar isar;

  @override
  Future<List<RecentSearchEntity>> readAll() async {
    final models = await isar.recentSearchModels.where().findAll();
    models.sort((a, b) {
      final byDate = b.searchedAtMillis.compareTo(a.searchedAtMillis);
      return byDate != 0 ? byDate : a.key.compareTo(b.key);
    });
    return [
      for (final model in models)
        RecentSearchEntity(
          key: model.key,
          text: model.text,
          searchedAt: DateTime.fromMillisecondsSinceEpoch(
            model.searchedAtMillis,
          ),
        ),
    ];
  }

  @override
  Future<void> replaceAll(List<RecentSearchEntity> searches) {
    return isar.writeTxn(() async {
      await isar.recentSearchModels.clear();
      await isar.recentSearchModels.putAll([
        for (final search in searches)
          RecentSearchModel(
            key: search.key,
            text: search.text,
            searchedAtMillis: search.searchedAt.millisecondsSinceEpoch,
          ),
      ]);
    });
  }
}
