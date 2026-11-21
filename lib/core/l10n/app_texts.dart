import 'package:cars_wheels_app/core/config/config.dart';

/// Textos para el usuario.
class AppTexts {
  const AppTexts._();

  static const String emptyStateTitle = 'Sin registros';
  static const String errorStateTitle = 'No se pudo cargar la información';
  static const String retryButtonLabel = 'Reintentar';
  // Conexión: banda bajo el encabezado y estados sin red.
  static const String offlineBandLabel = 'Sin conexión · mostrando lo guardado';
  static const String offlineFavoritesBandLabel =
      'Sin conexión · tus favoritos están guardados en el teléfono';
  static const String onlineRestoredLabel = 'Conexión restablecida';
  static const String offlineStateTitle = 'Sin conexión a internet';
  static const String offlineStateBody =
      'Revisa tu conexión y vuelve a intentarlo. Lo que ya guardaste sigue disponible.';
  static const String offlineUnavailableLabel = 'No disponible sin conexión';
  static const String offlineDetailNotice =
      'Algunos datos, como calificaciones de seguridad y retiros, no están guardados y aparecerán al volver la conexión.';
  static const String refreshFailedLabel = 'No se pudo actualizar';
  static const String referencePhotoLabel = 'Foto de referencia';
  static const String loaderSemanticLabel = 'Cargando';
  static const String photoLoadingLabel = 'Cargando foto…';
  static const String noPhotoTitle = 'Aún no hay foto de este modelo';
  static const String noPhotoSemanticLabel = 'Sin foto';
  static const String expandPhotoSemanticLabel = 'Ver foto en grande';
  static const String photoViewerCloseLabel = 'Cerrar';
  static const String homePageTitle = 'Pantalla Inicio';
  static const String comparePageTitle = 'Comparar';
  static const String favoritesPageTitle = 'Favoritos';
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
  static const String marketUnitedStatesName = 'Estados Unidos';
  static const String marketMexicoName = 'México';
  static const String switchToMexicoLabel = 'Cambiar a México';
  static const String switchToUnitedStatesLabel = 'Cambiar a Estados Unidos';
  static const String pickYearLabel = 'Elegir año';

  /// Nombre del mercado a partir de su código guardado.
  static String marketLabelOf(String code) => code == MarketConfig.mexicoCode
      ? marketMexicoLabel
      : marketUnitedStatesLabel;

  // Código corto de la opción del selector y su etiqueta accesible.
  static const String marketUnitedStatesCodeLabel = 'EE. UU.';
  static const String marketMexicoCodeLabel = 'MX';
  static String marketCodeLabelOf(String code) =>
      code == MarketConfig.mexicoCode
      ? marketMexicoCodeLabel
      : marketUnitedStatesCodeLabel;
  static String marketOptionSemanticLabel(
    String code, {
    required bool selected,
  }) => 'Mercado, ${marketLabelOf(code)}${selected ? ' seleccionado' : ''}';

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
  static const String ellipsis = '…';

  // Pantalla Detalle.
  static const String detailConsumptionCaption = 'consumo combinado';
  static const String detailPowertrainCaption = 'tipo de motor';
  static const String detailAnnualCostCaption = 'combustible al año (USD)';
  static const String detailSafetyCaption = 'seguridad NHTSA';
  static const String detailClassRowLabel = 'Clase';
  static const String detailFuelRowLabel = 'Combustible';
  static const String detailDriveRowLabel = 'Tracción';
  static const String detailAspirationRowLabel = 'Aspiración';
  static const String aspirationTurbo = 'Turbo';
  static const String aspirationSupercharger = 'Supercargador';
  static const String aspirationBoth = 'Turbo y supercargador';
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
  static const String removeFromFavoritesLabel = 'Quitar de favoritos';
  static String favoriteAddSemanticLabel(String name) =>
      'Guardar $name en favoritos';
  static String favoriteRemoveSemanticLabel(String name) =>
      'Quitar $name de favoritos';
  static const String favoriteSavedMessage = 'Guardado en favoritos';
  static const String favoriteRemovedMessage = 'Quitado de favoritos';
  static String favoriteRemovedNamedMessage(String name) => 'Quitaste $name';
  static const String favoriteUndoLabel = 'Deshacer';
  static String favoritesCountLabel(int count) =>
      count == 1 ? '1 guardado' : '$count guardados';
  static const String favoritesFilterAll = 'Todos';
  static const String favoritesFilterSemanticLabel = 'Filtrar por mercado';
  static String favoriteMarketYearLabel(String flag, int year) => '$flag $year';
  static String favoriteCardSemanticLabel(String name, String? label) =>
      label == null ? name : '$name, $label';
  static const String favoritesEmptyTitle = 'Aún no tienes favoritos';
  static const String favoritesEmptyBody =
      'Toca el corazón de un auto para guardarlo aquí';
  static const String favoritesExploreLabel = 'Explorar autos';
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
      license.trim().isEmpty ? 'Foto: $author' : 'Foto: $author · $license';
  static const String photoCreditSemanticHint = 'Abre la fuente de la foto';
  static const String photoSourceCopiedMessage = 'Enlace de la fuente copiado';

