import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';
import 'package:cars_wheels_app/features/safety/safety.dart';

/// Estrellas NHTSA de un vehículo, con la caché de seguridad de Detalle.
class MarketCompareSafetySource implements CompareSafetySource {
  const MarketCompareSafetySource(this.resolveGroupSafety);

  final ResolveGroupSafetyUseCase resolveGroupSafety;

  @override
  Future<int?> overallStarsOf(CompareSlotEntity slot) async {
    // NHTSA solo cubre EE. UU.: en México no se consulta.
    if (slot.marketCode == MarketConfig.mexicoCode) return null;
    final safety = await resolveGroupSafety.resolveSafety(
      year: slot.year,
      make: slot.brand,
      model: slot.modelName,
    );
    return safety?.maxOverall;
  }
}
