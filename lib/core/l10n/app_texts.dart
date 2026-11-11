/// Textos para el usuario.
class AppTexts {
  const AppTexts._();

  static const String emptyStateTitle = 'Sin registros';
  static const String errorStateTitle = 'No se pudo cargar la información';
  static const String retryButtonLabel = 'Reintentar';
  static const String refreshFailedLabel = 'No se pudo actualizar';
  static const String homePageTitle = 'Pantalla Inicio';
  static const String searchPageTitle = 'Pantalla Buscar';
  static const String comparePageTitle = 'Pantalla Comparar';
  static const String favoritesPageTitle = 'Pantalla Favoritos';
  static const String settingsPageTitle = 'Pantalla Ajustes';
  static const String placeholderItemLabel = 'Elemento de prueba';
  static const String navHomeLabel = 'Inicio';
  static const String navSearchLabel = 'Buscar';
  static const String navCompareLabel = 'Comparar';
  static const String navFavoritesLabel = 'Favoritos';
  static const String navSettingsLabel = 'Ajustes';
  static const String brandsSectionTitle = 'Marcas';
  static const String previousBrandsLabel = 'Marcas anteriores';
  static const String nextBrandsLabel = 'Marcas siguientes';

  static const String olderYearLabel = 'Año anterior';
  static const String newerYearLabel = 'Año siguiente';

  static String modelsCountLabel(int count) =>
      count == 1 ? '1 modelo' : '$count modelos';

  static String brandTileLabel(String name) => 'Marca $name';
}
