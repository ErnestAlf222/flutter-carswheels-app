import 'package:cars_wheels_app/core/config/config.dart';

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
  static const String hydrogenLabel = 'Hidrógeno';
  static const String semanticListSeparator = ', ';
  static const String consumptionUnitLabel = 'km/l combinado';
  static const String mixedPowertrainSemanticLabel =
      'Incluye versiones eléctricas, híbridas enchufables o de hidrógeno';
  static const String classAndVersionsSeparator = ' · ';

  /// Cifra de consumo: un solo número si el rango redondea igual.
  static String consumptionFigureLabel(int min, int max) =>
      min == max ? '$min' : '$min–$max';

  /// Etiqueta de accesibilidad de una fila de modelo.
  static String modelSummarySemanticLabel(String name, String? consumption) =>
      consumption == null ? name : '$name, $consumption';

  static const String transmissionAutomaticLabel = 'Automática';
  static const String transmissionManualLabel = 'Manual';
  static const String transmissionCvtLabel = 'CVT';
  static const String descriptorSeparator = ' · ';
  static const String noDataLabel = '—';

  // Pantalla Detalle.
  static const String detailConsumptionCaption = 'consumo combinado';
  static const String detailPowertrainCaption = 'tipo de motor';
  static const String detailAnnualCostCaption = 'combustible al año (USD)';
  static const String detailSafetyCaption = 'seguridad NHTSA';
  static const String detailClassRowLabel = 'Clase';
  static const String detailFuelRowLabel = 'Combustible';
  static const String detailDriveRowLabel = 'Tracción';
  static const String detailRecallsLabel = 'Avisos de seguridad (recalls)';
  static const String compareWithOtherLabel = 'Comparar con otro';
  static const String addToFavoritesLabel = 'Agregar a favoritos';
  static const String backLabel = 'Volver';
  static const String versionSheetTitle = 'Elige una versión';
  static const String authorMissingLabel = 'Autor no indicado';
  static const String kmPerLiterUnit = 'km/l';
  static const String creditSeparator = ' · ';

  static String detailVersionLabel(int n) =>
      n == 1 ? 'Versión (1 disponible)' : 'Versión ($n disponibles)';

  static String brandYearLabel(String brand, int year) =>
      '${brand.toUpperCase()} · $year';

  static String photoCreditLabel(String author, String license) =>
      'Foto: $author · $license';

  /// Consumo con un decimal, por ejemplo '14.6'.
  static String kmPerLiterFigure(double value) =>
      value.toStringAsFixed(TextConfig.kmPerLiterFractionDigits);

  static String transmissionSpeedsLabel(int count) => '$count vel.';

  static String cylindersLabel(int count) => '$count cil';

  /// Litros con un decimal, por ejemplo '2.0 L'.
  static String displacementLabel(double liters) =>
      '${liters.toStringAsFixed(TextConfig.displacementFractionDigits)} L';

  /// Costo anual en dólares con separador de miles, por ejemplo '$1,750'.
  static String annualCostLabel(int usd) {
    final grouped = usd.toString().replaceAllMapped(
      RegExp(TextConfig.thousandsBoundaryPattern),
      (_) => TextConfig.thousandsSeparator,
    );
    return '\$$grouped';
  }
}