  // Ficha técnica flotante de Detalle.
  static const String specSheetTitle = 'Ficha técnica';
  static const String specSheetOpenLabel = 'Abrir la ficha técnica';
  static const String specSheetCloseLabel = 'Cerrar la ficha técnica';

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
  static const String searchRecentsTitle = 'Recientes';
  static const String searchClearAllLabel = 'Borrar todo';
  static const String searchIdleHint =
      'Escribe una marca o un modelo, o explora por marca';
  static const String searchExploreByBrandTitle = 'Explorar por marca';
  static const String searchBrandMatchesTitle = 'Marcas';
  static const String searchScopePrefix = 'Buscando en';
  static const String searchOtherBrandsTitle = 'En otras marcas';
  static const String scrollToTopLabel = 'Subir al inicio';
  static const String searchOtherYearsTitle = 'También en otros años';
  static const String searchOtherYearsPrompt = '¿No es el que buscas?';
  static const String searchOtherYearsAction = 'Buscar en otros años';
  static const String searchOtherYearsCancel = 'Cancelar';
  static const String searchOtherYearsNone =
      'Sin coincidencias en los años cercanos';
  static const String searchOtherYearsFailed =
      'No se pudo buscar en otros años';
  static const String searchNoResultsSuggestion =
      'Revisa la ortografía o prueba con menos letras';
  static String searchResultsCountLabel(int count) =>
      count == 1 ? '1 resultado' : '$count resultados';
  static String searchResultsTruncatedLabel(int count) =>
      'Mostrando los primeros $count';
  static String searchBrandChipSemanticLabel(String brand) =>
      'Buscar en la marca $brand';
  static String searchScopeSemanticLabel(String brand) =>
      'Buscando en la marca $brand';
  static String searchScopeClearSemanticLabel(String brand) =>
      'Quitar la marca $brand de la búsqueda';
  static String searchInBrandTitle(String brand) => 'En $brand';
  static String searchNoResultsInBrand(String brand) =>
      'Sin resultados en $brand';
  static String searchSuggestionSemanticLabel(String text) =>
      'Buscar $text en su lugar';
  static String searchOtherYearsProgressLabel(List<int> years) =>
      'Buscando en ${years.join(", ")}…';
  static String searchOtherYearRowSemanticLabel(
    String group,
    String brand,
    int year,
  ) => '$group, $brand, año $year';
  static String searchNoResultsTitle(String query) =>
      'Sin resultados para "$query"';
  static String searchNoResultsForBrandTitle(String brand) =>
      'Sin modelos de $brand';
  static String searchNoResultsScope(String market, int year) =>
      'Se buscó en $market, año $year';
  // Filtros de la búsqueda.
  static const String searchFiltersTitle = 'Filtrar resultados';
  static const String searchFiltersButtonLabel = 'Filtrar resultados';
  static const String searchFiltersEngineTitle = 'Motorización';
  static const String searchFiltersBrandTitle = 'Marca';
  static const String searchFiltersSortTitle = 'Ordenar';
  static const String searchFiltersEngineElectric = 'Eléctrico';
  static const String searchFiltersEngineHybrid = 'Híbrido';
  static const String searchFiltersEnginePluginHybrid = 'Enchufable';
  static const String searchFiltersEngineCombustion = 'Combustión';
  static const String searchFiltersSortAlphabetical = 'A–Z';
  static const String searchFiltersSortMostEfficient = 'Más eficiente';
  static const String searchFiltersSortEfficiencyHelp =
      'Los eléctricos y los que no tienen dato van al final';
  static const String searchFiltersClear = 'Limpiar';
  static const String searchFiltersClearAll = 'Limpiar filtros';
  static const String searchFiltersEmptyTitle =
      'Ningún resultado con estos filtros';
  static const String searchFiltersEmptyHint =
      'Quita algún filtro para ver más modelos';
  static const String searchFiltersAlsoOtherYears =
      'Los filtros también se aplican a otros años';
  static const String searchFiltersSummarySeparator = ' · ';
  static const String searchActiveFiltersClear = 'Limpiar';
  static const String searchClearEverything = 'Limpiar todo';
  static const String searchOtherYearsNoFilterMatches =
      'Sin coincidencias con los filtros';
  static String searchActiveFiltersLabel(int count) =>
      'Filtros activos ($count)';
  static String searchFiltersEmptyActive(String filters) =>
      'Filtros activos: $filters';
  static String searchIndexingNotice(int done, int total) =>
      'Indexando… $done de $total marcas · los resultados se completan al terminar';
  static String searchFiltersButtonSemanticLabel(int active) => active == 0
      ? searchFiltersButtonLabel
      : '$searchFiltersButtonLabel, $active activos';
  static String searchFilterNumberLabel(int number) => '$number';
  static String searchFiltersApplyLabel(int count) =>
      count == 1 ? 'Ver 1 resultado' : 'Ver $count resultados';
  static String searchFiltersAnalyzingLabel(int done, int total) =>
      'Analizando $done de $total…';
  static String searchFiltersPendingLabel(int count) => count == 1
      ? 'Falta 1 resultado por analizar'
      : 'Faltan $count resultados por analizar';
  static String searchFilterChipSemanticLabel(String label, int? count) =>
      count == null ? label : '$label, ${searchResultsCountLabel(count)}';

