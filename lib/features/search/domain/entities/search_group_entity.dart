import 'package:equatable/equatable.dart';

/// Grupo de modelo que entrega el origen del catálogo: nombre y variantes.
class SearchGroupEntity extends Equatable {
  const SearchGroupEntity({required this.name, this.variantNames = const []});

  final String name;

  /// Nombres de las variantes tal como los entrega el catálogo.
  final List<String> variantNames;

  @override
  List<Object?> get props => [name, variantNames];
}
