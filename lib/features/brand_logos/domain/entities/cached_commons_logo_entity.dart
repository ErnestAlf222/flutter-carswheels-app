import 'package:cars_wheels_app/features/brand_logos/domain/entities/commons_logo_entity.dart';

/// Resultado guardado de una búsqueda de logo; sin logo es una búsqueda vacía.
class CachedCommonsLogoEntity {
  const CachedCommonsLogoEntity({required this.logo, required this.savedAt});

  /// Nulo significa que se buscó y no hay un logo aceptable.
  final CommonsLogoEntity? logo;
  final DateTime savedAt;

  bool get isMiss => logo == null;
}