  static String searchRecentSemanticLabel(String text) =>
      'Repetir la búsqueda $text';
  static String searchRecentRemoveSemanticLabel(String text) =>
      'Borrar la búsqueda reciente $text';

  // Comparar.
  static String compareEmptyTitle(int max) => 'Compara hasta $max vehículos';
  static const String compareEmptyBody = compareOneVehicleBody;
  static const String compareOneVehicleBody =
      'Agrega al menos 2 vehículos (hasta 3) para comparar';
  static const String compareAddVehicleLabel = 'Agregar vehículo';
  static const String compareClearLabel = 'Limpiar';
  static const String compareEmptySlotSemanticLabel =
      'Espacio libre, toca para agregar un vehículo';
  static const String compareAlreadyAddedNotice = 'Ya está en la comparación';
  static const String compareFullNotice =
      'El comparador está lleno: quita un vehículo para agregar otro';
  static String compareAddedNotice(String name) => 'Agregaste $name';
  static String compareReplacedNotice(String removed, String added) =>
      'Reemplazaste $removed por $added';
  static String compareStartedNewNotice(String name) =>
      'Comparación nueva con $name';
  static const String compareTableTitle = 'Comparativa';
  static const String compareTableSupport =
      'Lo resaltado es el mejor valor en consumo, emisiones, costo anual y seguridad.';
  static const String compareSectionConsumption = 'Consumo';
  static const String compareSectionEngine = 'Motor y transmisión';
  static const String compareSectionSafetyCost = 'Seguridad y costo';
  static const String compareRowCombinedConsumption =
      'Consumo combinado (km/l)';
  static const String compareRowCityConsumption = 'Consumo en ciudad (km/l)';
  static const String compareRowHighwayConsumption =
      'Consumo en carretera (km/l)';
  static const String compareRowEngine = 'Motorización';
  static const String compareRowAnnualCost = 'Combustible al año (USD)';
  static const String compareRowSafety = 'Seguridad NHTSA';
  static const String compareEngineCombustionLabel = 'Combustión';
  static String compareStarsValue(int stars) =>
      '$stars de ${UiConfig.safetyStarCount}';
  static const String compareColumnLoadFailed = 'No se pudo cargar';
  static const String compareVersionDefaultLabel = 'Predeterminada';
  static const String compareVersionDefaultCaption =
      'La que se muestra al agregar el vehículo';
  static const String compareVersionSheetEmpty =
      'Este modelo no tiene versiones disponibles';
  static String compareVersionPillSemanticLabel(String name, String version) =>
      'Versión de $name: $version. Toca para cambiarla';
  static String compareColumnHeaderLabel(String brand, String model) =>
      '$brand $model';
  static String compareCellSemanticLabel(
    String row,
    String vehicle,
    String value, {
    required bool isBest,
  }) =>
      isBest ? '$row, $vehicle: $value, mejor valor' : '$row, $vehicle: $value';
  static const String comparePickerTitle = 'Agregar vehículo';
  static const String comparePickerCloseSemanticLabel = 'Cerrar el selector';
  static const String comparePickerAddLabel = 'Comparar';
  static const String comparePickerAddedLabel = 'En la comparación';
  static String comparePickerAddedSemanticLabel(String name) =>
      '$name ya está en la comparación, toca para ver opciones';
  static String comparePickerAddSemanticLabel(String name) =>
      'Agregar $name a la comparación';
  static const String comparePickerHint =
      'Modo comparar: toca "Comparar" en el auto que quieras agregar. Tocar la tarjeta abre su detalle.';
  static const String comparePickerHintDismissSemanticLabel = 'Cerrar el aviso';
  static const String closeLabel = 'Cerrar';

  static const String cancelLabel = 'Cancelar';

  // Limpiar con confirmación.
  static const String compareClearDialogTitle = '¿Limpiar la comparación?';
  static String compareClearDialogBody(int count) =>
      'Se quitarán los $count vehículos';

