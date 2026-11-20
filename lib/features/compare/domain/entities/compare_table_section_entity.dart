import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/features/compare/domain/entities/compare_table_row_entity.dart';

/// Un grupo de filas con su título.
class CompareTableSectionEntity extends Equatable {
  const CompareTableSectionEntity({required this.title, required this.rows});

  final String title;
  final List<CompareTableRowEntity> rows;

  @override
  List<Object?> get props => [title, rows];
}
