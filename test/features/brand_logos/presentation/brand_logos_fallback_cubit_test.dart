import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/commons_logo_fixtures.dart';

class _Repository implements BrandLogosRepository {
  @override
  Future<Map<String, String>> getLogoUrlsByBrand() async => const {
    'hongqi': 'https://logos/hongqi-logo.png',
    'avatr': 'https://logos/avatr-logo.svg',
  };
}

class _Cache implements CommonsLogoCacheDatasource {
  final Map<String, CachedCommonsLogoEntity> entries = {};

  @override
  Future<CachedCommonsLogoEntity?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, CachedCommonsLogoEntity entry) async =>
      entries[key] = entry;
}

class _Datasource implements CommonsLogoDatasource {
  final List<String> searches = [];
  bool offline = false;

  @override
  Future<List<CommonsLogoCandidateEntity>> searchLogos(String brandName) async {
    searches.add(brandName);
    if (offline) throw const NetworkFailure('sin red');
    final json = commonsLogoResponses[brandName];
    return json == null
        ? const []
        : CommonsLogoDatasourceImpl.parse(jsonDecode(json));
  }
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _Datasource datasource;
  late BrandLogosCubit cubit;

  setUp(() {
    datasource = _Datasource();
    cubit = BrandLogosCubit(
      _Repository(),
      resolveCommonsLogo: ResolveCommonsLogoUseCase(
        cache: _Cache(),
        datasource: datasource,
        selector: const CommonsLogoSelector(),
        clock: DateTime.now,
      ),
    );
  });

  tearDown(() => cubit.close());

  test('Honqi usa el logo de Hongqi del conjunto por el alias', () async {
    await cubit.loadLogos();
    expect(cubit.urlFor('Honqi'), 'https://logos/hongqi-logo.png');
    cubit.ensureLogo('Honqi');
    await _settle();
    expect(datasource.searches, isEmpty);
  });

  test('una marca con logo en el conjunto no consulta Commons', () async {
    await cubit.loadLogos();
    cubit.ensureLogo('Hongqi');
    await _settle();
    expect(datasource.searches, isEmpty);
  });

  test('una marca sin logo lo trae de Commons y lo expone', () async {
    await cubit.loadLogos();
    expect(cubit.urlFor('Auteco'), isNull);
    cubit.ensureLogo('Auteco');
    await _settle();
    expect(cubit.urlFor('Auteco'), contains('Auteco_logo.svg'));
    expect(datasource.searches, ['Auteco']);
  });

  test('pedirla de nuevo no repite la búsqueda', () async {
    await cubit.loadLogos();
    cubit.ensureLogo('Auteco');
    cubit.ensureLogo('Auteco');
    await _settle();
    cubit.ensureLogo('Auteco');
    await _settle();
    expect(datasource.searches, ['Auteco']);
  });

  test('Avatr, marcado sin logo usable, usa el de Commons', () async {
    await cubit.loadLogos();
    expect(cubit.urlFor('Avatr'), isNull);
    cubit.ensureLogo('Avatr');
    await _settle();
    expect(cubit.urlFor('Avatr'), contains('Avatr_Technology_logo.svg'));
  });

  test('una marca sin logo en Commons queda sin URL', () async {
    await cubit.loadLogos();
    cubit.ensureLogo('Vizeon');
    cubit.ensureLogo('Gac');
    await _settle();
    expect(cubit.urlFor('Vizeon'), isNull);
    expect(cubit.urlFor('Gac'), isNull);
  });

  test('lo pedido antes de cargar el conjunto se resuelve al cargar', () async {
    cubit.ensureLogo('Soueast');
    await cubit.loadLogos();
    await _settle();
    expect(cubit.urlFor('Soueast'), contains('Soueast_Logo.png'));
  });

  test('sin red no falla y permite reintentar después', () async {
    await cubit.loadLogos();
    datasource.offline = true;
    cubit.ensureLogo('Auteco');
    await _settle();
    expect(cubit.urlFor('Auteco'), isNull);
    datasource.offline = false;
    cubit.ensureLogo('Auteco');
    await _settle();
    expect(cubit.urlFor('Auteco'), isNotNull);
  });
}
