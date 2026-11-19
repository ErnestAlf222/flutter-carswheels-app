import 'dart:convert';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/brand_logos/brand_logos.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/commons_logo_fixtures.dart';

class _FakeCache implements CommonsLogoCacheDatasource {
  final Map<String, CachedCommonsLogoEntity> entries = {};

  @override
  Future<CachedCommonsLogoEntity?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, CachedCommonsLogoEntity entry) async =>
      entries[key] = entry;
}

class _FakeDatasource implements CommonsLogoDatasource {
  final List<String> searches = [];
  Object? failure;

  @override
  Future<List<CommonsLogoCandidateEntity>> searchLogos(String brandName) async {
    searches.add(brandName);
    final error = failure;
    if (error != null) throw error;
    final json = commonsLogoResponses[brandName];
    return json == null
        ? const []
        : CommonsLogoDatasourceImpl.parse(jsonDecode(json));
  }
}

void main() {
  late _FakeCache cache;
  late _FakeDatasource datasource;
  late DateTime now;
  late ResolveCommonsLogoUseCase resolve;

  setUp(() {
    cache = _FakeCache();
    datasource = _FakeDatasource();
    now = DateTime(2026, 11, 19);
    resolve = ResolveCommonsLogoUseCase(
      cache: cache,
      datasource: datasource,
      selector: const CommonsLogoSelector(),
      clock: () => now,
    );
  });

  test('la primera vez busca y guarda; la segunda sale de la caché', () async {
    final first = await resolve('Auteco');
    final second = await resolve('Auteco');
    expect(first!.licenseName, 'Public domain');
    expect(second!.url, first.url);
    expect(datasource.searches, ['Auteco']);
    expect(cache.entries.keys.single, 'v1|brand-logo|auteco');
  });

  test('una marca sin logo guarda la búsqueda vacía y no la repite', () async {
    expect(await resolve('Vizeon'), isNull);
    expect(await resolve('Vizeon'), isNull);
    expect(datasource.searches, ['Vizeon']);
    expect(cache.entries.values.single.isMiss, isTrue);
  });

  test('la búsqueda vacía vence a los días de config y se repite', () async {
    await resolve('Vizeon');
    now = now.add(
      const Duration(days: LogosConfig.commonsLogoMissTimeToLiveDays),
    );
    await resolve('Vizeon');
    expect(datasource.searches, ['Vizeon', 'Vizeon']);
  });

  test('un logo hallado dura más que una búsqueda vacía', () async {
    await resolve('Auteco');
    now = now.add(
      const Duration(days: LogosConfig.commonsLogoMissTimeToLiveDays + 1),
    );
    await resolve('Auteco');
    expect(datasource.searches, ['Auteco']);
    now = now.add(const Duration(days: LogosConfig.commonsLogoTimeToLiveDays));
    await resolve('Auteco');
    expect(datasource.searches, ['Auteco', 'Auteco']);
  });

  test('con la red caída relanza y no guarda nada', () async {
    datasource.failure = const NetworkFailure('sin red');
    await expectLater(resolve('Auteco'), throwsA(isA<NetworkFailure>()));
    expect(cache.entries, isEmpty);
  });

  test('con la red caída sirve el logo vencido si lo hay', () async {
    await resolve('Auteco');
    now = now.add(const Duration(days: LogosConfig.commonsLogoTimeToLiveDays));
    datasource.failure = const NetworkFailure('sin red');
    expect((await resolve('Auteco'))!.licenseName, 'Public domain');
  });
}
