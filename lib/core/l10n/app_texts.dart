import 'package:cars_wheels_app/core/config/config.dart';

/// Textos para el usuario.
class AppTexts {
  const AppTexts._();

  static const String emptyStateTitle = 'Sin registros';
  static const String errorStateTitle = 'No se pudo cargar la información';
  static const String retryButtonLabel = 'Reintentar';
  static const String refreshFailedLabel = 'No se pudo actualizar';
  static const String referencePhotoLabel = 'Foto de referencia';
  static const String photoLoadingLabel = 'Cargando foto…';
  static const String noPhotoTitle = 'Aún no hay foto de este modelo';
  static const String noPhotoSemanticLabel = 'Sin foto';
  static const String expandPhotoSemanticLabel = 'Ver foto en grande';
  static const String photoViewerCloseLabel = 'Cerrar';
  static const String homePageTitle = 'Pantalla Inicio';
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
  // Wordmark: la primera palabra va en blanco y la segunda en amarillo.
  static const String wordmarkFirst = 'Cars ';
  static const String wordmarkSecond = 'Wheels';
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
  static const String gasolineLabel = 'Gasolina';
  static const String dieselLabel = 'Diésel';
  static const String hybridLabel = 'Híbrido';
  static const String flexFuelLabel = 'Flex-fuel o gas natural';
  static const String missingValueLabel = '—';

  // Selector de mercado.
  static const String fuelListSeparator = ' · ';
  static const String marketUnitedStatesLabel = 'EE. UU.';
  static const String marketMexicoLabel = 'México';
  static const String marketSelectorSemanticLabel = 'Mercado del catálogo';
  static String marketOptionSemanticLabel(String market) => 'Mercado $market';

  /// Nombre del mercado a partir de su código guardado.
  static String marketLabelOf(String code) => code == MarketConfig.mexicoCode
      ? marketMexicoLabel
      : marketUnitedStatesLabel;

  /// Atribución obligatoria (CC BY 4.0); Detalle de México y créditos la reutilizan.
  static const String conueeAttribution =
      'Fuente: CONUEE, Catálogo de rendimiento de combustible en vehículos '
      'ligeros de venta en México, vía datos.gob.mx (CC BY 4.0)';

  /// Combustible de CONUEE (normalizado) → etiqueta; lo no listado se muestra tal cual.
  static const Map<String, String> mexicoFuelLabels = {
    'gasolina': gasolineLabel,
    'diesel': dieselLabel,
    'hibrido': hybridLabel,
    'gasolina/electrico': 'Gasolina/Eléctrico',
    'electrico': electricLabel,
    'erev': 'Autonomía extendida',
    'gasolina/erev': 'Gasolina/Autonomía extendida',
  };

  /// Etiqueta de cada tipo de motorización; la clave es el nombre del enum.
  static const Map<String, String> engineKindLabels = {
    'electric': electricLabel,
    'pluginHybrid': pluginHybridLabel,
    'hybrid': hybridLabel,
    'hydrogen': hydrogenLabel,
    'diesel': dieselLabel,
    'gasoline': gasolineLabel,
    'flexFuel': flexFuelLabel,
  };

  /// Etiqueta de accesibilidad de la insignia con los tipos de motorización.
  static String engineBadgeSemanticLabel(List<String> labels) =>
      'Motorización: ${labels.join(semanticListSeparator)}';

