/// Rutas, claves JSON, vigencias y alias de las APIs de seguridad de NHTSA.
class SafetyConfig {
  const SafetyConfig._();

  static const String nhtsaSourceLabel = 'nhtsa';
  static const int maxConcurrentRequests = 10;

  // Rutas relativas a la URL base de api.nhtsa.gov.
  static const String yearPlaceholder = '{year}';
  static const String makePlaceholder = '{make}';
  static const String modelPlaceholder = '{model}';
  static const String idPlaceholder = '{id}';
  static const String ratingsModelsPathTemplate =
      '/SafetyRatings/modelyear/{year}/make/{make}';
  static const String ratingsVariantsPathTemplate =
      '/SafetyRatings/modelyear/{year}/make/{make}/model/{model}';
  static const String ratingsVehiclePathTemplate =
      '/SafetyRatings/VehicleId/{id}';
  static const String recallsPath = '/recalls/recallsByVehicle';
  static const String recallsMakeParameter = 'make';
  static const String recallsModelParameter = 'model';
  static const String recallsYearParameter = 'modelYear';

  // Ruta relativa a la URL base de vPIC y su parámetro de formato.
  static const String vpicModelsPathTemplate =
      '/GetModelsForMakeYear/make/{make}/modelyear/{year}';
  static const String vpicFormatParameter = 'format';
  static const String vpicFormatValue = 'json';

  // Claves JSON de las calificaciones y de vPIC.
  static const String ratingsResultsKey = 'Results';
  static const String ratingsModelKey = 'Model';
  static const String ratingsVehicleIdKey = 'VehicleId';
  static const String overallRatingKey = 'OverallRating';
  static const String frontRatingKey = 'OverallFrontCrashRating';
  static const String sideRatingKey = 'OverallSideCrashRating';
  static const String rolloverRatingKey = 'RolloverRating';
  static const String vpicModelNameKey = 'Model_Name';

  // Claves JSON de los recalls; la lista viene en minúscula.
  static const String recallsResultsKey = 'results';
  static const String recallsCountKey = 'Count';
  static const String recallCampaignKey = 'NHTSACampaignNumber';
  static const String recallDateKey = 'ReportReceivedDate';
  static const String recallComponentKey = 'Component';
  static const String recallSummaryKey = 'Summary';
  static const String recallConsequenceKey = 'Consequence';
  static const String recallRemedyKey = 'Remedy';

  // Sin recalls, la API responde HTTP 400 con Count 0.
  static const int noRecallsStatus = 400;

  // Escala de estrellas de NHTSA; "Not Rated" y vacíos son dato ausente.
  static const int ratingMin = 1;
  static const int ratingMax = 5;

  // VehicleId 0 es un modelo listado sin calificación publicada.
  static const int unratedVehicleId = 0;

  // Fecha de recall dd/MM/yyyy; se comprobó con días mayores a 12.
  static const String recallDatePattern = r'^(\d{2})/(\d{2})/(\d{4})$';

  // Claves versionadas: subir la versión invalida lo guardado (v2: alias nuevos).
  static const String cacheKeyVersion = 'v2';
  static const String cacheKeySeparator = '|';
  static const String ratingsKeyKind = 'ratings';
  static const String recallsKeyKind = 'recalls';
  static const String ratingsNoMatchKeyKind = 'ratings-nomatch';
  static const String recallsNoMatchKeyKind = 'recalls-nomatch';

  // Vigencias provisionales en días.
  static const int ratingsTimeToLiveDays = 30;
  static const int recallsTimeToLiveDays = 7;
  static const int noMatchTimeToLiveDays = 3;

  // Claves del JSON guardado en las cachés.
  static const String payloadMinOverallKey = 'minOverall';
  static const String payloadMaxOverallKey = 'maxOverall';
  static const String payloadRatedCountKey = 'ratedCount';
  static const String payloadCountKey = 'count';
  static const String payloadRecallsKey = 'recalls';
  static const String payloadCampaignKey = 'campaign';
  static const String payloadDateKey = 'date';
  static const String payloadComponentKey = 'component';
  static const String payloadSummaryKey = 'summary';
  static const String payloadConsequenceKey = 'consequence';
  static const String payloadRemedyKey = 'remedy';

  // Alias por marca y modelo normalizados ("marca|modelo") hacia nombres de
  // NHTSA; solo casos evidentes comprobados con la API de 2024.
  static const String aliasKeySeparator = '|';
  static const Map<String, List<String>> modelAliases = {
    'honda|civic': ['CIVIC SEDAN', 'CIVIC HATCHBACK'],
    'tesla|models': ['MODEL S (ALL VARIANTS)'],
    'tesla|modelx': ['MODEL X (ALL VARIANTS)'],
    'tesla|modely': ['MODEL Y (All Variants)'],
    'ford|f150': [
      'F-150 (REGULAR CAB) GAS',
      'F-150 (SUPER CAB) GAS',
      'F-150 (SUPER CREW) GAS',
      'F-150 (SUPER CREW) HEV',
    ],
    'bmw|330i': ['3 SERIES SEDAN'],
    'mercedesbenz|c300': ['C-CLASS'],
    // Híbridos únicos en FuelEconomy 2024 (atvType Hybrid) y en NHTSA.
    'toyota|crown': ['CROWN HYBRID'],
    'toyota|sequoia': ['SEQUOIA HYBRID'],
    'toyota|sienna': ['SIENNA HYBRID'],
    'toyota|venza': ['VENZA HYBRID'],
    'honda|prologue': ['PROLOGUE EV'],
    // NHTSA solo lista la versión SuperCrew de 2024.
    'ford|ranger': ['RANGER (SUPER CREW)'],
    // NHTSA antepone la familia: Jetta GLI y Golf GTI.
    'volkswagen|gli': ['JETTA GLI'],
    'volkswagen|gti': ['GOLF GTI'],
    // Todas las variantes de FuelEconomy comparten la carrocería del nombre NHTSA.
    'bmw|m2': ['M2 COUPE'],
    'bmw|m3': ['M3 SEDAN'],
    'bmw|i4': ['I4 GRAN COUPE'],
    'bmw|i7': ['I7 SEDAN'],
    'audi|s6': ['S6 SEDAN'],
    'audi|rs6': ['RS 6 AVANT'],
    // vPIC y NHTSA solo listan la versión larga (LWB) en 2024.
    'audi|a8': ['A8 LWB'],
    'audi|s8': ['S8 LWB'],
  };
}
