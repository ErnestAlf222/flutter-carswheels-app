import 'package:equatable/equatable.dart';

/// Fila indexada: una marca sola (groupName nulo) o un grupo de una marca.
class SearchEntryEntity extends Equatable {
  const SearchEntryEntity({required this.brand, this.groupName});

  final String brand;
  final String? groupName;

  @override
  List<Object?> get props => [brand, groupName];
}
