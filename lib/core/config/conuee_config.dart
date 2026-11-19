/// Acceso, limpieza y caché del catálogo de CONUEE (datos.gob.mx, CC BY 4.0).
///
/// Las tablas se sembraron SOLO con las grafías observadas en los datos reales
/// de 2025 y 2026; lo que no esté aquí se muestra tal cual viene.
class ConueeConfig {
  const ConueeConfig._();

  static const String sourceLabel = 'conuee';
  static const int maxConcurrentRequests = 4;

  // Los años ofrecidos salen del catálogo (package_show); solo se fija el de inicio.
  static const int defaultYear = 2025;

  // Rutas relativas a la URL base y parámetros de CKAN.
  static const String packageShowPath = '/package_show';
  static const String datastoreSearchPath = '/datastore_search';
  static const String packageIdParameter = 'id';
  static const String resourceIdParameter = 'resource_id';
  static const String limitParameter = 'limit';
  static const String offsetParameter = 'offset';

  // Mensajes técnicos de las fallas.
  static const String unexpectedShapeMessage =
      'La respuesta de CONUEE no tiene la forma esperada';
  static const String emptyYearsMessage =
      'CONUEE no tiene años con catálogo disponible';
  static const String yearNotOfferedMessage =
      'El año no está disponible en el catálogo de CONUEE';

  // Tope de filas por petición del datastore.
  static const int maxRecordsPerRequest = 32000;

  // Claves de la respuesta CKAN.
  static const String resultKey = 'result';
  static const String resourcesKey = 'resources';
  static const String resourceIdKey = 'id';
  static const String resourceNameKey = 'name';
  static const String datastoreActiveKey = 'datastore_active';
  static const String recordsKey = 'records';
  static const String totalKey = 'total';

  // El año del recurso es el número entre paréntesis al final de su nombre.
  static const String resourceYearPattern = r'\((\d{4})\)\s*$';

  // Campos de cada fila del datastore.
  static const String rowIdKey = '_id';
  static const String brandKey = 'marca';
  static const String modelKey = 'modelo';
  static const String cityKmPerLiterKey = 'rendimiento_km_l_ciudad';
  static const String highwayKmPerLiterKey = 'rendimiento_km_l_carretera';
  static const String combinedKmPerLiterKey = 'rendimiento_km_l_combinado';
  static const String cityCo2Key = 'emisiones_co2_g_km_ciudad';
  static const String highwayCo2Key = 'emisiones_co2_g_km_carretera';
  static const String combinedCo2Key = 'emisiones_co2_g_km_combinado';
  static const String fuelTypeKey = 'tipo_combustible';
  static const String cylindersKey = 'numero_cilindros';
  static const String displacementKey = 'desplazamiento_cm3';
  static const String transmissionKey = 'tipo_transmision';
  static const String powerKey = 'potencia_maxima_hp_rpm';
  static const String torqueKey = 'torque_maximo_n_m_rpm';

  // Claves versionadas: subir la versión invalida lo guardado.
  static const String cacheKeyVersion = 'v2';
  static const String cacheKeySeparator = '|';
  static const String yearsKeyKind = 'years';
  static const String yearKeyKind = 'year';
  static const int cacheTimeToLiveDays = 7;

  // Claves del JSON guardado en la caché.
  static const String payloadYearKey = 'year';
  static const String payloadResourceIdKey = 'resourceId';
  static const String payloadYearsKey = 'years';
  static const String payloadVehiclesKey = 'vehicles';
  static const String payloadRawRowCountKey = 'rawRows';
  static const String payloadDroppedKmKey = 'droppedKm';
  static const String payloadIdKey = 'id';
  static const String payloadBrandKey = 'brand';
  static const String payloadRawModelKey = 'rawModel';
  static const String payloadModelKey = 'model';
  static const String payloadEngineKindKey = 'engineKind';
  static const String payloadFuelTypeKey = 'fuelType';
  static const String payloadCityKmKey = 'cityKm';
  static const String payloadHighwayKmKey = 'highwayKm';
  static const String payloadCombinedKmKey = 'combinedKm';
  static const String payloadCityCo2Key = 'cityCo2';
  static const String payloadHighwayCo2Key = 'highwayCo2';
  static const String payloadCombinedCo2Key = 'combinedCo2';
  static const String payloadCylindersKey = 'cylinders';
  static const String payloadDisplacementKey = 'displacement';
  static const String payloadTransmissionKey = 'transmission';
  static const String payloadPowerKey = 'power';
  static const String payloadTorqueKey = 'torque';

