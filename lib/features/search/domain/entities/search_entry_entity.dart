import 'package:equatable/equatable.dart';

/// Fila indexada: una marca sola (groupName nulo) o un grupo de una marca.
class SearchEntryEntity extends Equatable {
  const SearchEntryEntity({
    required this.brand,
    this.groupName,
    this.variantNames = const [],
  });

  final String brand;
  final String? groupName;

  /// Variantes del grupo; vacío en las filas de marca sola.
  final List<String> variantNames;

  @override
  List<Object?> get props => [brand, groupName, variantNames];
}
