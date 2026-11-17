import 'package:cars_wheels_app/features/safety/domain/entities/recall_summary_entity.dart';

/// Recalls de un grupo.
abstract class RecallsRepository {
  /// Con recalls siempre los devuelve; sin ellos, solo si el modelo es único
  /// y exacto en vPIC. Nulo si el cero no se puede asegurar.
  Future<RecallSummaryEntity?> getRecalls(int year, String make, String model);
}
