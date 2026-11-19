import 'package:equatable/equatable.dart';

/// Fase de la construcción del índice.
enum SearchIndexPhase { building, ready, partial }

/// Estado del índice: construyendo con progreso, listo o parcial.
class SearchIndexStatusEntity extends Equatable {
  const SearchIndexStatusEntity({
    required this.phase,
    required this.completedBrands,
    required this.totalBrands,
    this.failedBrands = const [],
  });

  /// Construyendo: ya se puede buscar por marca.
  const SearchIndexStatusEntity.building({
    required int completedBrands,
    required int totalBrands,
    List<String> failedBrands = const [],
  }) : this(
         phase: SearchIndexPhase.building,
         completedBrands: completedBrands,
         totalBrands: totalBrands,
         failedBrands: failedBrands,
       );

  /// Todas las marcas indexadas.
  const SearchIndexStatusEntity.ready({required int totalBrands})
    : this(
        phase: SearchIndexPhase.ready,
        completedBrands: totalBrands,
        totalBrands: totalBrands,
      );

  /// Terminó, pero a las marcas fallidas les faltan los grupos.
  const SearchIndexStatusEntity.partial({
    required int totalBrands,
    required List<String> failedBrands,
  }) : this(
         phase: SearchIndexPhase.partial,
         completedBrands: totalBrands,
         totalBrands: totalBrands,
         failedBrands: failedBrands,
       );

  final SearchIndexPhase phase;
  final int completedBrands;
  final int totalBrands;
  final List<String> failedBrands;

  /// Avance de 0 a 1.
  double get progress => totalBrands == 0 ? 1 : completedBrands / totalBrands;

  @override
  List<Object?> get props => [
    phase,
    completedBrands,
    totalBrands,
    failedBrands,
  ];
}
