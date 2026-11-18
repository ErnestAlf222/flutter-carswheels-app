// Respuestas reales de NHTSA (consultadas en 2026) reducidas a lo necesario.

/// Modelos con calificaciones de Toyota 2024.
const List<String> toyota2024Models = [
  'CAMRY',
  'CAMRY HYBRID',
  'COROLLA',
  'COROLLA CROSS',
  'GR COROLLA',
];

/// Modelos con calificaciones de Honda 2024.
const List<String> honda2024Models = [
  'CIVIC HATCHBACK',
  'CIVIC HATCHBACK TYPE R',
  'CIVIC SEDAN',
  'CIVIC SEDAN SI',
];

/// Modelos con calificaciones de Chevrolet 2024.
const List<String> chevrolet2024Models = [
  'SILVERADO 1500',
  'SILVERADO 2500',
  'SILVERADO EV',
];

/// Modelos con calificaciones de Ford 2024.
const List<String> ford2024Models = [
  'F-150 (REGULAR CAB) GAS',
  'F-150 (SUPER CAB) GAS',
  'F-150 (SUPER CREW) GAS',
  'F-150 (SUPER CREW) HEV',
  'F-150 (SUPER CREW) LIGHTNING BEV',
  'TRANSIT HIGH ROOF 15 PASS',
];

/// Modelos con calificaciones de Tesla 2024.
const List<String> tesla2024Models = [
  'MODEL 3',
  'MODEL S (ALL VARIANTS)',
  'MODEL X (ALL VARIANTS)',
  'MODEL Y (All Variants)',
  'MODEL Y RWD',
];

/// Modelos de vPIC para Chevrolet 2024 (con repetidos, como los entrega).
const List<String> vpicChevrolet2024Models = [
  'Silverado',
  'Silverado',
  'Silverado HD',
  'Silverado HD',
];

/// Modelos de vPIC para Aston Martin 2027.
const List<String> vpicAstonMartin2027Models = ['DBX'];

/// Segundo paso de un modelo (BMW X5 2024).
const Map<String, dynamic> bmwX5VariantsJson = {
  'Count': 2,
  'Message': 'Results returned successfully',
  'Results': [
    {'VehicleDescription': '2024 BMW X5 SUV AWD', 'VehicleId': 19227},
    {'VehicleDescription': '2024 BMW X5 SUV RWD', 'VehicleId': 19226},
  ],
};

/// Modelo listado de 2027 sin calificación publicada (VehicleId 0).
const Map<String, dynamic> jeep2027ModelsJson = {
  'Count': 2,
  'Message': 'Results returned successfully',
  'Results': [
    {'ModelYear': 2027, 'Make': 'JEEP', 'Model': 'CHEROKEE', 'VehicleId': 0},
    {
      'ModelYear': 2027,
      'Make': 'JEEP',
      'Model': 'GRAND CHEROKEE',
      'VehicleId': 0,
    },
  ],
};

/// Tercer paso: BMW X5 AWD con las cuatro calificaciones.
const Map<String, dynamic> bmwX5AwdRatingJson = {
  'Count': 1,
  'Results': [
    {
      'VehicleId': 19227,
      'OverallRating': '4',
      'OverallFrontCrashRating': '4',
      'OverallSideCrashRating': '5',
      'RolloverRating': '4',
    },
  ],
};

/// Tercer paso: BMW X5 RWD, con general y vuelco sin calificar.
const Map<String, dynamic> bmwX5RwdRatingJson = {
  'Count': 1,
  'Results': [
    {
      'VehicleId': 19226,
      'OverallRating': 'Not Rated',
      'OverallFrontCrashRating': '4',
      'OverallSideCrashRating': '5',
      'RolloverRating': 'Not Rated',
    },
  ],
};

/// Tercer paso: Tesla Model 3 2024, todo sin calificar.
const Map<String, dynamic> tesla3RatingJson = {
  'Count': 1,
  'Results': [
    {
      'VehicleId': 19950,
      'OverallRating': 'Not Rated',
      'OverallFrontCrashRating': 'Not Rated',
      'OverallSideCrashRating': 'Not Rated',
      'RolloverRating': 'Not Rated',
    },
  ],
};

/// Recalls de Toyota Camry 2024 (la fecha viene dd/MM/yyyy).
const Map<String, dynamic> camryRecallsJson = {
  'Count': 1,
  'Message': 'Results returned successfully',
  'results': [
    {
      'Manufacturer': 'Toyota Motor Engineering & Manufacturing',
      'NHTSACampaignNumber': '24V128000',
      'parkIt': false,
      'parkOutSide': false,
      'overTheAirUpdate': false,
      'ReportReceivedDate': '22/02/2024',
      'Component': 'SEATS',
      'Summary': 'Toyota is recalling certain 2023-2024 Camry vehicles.',
      'Consequence': 'A head restraint bracket may not restrain an occupant.',
      'Remedy': 'Dealers will replace the rear seat-back frame.',
      'Notes': '',
      'ModelYear': '2024',
      'Make': 'TOYOTA',
      'Model': 'CAMRY',
    },
  ],
};

/// Cuerpo del HTTP 400 que NHTSA responde cuando no hay recalls.
const Map<String, dynamic> noRecallsBodyJson = {
  'Count': 0,
  'Message': 'Results returned successfully',
  'results': <Object?>[],
};

/// Modelos reales de Volkswagen 2024 en la API de calificaciones de NHTSA.
const List<String> volkswagen2024Models = [
  'ATLAS',
  'ATLAS CROSS SPORT',
  'GOLF GTI',
  'GOLF R',
  'ID.4',
  'JETTA',
  'JETTA GLI',
  'TAOS',
  'TIGUAN',
];

/// Modelos reales de BMW 2024 en la API de calificaciones de NHTSA.
const List<String> bmw2024Models = [
  '2 SERIES COUPE',
  '3 SERIES HYBRID SEDAN',
  '3 SERIES SEDAN',
  '4 SERIES CONVERTIBLE',
  'I4 GRAN COUPE',
  'I7 SEDAN',
  'IX',
  'M2 COUPE',
  'M3 SEDAN',
  'M4 CONVERTIBLE',
  'M4 COUPE',
  'X5',
];

/// Modelos reales de Ford 2024 de NHTSA donde Ranger solo tiene SuperCrew.
const List<String> fordRanger2024Models = [
  'MAVERICK',
  'MUSTANG',
  'RANGER (SUPER CREW)',
];

/// Modelos reales de Toyota 2024 híbridos de NHTSA (Sienna y Crown).
const List<String> toyotaHybrid2024Models = [
  'CROWN HYBRID',
  'SIENNA HYBRID',
  'SEQUOIA HYBRID',
  'VENZA HYBRID',
];
