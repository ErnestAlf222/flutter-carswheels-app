import 'package:cars_wheels_app/features/search/search.dart';

/// Crea un SearchCubit independiente del de la pestaña Buscar.
///
/// Comparte el índice ya construido y las cachés, pero usa sus propios casos de
/// uso de construcción y de otros años: cerrar este cubit no cancela las
/// construcciones del otro.
class SearchCubitFactory {
  const SearchCubitFactory(this.create);

  /// Recibe la fuente de mercado y año propia del nuevo cubit (la cierra él).
  final SearchCubit Function(SearchContextSource contextSource) create;
}