  // Potencia y torque: solo se aceptan estas formas inequívocas.
  static const String powerValueOnlyPattern = r'^(\d+(?:\.\d+)?)$';
  static const String powerMarkerPattern =
      r'^(\d+(?:\.\d+)?)\s*@\s*(?:max|peak)$';
  static const String powerRpmPattern =
      r'^(\d+(?:\.\d+)?)\s*@\s*(\d[\d,]*)(?:\s*[-~]\s*(\d[\d,]*))?$';
  static const String powerSeparator = ' @ ';
  static const String rpmRangeSeparator = '-';
  static const String rpmThousandsSeparator = ',';

  // En eléctricos, 0 y 1.0 de km/l y de CO2 son relleno, no datos.
  static const List<double> electricFillerValues = [0.0, 1.0];

  // Rango plausible de km/l en combustión e híbridos: lo observado va de 6.78 a
  // 31.31 una vez quitados los enchufables (que llegan a 50.3).
  static const double minPlausibleKmPerLiter = 3.0;
  static const double maxPlausibleKmPerLiter = 40.0;

  // Palabras del modelo que delatan un enchufable o de autonomía extendida
  // (DM-i y DM-O son los enchufables de BYD).
  static const String pluginModelPattern =
      r'(?:^|[^A-Z0-9])(?:PHEV|REEV|E-REV|PLUG-IN|DM-I|DM-O)(?:[^A-Z0-9]|$)';

  // E-Rev con este texto en el nombre es el E-POWER de Nissan: el motor de
  // gasolina solo genera y no se enchufa, así que cuenta como híbrido.
  static const String eRevHybridModelMarker = 'E-POWER';
  static const List<String> rangeExtenderFuelKeys = ['erev', 'gasolina/erev'];

  // Combustible normalizado → nombre del EngineKind; E-Rev no tiene km/l comparable.
  static const Map<String, String> fuelEngineKinds = {
    'gasolina': 'gasoline',
    'diesel': 'diesel',
    'hibrido': 'hybrid',
    'gasolina/electrico': 'hybrid',
    'electrico': 'electric',
    'erev': 'pluginHybrid',
    'gasolina/erev': 'pluginHybrid',
  };

  // Texto que significa "sin dato" en cilindros y transmisión (normalizado).
  static const List<String> noDataValues = [
    '0',
    '0l',
    'sindato',
    'noaplica',
    '',
  ];

  // Cilindros: grafía normalizada (sin espacios, guiones ni acentos) → etiqueta.
  static const Map<String, String> cylinderLabels = {
    '3l': '3 en línea',
    'l3': '3 en línea',
    'i3': '3 en línea',
    '3i': '3 en línea',
    '3enlinea': '3 en línea',
    '4l': '4 en línea',
    'l4': '4 en línea',
    'i4': '4 en línea',
    '4i': '4 en línea',
    '4enlinea': '4 en línea',
    '4enl': '4 en línea',
    '5l': '5 en línea',
    '6l': '6 en línea',
    '6enlinea': '6 en línea',
    'v6': 'V6',
    '6v': 'V6',
    '6env': 'V6',
    'v8': 'V8',
    '8v': 'V8',
    '8env': 'V8',
    'b4': '4 bóxer',
    'b6': '6 bóxer',
    // Con asterisco se sabe el número, no la disposición.
    '3*': '3',
    '4*': '4',
    '5*': '5',
  };

  // Transmisión: grafía normalizada → etiqueta.
  static const Map<String, String> transmissionLabels = {
    'automatica': 'Automática',
    'automatico': 'Automática',
    'aut0matica': 'Automática',
    'at': 'Automática',
    't/a': 'Automática',
    '4at': 'Automática de 4 velocidades',
    '6at': 'Automática de 6 velocidades',
    '8at': 'Automática de 8 velocidades',
    '9at': 'Automática de 9 velocidades',
    '10at': 'Automática de 10 velocidades',
    'automaticasecuencial': 'Automática secuencial',
    'manual': 'Manual',
    'mecanica': 'Manual',
    'mt': 'Manual',
    '5mt': 'Manual de 5 velocidades',
    'mt5': 'Manual de 5 velocidades',
    '6mt': 'Manual de 6 velocidades',
    'cvt': 'CVT',
    'mcvt': 'MCVT',
    'ecvt': 'e-CVT',
    'ivt': 'IVT',
    'dct': 'Doble embrague (DCT)',
    'dht': 'DHT',
    'electrica': 'Eléctrica',
    'directa': 'Directa',
  };
}
