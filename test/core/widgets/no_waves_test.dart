import 'dart:io';

import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  test('no quedan archivos de ola en lib', () {
    final names = dartFiles
        .map((file) => file.uri.pathSegments.last.toLowerCase())
        .where((name) => name.contains('wave') || name.contains('solid_back'));
    expect(names, isEmpty);
  });

  test('no quedan símbolos de ola en lib', () {
    final symbol = RegExp(
      r'Wave(Shape|Config|Painter|Clipper|FooterWidget)|waveFootprint|'
      r'detailFooterHeight|SolidBackgroundWidget',
    );
    final offenders = dartFiles
        .where((file) => symbol.hasMatch(file.readAsStringSync()))
        .map((file) => file.path)
        .toList();
    expect(offenders, isEmpty);
  });

  testWidgets('el borde del encabezado es un BorderRadius con HeaderConfig', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HeroHeaderWidget(child: Text('hola'))),
      ),
    );
    final decoration =
        tester
                .widget<DecoratedBox>(
                  find
                      .descendant(
                        of: find.byType(HeroHeaderWidget),
                        matching: find.byType(DecoratedBox),
                      )
                      .first,
                )
                .decoration
            as BoxDecoration;
    expect(
      decoration.borderRadius,
      const BorderRadius.vertical(
        bottom: Radius.circular(HeaderConfig.bottomRadius),
      ),
    );
    expect(find.byType(ClipRRect), findsOneWidget);
  });
}
