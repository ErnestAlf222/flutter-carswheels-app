import 'package:cars_wheels_app/features/safety/domain/datasources/nhtsa_safety_ratings_datasource.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/group_safety_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/repositories/safety_ratings_repository.dart';
import 'package:cars_wheels_app/features/safety/domain/services/group_safety_builder.dart';
import 'package:cars_wheels_app/features/safety/domain/services/nhtsa_model_matcher.dart';

/// Repositorio de estrellas sobre un NhtsaSafetyRatingsDatasource.
class SafetyRatingsRepositoryImpl implements SafetyRatingsRepository {
  const SafetyRatingsRepositoryImpl({
    required this.datasource,
    this.matcher = const NhtsaModelMatcher(),
    this.builder = const GroupSafetyBuilder(),
  });

  final NhtsaSafetyRatingsDatasource datasource;
  final NhtsaModelMatcher matcher;
  final GroupSafetyBuilder builder;

  @override
  Future<GroupSafetyEntity?> getGroupSafety(
    int year,
    String make,
    String model,
  ) async {
    final names = await datasource.fetchModelNames(year, make);
    final matched = matcher.match(make, model, names);
    if (matched.isEmpty) return null;
    // Todas las peticiones se lanzan a la vez; la cola limita la concurrencia.
    final idLists = await Future.wait([
      for (final name in matched) datasource.fetchVehicleIds(year, make, name),
    ]);
    final ids = {for (final list in idLists) ...list};
    final ratings = await Future.wait([
      for (final id in ids) datasource.fetchRating(id),
    ]);
    return builder.build([for (final rating in ratings) ?rating]);
  }
}
