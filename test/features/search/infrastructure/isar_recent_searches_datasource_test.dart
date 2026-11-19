import 'dart:io';

import 'package:cars_wheels_app/features/search/search.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';

import '../../../support/isar_test_support.dart';

void main() {
  late Directory directory;
  late Isar isar;
  late IsarRecentSearchesDatasource datasource;

  setUpAll(() async {
    await IsarTestSupport.prepare();
  });

  setUp(() async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    directory = await Directory.systemTemp.createTemp('isar_recent_searches');
    isar = await Isar.open(
      [RecentSearchModelSchema],
      directory: directory.path,
      name: 'prueba',
      inspector: false,
    );
    datasource = IsarRecentSearchesDatasource(isar);
  });

  tearDown(() async {
    if (IsarTestSupport.skipReason != null) return;
    await isar.close(deleteFromDisk: true);
    await directory.delete(recursive: true);
  });

  RecentSearchEntity search(String key, int millis) => RecentSearchEntity(
    key: key,
    text: key.toUpperCase(),
    searchedAt: DateTime.fromMillisecondsSinceEpoch(millis),
  );

  test('guarda, lee la más reciente primero y reemplaza todo', () async {
    if (IsarTestSupport.skipIfUnavailable()) return;
    expect(await datasource.readAll(), isEmpty);
    await datasource.replaceAll([search('a', 1000), search('b', 3000)]);
    expect((await datasource.readAll()).map((s) => s.key), ['b', 'a']);
    await datasource.replaceAll([search('c', 2000)]);
    expect((await datasource.readAll()).single, search('c', 2000));
    await datasource.replaceAll(const []);
    expect(await datasource.readAll(), isEmpty);
  });
}
