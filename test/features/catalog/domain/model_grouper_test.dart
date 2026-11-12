import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/catalog/catalog.dart';
import 'package:flutter_test/flutter_test.dart';

const _grouper = ModelGrouper(
  sortStrategy: AdaptiveSortStrategy<ModelGroupEntity>(
    smallListStrategy: BubbleSortStrategy<ModelGroupEntity>(),
    largeListStrategy: ShellSortStrategy<ModelGroupEntity>(),
  ),
);

List<ModelGroupEntity> _group(String brand, List<String> names) =>
    _grouper.group(brand, [for (final name in names) ModelEntity(name: name)]);

ModelGroupEntity _find(List<ModelGroupEntity> groups, String name) =>
    groups.singleWhere((group) => group.name == name);

List<String> _names(ModelGroupEntity group) =>
    group.variants.map((model) => model.name).toList();

void main() {
  group('Toyota 2020', () {
    const camry = [
      'Camry',
      'Camry AWD LE/SE',
      'Camry AWD XLE/XSE',
      'Camry Hybrid LE',
      'Camry Hybrid XLE/SE',
      'Camry LE/SE',
      'Camry TRD',
      'Camry XLE/XSE',
      'Camry XSE',
    ];
    const corolla = [
      'Corolla',
      'Corolla Hatchback',
      'Corolla Hatchback XSE',
      'Corolla Hybrid',
      'Corolla XLE',
      'Corolla XSE',
    ];
    const highlander = [
      'Highlander',
      'Highlander AWD',
      'Highlander Hybrid',
      'Highlander Hybrid AWD',
      'Highlander Hybrid AWD LTD/PLAT',
    ];
    const prius = ['Prius', 'Prius AWD', 'Prius c', 'Prius Eco', 'Prius Prime'];
    const rav4 = [
      'RAV4',
      'RAV4 AWD',
      'RAV4 AWD LE',
      'RAV4 AWD TRD OFFROAD',
      'RAV4 Hybrid AWD',
    ];
    const avalon = [
      'Avalon',
      'Avalon Hybrid',
      'Avalon Hybrid XLE',
      'Avalon XLE',
    ];
    final all = [
      ...camry,
      ...corolla,
      ...highlander,
      ...prius,
      ...rav4,
      ...avalon,
    ];

    test('cada familia forma un grupo con todas sus variantes', () {
      final groups = _group('Toyota', all);
      expect(groups.length, 6);
      expect(_names(_find(groups, 'Camry')), camry);
      expect(_names(_find(groups, 'Corolla')), corolla);
      expect(_names(_find(groups, 'Highlander')), highlander);
      expect(_names(_find(groups, 'Prius')), prius);
      expect(_names(_find(groups, 'RAV4')), rav4);
      expect(_names(_find(groups, 'Avalon')), avalon);
    });

    test('los grupos salen ordenados sin distinguir mayúsculas', () {
      final groups = _group('Toyota', all.reversed.toList());
      expect(groups.map((g) => g.name), [
        'Avalon',
        'Camry',
        'Corolla',
        'Highlander',
        'Prius',
        'RAV4',
      ]);
    });

    test('las variantes conservan el orden de la lista original', () {
      final groups = _group('Toyota', ['Camry XSE', 'Camry', 'Camry TRD']);
      expect(groups.single.name, 'Camry');
      expect(_names(groups.single), ['Camry XSE', 'Camry', 'Camry TRD']);
    });
  });

  test('Jeep: Cherokee y Grand Cherokee son grupos distintos', () {
    final groups = _group('Jeep', [
      'Cherokee 4WD',
      'Cherokee 4WD Active Drive II',
      'Cherokee FWD',
      'Cherokee Trailhawk 4WD',
      'Grand Cherokee 2WD',
      'Grand Cherokee 4WD',
      'Grand Cherokee SRT 4WD',
      'Grand Cherokee Trackhawk 4WD',
    ]);
    expect(groups.map((g) => g.name), ['Cherokee', 'Grand Cherokee']);
    expect(_find(groups, 'Cherokee').variants.length, 4);
    expect(_find(groups, 'Grand Cherokee').variants.length, 4);
  });

  test('Hyundai: Ioniq y Santa Fe', () {
    final groups = _group('Hyundai', [
      'Ioniq',
      'Ioniq Blue',
      'Ioniq Electric',
      'Ioniq Plug-in Hybrid',
      'Santa Fe',
      'Santa Fe 4WD',
    ]);
    expect(groups.map((g) => g.name), ['Ioniq', 'Santa Fe']);
    expect(_find(groups, 'Ioniq').variants.length, 4);
    expect(_find(groups, 'Santa Fe').variants.length, 2);
  });

  test('Audi: sufijos propios de la marca y sufijos generales', () {
    final groups = _group('Audi', [
      'A6 e-tron',
      'A6 e-tron quattro',
      'A6 e-tron quattro ultra',
      'A6 e-tron ultra',
      'A6 Sedan',
      'Q5 TFSI',
      'Q5 Sportback TFSI',
      'S5 Sport',
      'RS e-tron GT Performance',
    ]);
    expect(groups.map((g) => g.name), ['A6', 'Q5', 'RS e-tron GT', 'S5']);
    expect(_find(groups, 'A6').variants.length, 5);
    expect(_find(groups, 'Q5').variants.length, 2);
    expect(_find(groups, 'S5').variants.length, 1);
    expect(_find(groups, 'RS e-tron GT').variants.length, 1);
  });

  test('los sufijos de Audi no se aplican a otras marcas', () {
    final groups = _group('Honda', ['Civic Sport', 'Civic']);
    expect(_find(groups, 'Civic').variants.length, 2);
  });

  // Datos sintéticos: no son nombres medidos con FuelEconomy.
  test('familias protegidas de Land Rover no se unen a un nombre corto', () {
    final groups = _group('Land Rover', [
      'Range Rover',
      'Range Rover 4WD',
      'Range Rover Sport',
      'Range Rover Sport 4WD',
      'Range Rover Evoque',
      'Discovery',
    ]);
    expect(groups.length, 4);
    expect(_find(groups, 'Range Rover').variants.length, 2);
    expect(_find(groups, 'Range Rover Sport').variants.length, 2);
    expect(_find(groups, 'Range Rover Evoque').variants.length, 1);
    expect(_find(groups, 'Discovery').variants.length, 1);
  });

  group('casos borde', () {
    test('lista vacía devuelve vacía', () {
      expect(_group('Honda', const []), isEmpty);
    });

    test('un nombre que solo es un sufijo se conserva', () {
      final groups = _group('Honda', ['Hybrid', 'Twin Motor']);
      expect(groups.map((g) => g.name), ['Hybrid', 'Twin']);
    });

    test('los paréntesis no quedan en el nombre del grupo', () {
      final groups = _group('Volvo', [
        'EX60 P10 AWD electric (22 Inch Wheels)',
      ]);
      expect(groups.single.name, 'EX60 P10');
      expect(_names(groups.single).single, contains('(22 Inch Wheels)'));
    });

    test('nombres idénticos no se duplican', () {
      final groups = _group('Honda', ['Civic', 'Civic', 'Civic 4Dr']);
      expect(groups.single.variants.length, 2);
    });

    test('mayúsculas mezcladas forman un grupo con el nombre del primero', () {
      final groups = _group('Toyota', ['Prius', 'prius C', 'Prius c']);
      expect(groups.length, 1);
      expect(groups.single.name, 'Prius');
      expect(groups.single.variants.length, 3);
    });

    test('un prefijo debe ser de palabras completas', () {
      expect(_group('Honda', ['Civic', 'Civics']).length, 2);
    });

    test('un sufijo debe ser una palabra completa', () {
      final groups = _group('Honda', ['Civic Hybridx', 'Fit Hybrid']);
      expect(groups.map((g) => g.name), ['Civic Hybridx', 'Fit']);
    });

    test('un sufijo en otras mayúsculas se quita igual', () {
      final groups = _group('Honda', ['Civic', 'Civic AWD', 'Civic awd']);
      expect(groups.single.variants.length, 3);
    });
  });
  group('Día 6G', () {
    test('BMW: Gran Coupe, xDrive/sDrive y Competition', () {
      final gran = _group('BMW', ['228i xDrive Gran Coupe']);
      expect(gran.single.name, '228i');
      final x1 = _group('BMW', ['X1 sDrive28i', 'X1 xDrive28i']);
      expect(x1.single.name, 'X1');
      expect(x1.single.variants.length, 2);
      final m2 = _group('BMW', ['M2 Competition', 'M2 CS']);
      expect(m2.single.name, 'M2');
      expect(m2.single.variants.length, 2);
    });

    test('Ford 2020: F150 forma un solo grupo F-150', () {
      const names = [
        'F150 2WD BASE PAYLOAD LT TIRE',
        'F150 2WD FFV BASE PAYLOAD LT',
        'F150 5.0L 2WD FFV GVWR>7599 LBS',
        'F150 Pickup 2WD',
        'F150 Pickup 2WD FFV',
        'F150 Pickup 2WD Limited',
        'F150 Pickup 4WD',
        'F150 Pickup 4WD FFV',
        'F150 Pickup 4WD Limited',
        'F150 Pickup 4WD XL/XLT',
        'F150 RAPTOR 4WD',
      ];
      final groups = _group('Ford', names);
      expect(groups.single.name, 'F-150');
      expect(groups.single.variants.length, 11);
    });

    test('Ford 2020: Transit Connect y Transit son grupos distintos', () {
      final groups = _group('Ford', [
        'Transit Connect Van',
        'Transit Connect Wagon LWB',
        'Transit Connect USPS',
        'Transit T150 Wagon 2WD FFV',
        'Transit T150 Wagon 4WD FFV',
      ]);
      expect(_find(groups, 'Transit Connect').variants.length, 3);
      expect(_find(groups, 'Transit').variants.length, 2);
    });

    test('Ford: Shelby GT350 Mustang y Mustang son distintos', () {
      final groups = _group('Ford', ['Shelby GT350 Mustang', 'Mustang']);
      expect(groups.length, 2);
    });

    test('Audi: Sportback se quita de cualquier posición', () {
      final q6 = _group('Audi', ['Q6 e-tron', 'Q6 Sportback e-tron']);
      expect(q6.single.name, 'Q6 e-tron');
      final sq6 = _group('Audi', ['SQ6 e-tron', 'SQ6 Sportback e-tron']);
      expect(sq6.single.name, 'SQ6 e-tron');
      final q5 = _group('Audi', ['Q5 TFSI', 'Q5 Sportback TFSI']);
      expect(q5.single.name, 'Q5');
      expect(q5.single.variants.length, 2);
    });

    test('Volkswagen: Atlas Cross Sport es una familia protegida', () {
      final groups = _group('Volkswagen', [
        'Atlas',
        'Atlas Cross Sport',
        'Atlas Cross Sport 4motion',
      ]);
      expect(groups.length, 2);
      expect(_find(groups, 'Atlas').variants.length, 1);
      expect(_find(groups, 'Atlas Cross Sport').variants.length, 2);
    });
  });
}
