import 'package:cars_wheels_app/features/search/domain/entities/search_scope_entity.dart';

/// Mercado y año vigentes de la app; lo implementa la capa app.
abstract class SearchContextSource {
  /// Alcance actual; nulo mientras el catálogo no está listo para el mercado.
  SearchScopeEntity? get scope;

  /// Cada cambio de alcance (nulo cuando se está recargando el catálogo).
  Stream<SearchScopeEntity?> get scopeChanges;

  /// Años disponibles del mercado vigente, del más reciente al más antiguo.
  List<int> get availableYears;

  /// Libera las suscripciones.
  Future<void> close();
}
