import 'package:cars_wheels_app/features/compare/domain/entities/compare_selection_entity.dart';

/// Resultado de agregar un vehículo; siempre trae la selección vigente.
sealed class CompareAddResult {
  const CompareAddResult(this.selection);

  final CompareSelectionEntity selection;
}

/// El vehículo se agregó al final de la lista.
class CompareAdded extends CompareAddResult {
  const CompareAdded(super.selection);
}

/// El vehículo ya estaba (mismo grupo, versión y año); no se duplicó.
class CompareAlreadyPresent extends CompareAddResult {
  const CompareAlreadyPresent(super.selection);
}

/// La lista ya tiene el máximo de vehículos; no se agregó.
class CompareFull extends CompareAddResult {
  const CompareFull(super.selection);
}