  // Ayuda de Comparar.
  static const String compareHelpButtonLabel = '¿Cómo funciona?';
  static const String compareHelpSheetTitle = '¿Cómo funciona?';
  static const List<String> compareHelpSteps = [
    'Agrega 2 o 3 vehículos con el botón +.',
    'Elige la versión de cada uno.',
    'Lo resaltado en amarillo suave es el mejor valor de cada fila.',
    'Toca el botón de la gráfica para verlo de un vistazo.',
  ];
  static String compareHelpStepNumber(int number) => '$number';
  static const String compareHelpFootnote = '"Limpiar" quita todo.';

  // Pastilla y hoja de versiones.
  static const String compareVersionPillOverline = 'Versión';
  static const String compareVersionPillLoadingValue = 'Cargando…';
  static String compareVersionSheetTitle(String brand, String model) =>
      '$brand $model';
  static const String compareVersionSheetSubtitle = 'Elige una versión';

  // Gráfica visual.
  static const String compareChartButtonSemanticLabel =
      'Ver la comparación visual';
  static const String compareChartTitle = 'Comparación visual';
  static const String compareChartConsumption = 'Consumo';
  static const String compareChartCo2 = 'CO₂';
  static const String compareChartAnnualCost = 'Costo anual';
  static const String compareChartSafety = 'NHTSA';
  static String compareChartKmPerLiterValue(String figure) => '$figure km/l';
  static const String compareChartHintHigher = 'Gana la columna más alta';
  static const String compareChartHintLower = 'Gana la columna más baja';
  static String compareChartMetricSemanticLabel(String label) =>
      'Métrica: $label';
  static String compareChartBarSemanticLabel(
    String vehicle,
    String value, {
    required bool isBest,
  }) => isBest ? '$vehicle: $value, mejor valor' : '$vehicle: $value';
  static String compareRemoveSemanticLabel(String name) =>
      'Quitar $name del comparador';
  static String compareSlotsCountLabel(int count, int max) =>
      '$count de $max vehículos';

  // Menú de "Comparar" cuando el auto ya está o el comparador está lleno.
  static String compareActionsAlreadyTitle(String name) =>
      '$name ya está en la comparación';
  static const String compareActionsFullTitle = 'El comparador está lleno';
  static const String compareActionsBody = '¿Qué quieres hacer?';
  static const String compareActionsSubstituteLabel =
      'Sustituir un auto de la comparación';
  static const String compareActionsOtherModelLabel =
      'Comparar con otro modelo';
  static const String compareActionsBackLabel = 'Volver';
  static const String compareSubstituteTitle = 'Elige cuál sustituir';
  static String compareSubstituteBody(String name) =>
      'Se reemplazará por $name.';
  static String compareSubstituteYearFlag(int year, String flag) =>
      '$year · $flag';
  static String compareSubstituteRowSemanticLabel(
    String name,
    int year,
    String market,
  ) => 'Sustituir $name, $year, $market';

  // Burbuja que explica qué mide cada métrica de la gráfica.
  static const String compareChartInfoConsumption =
      'Consumo: cuántos kilómetros recorre con un litro. Más es mejor.';
  static const String compareChartInfoCo2 =
      'CO₂: gramos de dióxido de carbono que emite por kilómetro. Menos es mejor.';
  static const String compareChartInfoAnnualCost =
      'Costo anual: lo que gasta en combustible al año, en dólares. Menos es mejor.';
  static const String compareChartInfoSafety =
      'NHTSA: calificación de seguridad en estrellas. Más es mejor.';
  static const String compareChartInfoCloseSemanticLabel =
      'Cerrar la explicación';
  static const String compareChartInfoOpenSemanticLabel =
      'Qué mide esta métrica';

  // Aviso cuando la marca activa no tiene registros en el año elegido.
  static String yearWithoutDataNotice(String brand, int year) =>
      '$brand no tiene registros para $year';

  // Aviso al cambiar de mercado desde la píldora.
  static String marketChangedTitle(String market) => 'Cambiaste a $market';
  static String marketChangedBody(String market, int year) =>
      'Ahora ves datos de $market · $year';
  static String marketChangedCompareBody(String market) =>
      'Ahora ves la comparación de $market';

  // Sugerencias de Buscar con el campo vacío.
  static const String searchPicksTitle = 'Sugerencias para ti';
  static String searchPickSemanticLabel(String brand, String model) =>
      'Ver $brand $model';

  // "¿Quisiste decir…?": línea sutil con el nombre en negrita.
  static const String searchDidYouMeanLead = '¿Quisiste decir ';
  static const String searchDidYouMeanTail = '?';
  static String searchSuggestionLabel(String text) =>
      '$searchDidYouMeanLead$text$searchDidYouMeanTail';
}
