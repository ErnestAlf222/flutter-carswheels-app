import 'package:equatable/equatable.dart';

/// Año ofrecido y el recurso de CKAN que lo contiene.
class MxYearSourceEntity extends Equatable {
  const MxYearSourceEntity({required this.year, required this.resourceId});

  final int year;
  final String resourceId;

  @override
  List<Object?> get props => [year, resourceId];
}