  static const String semanticListSeparator = ', ';
  static const String consumptionUnitLabel = 'km/l combinado';
  static const String consumptionUnitShortLabel = 'km/l';
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
  static const String detailCylindersRowLabel = 'Cilindros';
  static const String detailDisplacementRowLabel = 'Cilindrada';
  static const String detailTransmissionRowLabel = 'Transmisión';
  static const String detailPowerRowLabel = 'Potencia';
  static const String detailTorqueRowLabel = 'Torque';
  static const String detailCompressionRowLabel = 'Relación de compresión';
  static const String detailCityCaption = 'ciudad (km/l)';
  static const String detailHighwayCaption = 'carretera (km/l)';
  static const String detailCombinedCaption = 'combinado (km/l)';
  static const String detailPowerCaption = 'potencia';
  static const String detailTorqueCaption = 'torque';
  static const String emissionsTitle = 'Emisiones de CO₂';
  static const String combinedCycleLabel = 'Combinado';
  static const String horsepowerUnit = 'hp';
  static const String newtonMetersUnit = 'N·m';
  static const String rpmUnit = 'rpm';
  static const String detailRecallsLabel = 'Avisos de seguridad (recalls)';
  static const String noRecallsLabel = 'Sin avisos';
  static const String recallsSheetTitle = 'Avisos de seguridad';
  static const String recallsSourceNote = 'Texto original de NHTSA, en inglés';
  static const String recallSummaryTitle = 'Resumen';
  static const String recallConsequenceTitle = 'Consecuencia';
  static const String recallRemedyTitle = 'Remedio';

  /// Conteo de recalls: singular y plural.
  static String recallsCountLabel(int count) =>
      count == 1 ? '1 aviso' : '$count avisos';

  static String recallCampaignLabel(String number) => 'Campaña $number';

  /// Etiqueta de accesibilidad de la fila de recalls.
  static String recallsRowSemanticLabel(String value) =>
      '$detailRecallsLabel: $value';

  /// Nota bajo las estrellas cuando el grupo tiene un rango de calificaciones.
  static String safetyRatedVersionsNote(int count) =>
      count == 1 ? '1 versión' : '$count versiones';

  /// Etiqueta de accesibilidad de las estrellas: una cifra o un rango.
  static String safetyRatingSemanticLabel(int min, int max, int ratedCount) =>
      min == max
      ? 'Calificación de seguridad NHTSA: $max de 5 estrellas'
      : 'Calificación de seguridad NHTSA: $min a $max de 5 estrellas, '
            '${safetyRatedVersionsNote(ratedCount)} calificadas';

  /// Cifra de estrellas: un número o el rango mínimo–máximo.
  static String safetyFigureLabel(int min, int max) =>
      min == max ? '$max' : '$min–$max';
  static const String compareWithOtherLabel = 'Comparar con otro';
  static const String addToFavoritesLabel = 'Agregar a favoritos';
  static const String backLabel = 'Volver';
  static const String versionSheetTitle = 'Elige una versión';
  static const String authorMissingLabel = 'Autor no indicado';
  static const String kmPerLiterUnit = 'km/l';
  static const String creditSeparator = ' · ';
  static const String efficiencyTitle = 'Consumo y emisiones';
  static const String cityConsumptionLabel = 'En ciudad';
  static const String highwayConsumptionLabel = 'En carretera';
  static const String co2Label = 'Emisiones de CO₂';
  static const String electricRangeLabel = 'Autonomía eléctrica';
  static const String totalRangeLabel = 'Autonomía';
  static const String electricConsumptionLabel = 'Consumo eléctrico';
  static const String hybridGasConsumptionLabel = 'Con gasolina (modo híbrido)';
  static const String fuelScoreLabel = 'Puntaje de consumo (EPA)';
  static const String emissionsScoreLabel = 'Puntaje de emisiones (EPA)';

  static String detailVersionLabel(int n) =>
      n == 1 ? 'Versión (1 disponible)' : 'Versión ($n disponibles)';

  static String brandYearLabel(String brand, int year) =>
      '${brand.toUpperCase()} · $year';

  static String photoPositionSemanticLabel(int position, int total) =>
      'Foto $position de $total';

  static String photoCreditLabel(String author, String license) =>
      'Foto: $author · $license';

  /// Consumo con un decimal, por ejemplo '14.6'.
  static String kmPerLiterFigure(double value) =>
      value.toStringAsFixed(TextConfig.kmPerLiterFractionDigits);

  static String kilometersFigure(double km) => '${km.round()} km';

