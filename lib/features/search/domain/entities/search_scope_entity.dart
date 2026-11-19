import 'package:equatable/equatable.dart';

import 'package:cars_wheels_app/core/core.dart';

/// Mercado y año sobre los que se construye un índice.
class SearchScopeEntity extends Equatable {
  const SearchScopeEntity({required this.marketCode, required this.year});

  final String marketCode;
  final int year;

  /// Clave del índice en memoria: mercado|año.
  String get key => '$marketCode${SearchConfig.scopeKeySeparator}$year';

  @override
  List<Object?> get props => [marketCode, year];
}
