import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/safety/domain/datasources/nhtsa_recalls_datasource.dart';
import 'package:cars_wheels_app/features/safety/domain/entities/recall_summary_entity.dart';
import 'package:cars_wheels_app/features/safety/domain/repositories/recalls_repository.dart';

/// Repositorio de recalls sobre un NhtsaRecallsDatasource.
class RecallsRepositoryImpl implements RecallsRepository {
  const RecallsRepositoryImpl(this.datasource);

  final NhtsaRecallsDatasource datasource;

  @override
  Future<RecallSummaryEntity?> getRecalls(
    int year,
    String make,
    String model,
  ) async {
    final recalls = await datasource.fetchRecalls(year, make, model);
    if (recalls.isNotEmpty) return RecallSummaryEntity(recalls: recalls);
    // El cero solo vale si vPIC lo confirma: NHTSA nombra distinto (C 300).
    final isUnique = await _isUniqueInVpic(year, make, model);
    return isUnique ? const RecallSummaryEntity(recalls: []) : null;
  }

  // Único si vPIC lo lista exacto y ningún otro modelo empieza con su nombre.
  Future<bool> _isUniqueInVpic(int year, String make, String model) async {
    final names = await datasource.fetchVpicModelNames(year, make);
    final target = TextNormalizer.normalize(model);
    final normalized = {
      for (final name in names) TextNormalizer.normalize(name),
    };
    if (!normalized.contains(target)) return false;
    return !normalized.any((name) => name != target && name.startsWith(target));
  }
}
