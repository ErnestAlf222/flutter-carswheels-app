/// Textos para el usuario.
class AppTexts {
  const AppTexts._();

  static const String emptyStateTitle = 'Sin registros';
  static const String errorStateTitle = 'No se pudo cargar la información';
  static const String retryButtonLabel = 'Reintentar';
  static const String refreshFailedLabel = 'No se pudo actualizar';
  static const String referencePhotoLabel = 'Foto de referencia';
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

  static String versionsCountLabel(int count) =>
      count == 1 ? '1 versión' : '$count versiones';

  static String brandTileLabel(String name) => 'Marca $name';

  static const String electricLabel = 'Eléctrico';
  static const String pluginHybridLabel = 'Híbrido enchufable';
  static const String electricAndPluginLabel = 'Eléctrico e híbrido enchufable';
  static const String consumptionUnitLabel = 'km/l combinado';
  static const String mixedPowertrainSemanticLabel =
      'Incluye versiones eléctricas o híbridas enchufables';
  static const String classAndVersionsSeparator = ' · ';

  /// Cifra de consumo: un solo número si el rango redondea igual.
  static String consumptionFigureLabel(int min, int max) =>
      min == max ? '$min' : '$min–$max';

  /// Etiqueta de accesibilidad de una fila de modelo.
  static String modelSummarySemanticLabel(String name, String? consumption) =>
      consumption == null ? name : '$name, $consumption';
}
