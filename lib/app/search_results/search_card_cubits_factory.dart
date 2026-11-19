import 'package:cars_wheels_app/features/photos/photos.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';

/// Crea los cubits de fotos y resúmenes propios de los resultados de búsqueda.
///
/// Usan los mismos casos de uso (y por tanto las mismas cachés) que Inicio,
/// pero su estado en memoria es independiente.
class SearchCardCubitsFactory {
  const SearchCardCubitsFactory({
    required this.createPhotos,
    required this.createSummaries,
  });

  final PhotosCubit Function() createPhotos;
  final SummariesCubit Function() createSummaries;
}
