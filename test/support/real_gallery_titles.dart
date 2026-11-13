import 'package:cars_wheels_app/features/photos/photos.dart';

/// Los 20 títulos reales de la búsqueda 'BMW 228' (rank = posición desde 1).
const List<String> bmw228Titles = [
  'File:Plang nama Stasiun Bumiwaluya.jpg',
  'File:BMW 228 xDrive Gran Coupé (F74, 2026) (55256563627).jpg',
  'File:BMW Isetta in VEER MALL (Yekaterinburg, Russia), 2022 02.jpg',
  'File:BMW Alpina XB7.jpg',
  'File:BMW 535i F10 (5227267038).jpg',
  'File:BMW 550i F10 (5226669841).jpg',
  'File:Bmw-fahrrad-2006.jpg',
  'File:1974 BMW E9 3.0 CSA Auto.jpg',
  'File:2023-02-11 BMW IBU World Championships Biathlon Oberhof 2023 – Men 10 km Sprint by Sandro Halank–228.jpg',
  'File:2023-02-14 BMW IBU World Championships Biathlon Oberhof 2023 – Men 20 km Individual by Sandro Halank–228.jpg',
  'File:2023-02-15 BMW IBU World Championships Biathlon Oberhof 2023 – Women 15 km Individual by Sandro Halank–228.jpg',
  'File:11-09-04-iaa-by-RalfR-228.jpg',
  'File:2023-02-10 BMW IBU World Championships Biathlon Oberhof 2023 – Women 7.5 km Sprint by Sandro Halank–228.jpg',
  'File:BMW M5 - Flickr - The Car Spy (18).jpg',
  'File:Renovation Works in Bumiwaluya Station.jpg',
  'File:BMW2022.jpeg',
  'File:Stasiun Bumiwaluya 2020.jpg',
  'File:KA Mutiara Selatan Bumiwaluya.jpg',
  'File:KITLV A686 - Station Malangbong van de Staatsspoorwegen bij Garoet, KITLV 54433.tiff',
  'File:325ix Touring.jpg',
];

/// Primeros 30 títulos reales de Commons para '2020 Toyota Corolla sedan'.
const List<String> corolla2020Titles = [
  'File:2020 Toyota Corolla LE sedan.jpg',
  'File:Toyota Corolla E210 sedan variation.jpg',
  'File:2020 Toyota Corolla LE 12-13-2019.jpg',
  'File:2020 Toyota Corolla SE 2.0L sedan, 12.28.19.jpg',
  'File:2020 Toyota Corolla Altis petrol version rear.jpg',
  'File:2020 Toyota Corolla Altis petrol version front.jpg',
  'File:Toyota Corolla Sedan (49332096123).jpg',
  'File:Toyota Corolla Sedan (49332560961).jpg',
  'File:2020 Toyota Corolla Sedan XSE (NA), Cleveland Auto Show.jpg',
  'File:2020 Toyota Corolla Sedan XSE (NA), Cleveland Auto Show (Rear).jpg',
  'File:Toyota Corolla Sedan FRS E210.png',
  'File:2020 Toyota Corolla SE.jpg',
  'File:Toyota Corolla Sedan (Brazil).jpg',
  'File:2020 Toyota Corolla Sedan Hybrid (NA), Cleveland Auto Show.jpg',
  'File:2020 Toyota Corolla LE standard front, 5.25.19.jpg',
  'File:2020 Toyota Corolla Sedan Hybrid (NA), Cleveland Auto Show (Rear).jpg',
  'File:Toyota Corolla (E210) sedan IMG 3379.jpg',
  'File:2020 Toyota Corolla SE Upgrade Package Sedan in Classic Silver Metallic, front left, 2025-04-20.jpg',
  "File:'17-'19 Toyota Corolla Sedan Chocolat-Chocolat.jpg",
  'File:Toyota Corolla (E210) sedan IMG 3229.jpg',
  'File:Toyota Corolla (E210) sedan IMG 0378.jpg',
  'File:Toyota Corolla E180 and Toyota Levin E180 rear.jpg',
  'File:1997 Toyota Corolla DX 4-door sedan (USA).png',
  'File:2020 Toyota Corolla Altis 1.8 G (ZRE211).jpg',
  'File:2021 Toyota Corolla LE, front right, 07-13-2024.jpg',
  'File:2004 Toyota Corolla Saloon (Front).png',
  'File:2004 Toyota Corolla Saloon (Rear).png',
  'File:2020 Toyota Corolla SE, Rear Right, 09-17-2020.jpg',
  'File:2020 Toyota Corolla SE rear NYIAS 2019.jpg',
  'File:2020 Toyota Corolla Hybrid front NYIAS 2019.jpg',
];

/// Candidatas con rank igual a su posición (desde 1) y fuente 'fuente-N'.
List<PhotoCandidateEntity> candidatesFrom(List<String> titles) => [
  for (final entry in titles.asMap().entries)
    PhotoCandidateEntity(
      title: entry.value,
      thumbnailUrl: 'https://upload.test/x/960px-${entry.key + 1}.jpg',
      authorName: 'autor',
      licenseName: 'CC BY-SA 4.0',
      sourceUrl: 'fuente-${entry.key + 1}',
      rank: entry.key + 1,
    ),
];
