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
    this.emptyBrands = const [],
  });

  /// Construyendo: ya se puede buscar por marca.
  const SearchIndexStatusEntity.building({
    required int completedBrands,
    required int totalBrands,
    List<String> failedBrands = const [],
    List<String> emptyBrands = const [],
  }) : this(
         phase: SearchIndexPhase.building,
         completedBrands: completedBrands,
         totalBrands: totalBrands,
         failedBrands: failedBrands,
         emptyBrands: emptyBrands,
       );

  /// Todas las marcas resueltas: con grupos o confirmadas vacías.
  const SearchIndexStatusEntity.ready({
    required int totalBrands,
    List<String> emptyBrands = const [],
  }) : this(
         phase: SearchIndexPhase.ready,
         completedBrands: totalBrands,
         totalBrands: totalBrands,
         emptyBrands: emptyBrands,
       );

  /// Terminó, pero a las marcas fallidas les faltan los grupos.
  const SearchIndexStatusEntity.partial({
    required int totalBrands,
    required List<String> failedBrands,
    List<String> emptyBrands = const [],
  }) : this(
         phase: SearchIndexPhase.partial,
         completedBrands: totalBrands,
         totalBrands: totalBrands,
         failedBrands: failedBrands,
         emptyBrands: emptyBrands,
       );

  final SearchIndexPhase phase;
  final int completedBrands;
  final int totalBrands;

  /// Marcas cuya petición falló o cuya respuesta llegó incompleta.
  final List<String> failedBrands;

  /// Marcas que respondieron sin modelos de forma consistente: no bloquean.
  final List<String> emptyBrands;

  /// Marcas ya resueltas (sin contar las fallidas); las vacías confirmadas cuentan.
  int get indexedBrands =>
      (completedBrands - failedBrands.length).clamp(0, totalBrands);

  /// Avance de 0 a 1.
  double get progress => totalBrands == 0 ? 1 : completedBrands / totalBrands;

  @override
  List<Object?> get props => [
    phase,
    completedBrands,
    totalBrands,
    failedBrands,
    emptyBrands,
  ];
}
