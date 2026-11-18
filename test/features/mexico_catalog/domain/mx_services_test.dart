import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/mexico_catalog/mexico_catalog.dart';
import 'package:cars_wheels_app/features/vehicle_specs/vehicle_specs.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/conuee_test_support.dart';

void main() {
  group('MxTableLabeler (cilindros)', () {
    const labeler = MxTableLabeler(labels: ConueeConfig.cylinderLabels);

    test('las grafías observadas llevan a la misma etiqueta', () {
      for (final raw in [
        '4L',
        '4 L',
        'L4',
        'I4',
        '4I',
        '4 EN LINEA',
        '4 en línea',
        '4 en Linea',
        '4 EN L',
        '4 en L',
        '4l',
      ]) {
        expect(labeler.label(raw), '4 en línea', reason: raw);
      }
      for (final raw in ['6V', '6 V', 'V6', 'V 6', '6 EN V']) {
        expect(labeler.label(raw), 'V6', reason: raw);
      }
      for (final raw in ['8V', 'V8', 'V 8', '8 en V', '8 EN V']) {
        expect(labeler.label(raw), 'V8', reason: raw);
      }
      expect(labeler.label('B6'), '6 bóxer');
      expect(labeler.label('4*'), '4');
    });

    test('"sin dato", "NO APLICA", 0 y "0 L" son nulo', () {
      for (final raw in ['sin dato', 'NO APLICA', '0', '0 L', '']) {
        expect(labeler.label(raw), isNull, reason: raw);
      }
      expect(labeler.label(null), isNull);
    });

    test('un valor desconocido se muestra tal cual y se avisa', () {
      final unknown = <String>[];
      final custom = MxTableLabeler(
        labels: ConueeConfig.cylinderLabels,
        onUnknown: unknown.add,
      );
      expect(custom.label(' W12 '), 'W12');
      expect(unknown, ['W12']);
    });
  });

  group('MxTableLabeler (transmisión)', () {
    const labeler = MxTableLabeler(labels: ConueeConfig.transmissionLabels);

    test('grafías de automática, manual y CVT', () {
      for (final raw in [
        'Automatica',
        'Automática',
        'Automatico',
        'Automático',
        'Aut0Matica',
        'At',
        'T/A',
      ]) {
        expect(labeler.label(raw), 'Automática', reason: raw);
      }
      for (final raw in ['Manual', 'Mecánica', 'Mecanica', 'Mt']) {
        expect(labeler.label(raw), 'Manual', reason: raw);
      }
      expect(labeler.label('6At'), 'Automática de 6 velocidades');
      expect(labeler.label('Mt5'), 'Manual de 5 velocidades');
      expect(labeler.label('E-Cvt'), 'e-CVT');
      expect(labeler.label('Eléctrica'), 'Eléctrica');
      expect(labeler.label('0'), isNull);
    });

    test('Dtc y Rg no se traducen: se muestran tal cual', () {
      expect(labeler.label('Dtc'), 'Dtc');
      expect(labeler.label('Rg'), 'Rg');
    });
  });

  group('MxFuelClassifier', () {
    const classifier = MxFuelClassifier();

    test('combustibles observados', () {
      expect(classifier.classify('Gasolina', 'CIVIC'), EngineKind.gasoline);
      expect(classifier.classify('Diesel', 'HILUX'), EngineKind.diesel);
      expect(classifier.classify('Híbrido', 'PRIUS'), EngineKind.hybrid);
      expect(
        classifier.classify('Gasolina/Eléctrico', 'F PACE MHEV'),
        EngineKind.hybrid,
      );
      expect(classifier.classify('Eléctrico', 'LYRIQ'), EngineKind.electric);
      expect(classifier.classify('E-Rev', 'KICKS'), EngineKind.pluginHybrid);
      expect(
        classifier.classify('Gasolina / E-Rev', 'X-TRAIL'),
        EngineKind.pluginHybrid,
      );
    });

    test(
      'PHEV, REEV, PLUG-IN y DM-i en el nombre mandan sobre el combustible',
      () {
        expect(
          classifier.classify('Gasolina', 'OUTLANDER PHEV SE PLUS'),
          EngineKind.pluginHybrid,
        );
        expect(
          classifier.classify('Gasolina', 'AVATR 07 (REEV) AWD'),
          EngineKind.pluginHybrid,
        );
        expect(
          classifier.classify('Híbrido', 'AUDI Q7 TFSI E PLUG-IN HYBRID 3.0L'),
          EngineKind.pluginHybrid,
        );
        expect(
          classifier.classify('Híbrido', 'SONG PRO DM-I'),
          EngineKind.pluginHybrid,
        );
      },
    );

    test('MHEV no es enchufable y un eléctrico sigue siendo eléctrico', () {
      expect(
        classifier.classify('Gasolina/Eléctrico', 'VELAR MHEV'),
        EngineKind.hybrid,
      );
      expect(
        classifier.classify('Eléctrico', 'ALGO PHEV'),
        EngineKind.electric,
      );
    });

    test('combustible desconocido: nulo y se avisa', () {
      final unknown = <String>[];
      final custom = MxFuelClassifier(onUnknown: unknown.add);
      expect(custom.classify('Hidrógeno', 'MIRAI'), isNull);
      expect(unknown, ['Hidrógeno']);
    });
  });

  group('MxPowerTextCleaner', () {
    const cleaner = MxPowerTextCleaner();

    test('formas inequívocas', () {
      expect(cleaner.clean('190@6000'), '190 @ 6000');
      expect(cleaner.clean('335.25 @ 5500'), '335.25 @ 5500');
      expect(cleaner.clean('270 @5500'), '270 @ 5500');
      expect(cleaner.clean('155 @ 5,600'), '155 @ 5600');
      expect(cleaner.clean('242.68@1700-5000'), '242.68 @ 1700-5000');
      expect(cleaner.clean('154.2 @ 4500~5500'), '154.2 @ 4500-5500');
      expect(cleaner.clean('299 @ 1750 - 2500'), '299 @ 1750-2500');
      expect(cleaner.clean('350@1,650 - 4,400'), '350 @ 1650-4400');
      expect(cleaner.clean('590'), '590');
    });

    test('quita MAX y PEAK', () {
      expect(cleaner.clean('46.94@ MAX'), '46.94');
      expect(cleaner.clean('135 @ PEAK'), '135');
    });

    test('patrón ambiguo o basura es nulo', () {
      expect(cleaner.clean('135±5 @ PEAK'), isNull);
      expect(cleaner.clean('95 y 5500'), isNull);
      expect(cleaner.clean('103/6000'), isNull);
      expect(cleaner.clean('221.2@9550 345.9@6190'), isNull);
      expect(cleaner.clean(''), isNull);
      expect(cleaner.clean(null), isNull);
    });
  });

  group('MxModelNameCleaner', () {
    const cleaner = MxModelNameCleaner();

    test('ejemplos reales', () {
      const cases = <(String, String, String)>[
        (
          'Audi',
          'AUDI A8 55 TFSI 3.0L 340HP MILD HYBRID TIPTRONIC QUATTRO',
          'A8',
        ),
        ('Audi', 'AUDI A3 SEDÁN TFSI 2.0L S TRONIC TRACCIÓN DELANTERA', 'A3'),
        ('Audi', 'AUDI Q7 TFSI E PLUG-IN HYBRID 3.0L TIPTRONIC QUATTRO', 'Q7'),
        (
          'Audi',
          'AUDI RS 6 AVANT PERFORMANCE 4.0T 630HP MILD HYBRID TIPTRONIC QUATTRO',
          'RS6',
        ),
        ('Alfa Romeo', 'STELVIO (SPRINT, VELOCE, TRIBUTO ITALIANO)', 'STELVIO'),
        ('Acura', 'ADX A SPEC', 'ADX'),
        ('Acura', 'INTEGRA INTEGRA', 'INTEGRA'),
        ('Ford', 'F 150 2.7L 4X2', 'F 150'),
        ('Ford', 'ESCAPE 2.5L AWD HEV', 'ESCAPE'),
        ('Land Rover', 'LAND ROVER DEFENDER 110 300 PS', 'DEFENDER 110'),
        ('Land Rover', 'RANGE ROVER VELAR 340 PS', 'VELAR'),
        ('Toyota', 'COROLLA CROSS HIBRIDO', 'COROLLA CROSS'),
        ('Chevrolet', 'AVEO A', 'AVEO'),
        ('Hyundai', 'HB20 GL TM', 'HB20'),
        ('Nissan', 'FRONTIER V6 PRO-4X, T/A', 'FRONTIER V6 PRO-4X'),
        ('Porsche', '911* CARRERA 2 PDK (COUPE)', '911 CARRERA 2'),
        ('Suzuki', 'FRONX 1.5L AT 2WD BOOSTERGREEN (ISG MILD-HYBRID)', 'FRONX'),
        ('Build Your Dreams', 'SONG PRO DM-I', 'SONG'),
      ];
      for (final (brand, raw, expected) in cases) {
        expect(cleaner.clean(brand, raw), expected, reason: raw);
      }
    });

    test('sin nada que conservar devuelve el modelo sin marca', () {
      expect(
        cleaner.clean('Porsche', '2.0 LTS 265 HP PDK TRACCION INTEGRAL'),
        '2.0 LTS 265 HP PDK TRACCION INTEGRAL',
      );
    });

    test('stripBrandPrefix solo quita la marca', () {
      expect(
        cleaner.stripBrandPrefix('Audi', 'AUDI A3 SPORTBACK TFSI 1.4L'),
        'A3 SPORTBACK TFSI 1.4L',
      );
      expect(cleaner.stripBrandPrefix('Audi', 'A3'), 'A3');
      expect(
        cleaner.stripBrandPrefix(
          'Volkswagen Comerciales',
          'VOLKSWAGEN CRAFTER',
        ),
        'CRAFTER',
      );
    });
  });

  group('MxModelGrouper', () {
    const grouper = MxModelGrouper();

    List<MxModelGroupEntity> groupOf(String brand, List<String> raws) =>
        grouper.group(brand, [for (final raw in raws) mxVehicle(brand, raw)]);

    Map<String, int> sizes(List<MxModelGroupEntity> groups) => {
      for (final group in groups) group.name: group.versions.length,
    };

    test('Audi: nombres largos y cortos caen en la misma familia', () {
      final groups = groupOf('Audi', [
        'A3',
        'AUDI A3 SEDÁN TFSI 2.0L S TRONIC TRACCIÓN DELANTERA',
        'AUDI A3 SPORTBACK TFSI 1.4L TIPTRONIC TRACCIÓN DELANTERA',
        'A8',
        'AUDI A8 55 TFSI 3.0L 340HP MILD HYBRID TIPTRONIC QUATTRO',
        'A8 LWB',
      ]);
      expect(sizes(groups), {'A3': 3, 'A8': 3});
    });

    test('Alfa Romeo: STELVIO con paréntesis de versiones', () {
      final groups = groupOf('Alfa Romeo', [
        'STELVIO (SPRINT, VELOCE, TRIBUTO ITALIANO)',
        'STELVIO (QV, QV SUPER SPORT)',
        'GIULIA (SPRINT, VELOCE, TRIBUTO ITALIANO)',
      ]);
      expect(sizes(groups), {'GIULIA': 1, 'STELVIO': 2});
    });

    test('Acura: ADX A SPEC y ADX ADVANCE son un grupo', () {
      final groups = groupOf('Acura', [
        'ADX A SPEC',
        'ADX ADVANCE',
        'INTEGRA INTEGRA',
        'INTEGRA A SPEC',
        'INTEGRA TYPE S',
      ]);
      expect(sizes(groups), {'ADX': 2, 'INTEGRA': 3});
    });

    test('familia protegida: COROLLA CROSS no se une a COROLLA', () {
      final groups = groupOf('Toyota', [
        'COROLLA',
        'COROLLA HIBRIDO',
        'COROLLA CROSS',
        'COROLLA CROSS HIBRIDO',
      ]);
      expect(sizes(groups), {'COROLLA': 2, 'COROLLA CROSS': 2});
    });

    test('Land Rover: alias, familias protegidas y NEW', () {
      final groups = groupOf('Land Rover', [
        'RANGE ROVER',
        'RANGE ROVER SPORT',
        'NEW RANGE ROVER SPORT 530 MHEV',
        'RANGE ROVER VELAR 340 PS',
        'VELAR',
      ]);
      expect(sizes(groups), {
        'RANGE ROVER': 1,
        'RANGE ROVER SPORT': 2,
        'VELAR': 2,
      });
    });

    test('base absorbente: todo lo de CAYENNE y 911 queda junto', () {
      final groups = groupOf('Porsche', [
        'CAYENNE BASIS (SUV)',
        'CAYENNE CAYENNE GT (COUPE)',
        'PORSCHE 911 CARRERA 3.0 LTS 394 HP PDK TRACCIÓN TRASERA',
        '911* GT3 MT',
      ]);
      expect(sizes(groups), {'911': 2, 'CAYENNE': 2});
    });

    test('familia indeterminada: grupo propio con el nombre limpio', () {
      final groups = groupOf('Porsche', [
        '2.0 LTS 265 HP PDK TRACCION INTEGRAL',
        'MACAN T',
      ]);
      expect(sizes(groups), {
        '2.0 LTS 265 HP PDK TRACCION INTEGRAL': 1,
        'MACAN': 1,
      });
    });

    test('guarda el nombre original y ordena los grupos por nombre', () {
      final groups = groupOf('Ford', [
        'RANGER 2.0L',
        'EXPLORER 3.0L AWD',
        'F 150 5.2L',
      ]);
      expect([for (final g in groups) g.name], ['EXPLORER', 'F 150', 'RANGER']);
      expect(groups.last.versions.single.vehicle.rawModel, 'RANGER 2.0L');
      expect(groups.last.versions.single.label, 'RANGER 2.0L');
    });
  });

  group('casos de uso', () {
    final repository = _FixedRepository(
      mxCatalog(2025, [
        mxVehicle('Audi', 'A3', id: 0),
        mxVehicle('Audi', 'AUDI A3 SEDÁN TFSI 2.0L', id: 1),
        mxVehicle('Acura', 'ADX ADVANCE', id: 2),
        mxVehicle('Gmc', 'SIERRA', id: 3),
      ]),
    );

    test('años', () async {
      expect(await GetMxYearsUseCase(repository)(), [2025]);
    });

    test('marcas con su cantidad, ordenadas', () async {
      expect(await GetMxBrandsUseCase(repository)(2025), const [
        MxBrandEntity(name: 'Acura', vehicleCount: 1),
        MxBrandEntity(name: 'Audi', vehicleCount: 2),
        MxBrandEntity(name: 'Gmc', vehicleCount: 1),
      ]);
    });

    test('grupos y versiones de una marca (sin importar mayúsculas)', () async {
      final groups = GetMxModelGroupsUseCase(
        repository: repository,
        grouper: const MxModelGrouper(),
      );
      expect([for (final g in await groups(2025, 'AUDI')) g.name], ['A3']);
      final versions = GetMxVersionsUseCase(groups);
      expect((await versions(2025, 'Audi', 'a3')).length, 2);
      expect(await versions(2025, 'Audi', 'Q9'), isEmpty);
    });
  });
}

class _FixedRepository implements MexicoCatalogRepository {
  const _FixedRepository(this.catalog);

  final MxYearCatalogEntity catalog;

  @override
  Future<List<int>> fetchYears() async => [catalog.year];

  @override
  Future<MxYearCatalogEntity> fetchYear(int year) async => catalog;
}
