import 'package:equatable/equatable.dart';

/// Coincidencia de búsqueda: una marca sola o un grupo de modelo de una marca.
class SearchResultEntity extends Equatable {
  const SearchResultEntity({
    required this.brand,
    required this.year,
    required this.marketCode,
    this.groupName,
  });

  final String brand;

  /// Nombre del grupo para mostrar; nulo cuando el resultado es solo la marca.
  final String? groupName;
  final int year;
  final String marketCode;

  bool get isBrandOnly => groupName == null;

  @override
  List<Object?> get props => [brand, groupName, year, marketCode];
}
