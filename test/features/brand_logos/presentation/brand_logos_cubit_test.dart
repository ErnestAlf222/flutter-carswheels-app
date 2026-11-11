import 'package:bloc_test/bloc_test.dart';
import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBrandLogosRepository implements BrandLogosRepository {
  _FakeBrandLogosRepository({this.urls = const {}, this.error});

  final Map<String, String> urls;
  final Object? error;

  @override
  Future<Map<String, String>> getLogoUrlsByBrand() async {
    if (error != null) throw error!;
    return urls;
  }
}

const _urls = {
  'mclaren': 'https://logos/mclaren.svg',
  'mercedesbenz': 'https://logos/mercedes.svg',
  'gmc': 'https://logos/gmc.svg',
};

void main() {
  blocTest<BrandLogosCubit, BrandLogosState>(
    'loadLogos: loading -> loaded',
    build: () => BrandLogosCubit(_FakeBrandLogosRepository(urls: _urls)),
    act: (cubit) => cubit.loadLogos(),
    expect: () => const [BrandLogosLoading(), BrandLogosLoaded(_urls)],
  );

  blocTest<BrandLogosCubit, BrandLogosState>(
    'loadLogos: loading -> error cuando falla',
    build: () => BrandLogosCubit(
      _FakeBrandLogosRepository(error: const NetworkFailure('sin red')),
    ),
    act: (cubit) => cubit.loadLogos(),
    expect: () => const [
      BrandLogosLoading(),
      BrandLogosError(NetworkFailure('sin red')),
    ],
  );

  blocTest<BrandLogosCubit, BrandLogosState>(
    'una excepción inesperada se vuelve UnknownFailure',
    build: () =>
        BrandLogosCubit(_FakeBrandLogosRepository(error: StateError('boom'))),
    act: (cubit) => cubit.loadLogos(),
    verify: (cubit) {
      expect((cubit.state as BrandLogosError).failure, isA<UnknownFailure>());
    },
  );

  group('urlFor', () {
    late BrandLogosCubit cubit;

    setUp(() async {
      cubit = BrandLogosCubit(_FakeBrandLogosRepository(urls: _urls));
      await cubit.loadLogos();
    });

    tearDown(() => cubit.close());

    test('resuelve el alias McLaren Automotive -> McLaren', () {
      expect(cubit.urlFor('McLaren Automotive'), _urls['mclaren']);
    });

    test('resuelve el alias Gmc -> GMC', () {
      expect(cubit.urlFor('Gmc'), _urls['gmc']);
    });

    test('ignora mayúsculas y acentos', () {
      expect(cubit.urlFor('MÉRCEDES-benz'), _urls['mercedesbenz']);
      expect(cubit.urlFor('MCLAREN AUTOMOTIVE'), _urls['mclaren']);
    });

    test('una marca sin logo devuelve null', () {
      expect(cubit.urlFor('Marca Inexistente'), isNull);
    });
  });

  test('urlFor devuelve null antes de cargar', () async {
    final cubit = BrandLogosCubit(_FakeBrandLogosRepository(urls: _urls));
    expect(cubit.urlFor('McLaren'), isNull);
    await cubit.close();
  });
}
