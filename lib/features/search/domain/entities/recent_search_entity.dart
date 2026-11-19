import 'package:equatable/equatable.dart';

/// Búsqueda reciente: el texto escrito y cuándo se hizo.
class RecentSearchEntity extends Equatable {
  const RecentSearchEntity({
    required this.key,
    required this.text,
    required this.searchedAt,
  });

  /// Texto normalizado; dos búsquedas con la misma clave son la misma.
  final String key;
  final String text;
  final DateTime searchedAt;

  @override
  List<Object?> get props => [key, text, searchedAt];
}