  static String gramsPerKilometerFigure(double grams) =>
      '${grams.round()} g/km';

  static String kwhPer100KmFigure(double value) =>
      '${value.toStringAsFixed(TextConfig.kwhPer100KmFractionDigits)} kWh/100 km';

  static String scoreSemanticLabel(int score) =>
      '$score de ${VehicleSpecsConfig.scoreMax}';

  static String transmissionSpeedsLabel(int count) => '$count vel.';

  static String cylindersLabel(int count) => '$count cil';

  /// Cilindrada de México: cm³ tal como viene y litros, por ejemplo '1,998 cm³ (2.0 L)'.
  static String displacementCubicCentimetersLabel(int cc, double liters) {
    final grouped = cc.toString().replaceAllMapped(
      RegExp(TextConfig.thousandsBoundaryPattern),
      (_) => TextConfig.thousandsSeparator,
    );
    return '$grouped cm³ (${displacementLabel(liters)})';
  }

  /// Cifra de potencia o torque sin las rpm, por ejemplo '190 hp'.
  static String peakFigure(String text, String unit) =>
      '${text.split(ConueeConfig.powerSeparator).first} $unit';

  /// Fila de potencia o torque con las rpm si las hay, por ejemplo '190 hp @ 6000 rpm'.
  static String peakWithRpm(String text, String unit) {
    final parts = text.split(ConueeConfig.powerSeparator);
    return parts.length < 2
        ? '${parts.first} $unit'
        : '${parts.first} $unit${ConueeConfig.powerSeparator}${parts[1]} $rpmUnit';
  }

  /// Etiqueta de una versión repetida: nombre más lo que la distingue.
  static String versionLabelWith(String label, List<String> extras) =>
      [label, ...extras].join(descriptorSeparator);

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

  // Búsqueda.
  static const String searchPageTitle = 'Buscar';
  static const String searchFieldHint = 'Buscar marca o modelo';
  static const String searchFieldSemanticLabel = 'Campo de búsqueda';
  static const String searchClearSemanticLabel = 'Borrar búsqueda';
  static const String searchHomeBarLabel = 'Buscar marca o modelo';
  static const String searchHomeBarSemanticLabel =
      'Abrir la búsqueda de marcas y modelos';
  static const String searchPreparingLabel = 'Preparando la búsqueda…';
  static const String searchPartialMessage =
      'Faltaron algunas marcas en la búsqueda';
  static const String searchRecentsTitle = 'Recientes';
  static const String searchClearAllLabel = 'Borrar todo';
  static const String searchAllBrandsLabel = 'Todas';
  static const String searchAllBrandsSemanticLabel =
      'Todas las marcas, quitar el filtro';
  static const String searchIdleHint =
      'Escribe una marca o un modelo, o elige una marca arriba';
  static const String searchNoResultsSuggestion =
      'Revisa la ortografía o prueba con menos letras';
  static const String searchRemoveBrandFilterLabel = 'Quitar filtro de marca';
  static String searchResultsCountLabel(int count) =>
      count == 1 ? '1 resultado' : '$count resultados';
  static String searchResultsTruncatedLabel(int count) =>
      'Mostrando los primeros $count';
  static String searchBrandChipSemanticLabel(String brand) =>
      'Filtrar por la marca $brand';
  static String searchContextChipLabel(String market, int year) =>
      '$market · $year';
  static String searchContextSemanticLabel(String market, int year) =>
      'Buscando en $market, año $year';
  static String searchNoResultsTitle(String query) =>
      'Sin resultados para "$query"';
  static String searchNoResultsForBrandTitle(String brand) =>
      'Sin modelos de $brand';
  static String searchNoResultsScope(String market, int year) =>
      'Se buscó en $market, año $year';
  static String searchRecentSemanticLabel(String text) =>
      'Repetir la búsqueda $text';
  static String searchRecentRemoveSemanticLabel(String text) =>
      'Borrar la búsqueda reciente $text';
}
