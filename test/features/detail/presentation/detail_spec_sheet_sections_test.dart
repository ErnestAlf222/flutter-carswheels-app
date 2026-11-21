import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/detail/detail.dart';
import 'package:cars_wheels_app/features/detail/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

Widget _host(List<SpecEntryEntity> entries, {double scale = 1.0}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(360, 780),
          textScaler: TextScaler.linear(scale),
        ),
        child: Scaffold(
          body: Stack(
            children: [
              DetailSpecBubbleWidget(entries: entries, subtitle: 'Versión'),
            ],
          ),
        ),
      ),
    );

const _entries = [
  SpecEntryEntity(
    label: 'Cilindros',
    value: '4 cil',
    kind: SpecKind.cylinders,
    section: SpecSection.engine,
  ),
  SpecEntryEntity(
    label: 'Consumo combinado',
    value: '14.6 km/l · 34.3 mpg',
    kind: SpecKind.combinedConsumption,
    section: SpecSection.consumption,
  ),
  SpecEntryEntity(
    label: 'Combustible',
    value: 'Eléctrico',
    kind: SpecKind.fuel,
    section: SpecSection.energy,
    engineKindName: 'electric',
  ),
];

void main() {
  testWidgets('el panel muestra solo las secciones con datos y sus íconos', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_entries));
    await tester.tap(find.bySemanticsLabel(AppTexts.specSheetOpenLabel));
    await tester.pumpAndSettle();
    expect(find.text(SpecSheetTexts.engineSection), findsOneWidget);
    expect(find.text(SpecSheetTexts.consumptionSection), findsOneWidget);
    expect(find.text(SpecSheetTexts.energySection), findsOneWidget);
    expect(find.text(SpecSheetTexts.bodySection), findsNothing);
    expect(find.byIcon(Symbols.engineering), findsOneWidget);
    expect(find.byIcon(Symbols.avg_pace), findsOneWidget);
    expect(find.byIcon(Symbols.bolt), findsOneWidget);
  });

  testWidgets('sin datos no hay burbuja', (tester) async {
    await tester.pumpWidget(_host(const []));
    expect(find.bySemanticsLabel(AppTexts.specSheetOpenLabel), findsNothing);
  });

  testWidgets('a 360 dp y texto 1.3 no desborda', (tester) async {
    await tester.pumpWidget(_host(_entries, scale: 1.3));
    await tester.tap(find.bySemanticsLabel(AppTexts.specSheetOpenLabel));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('cada tipo de dato tiene su ícono', () {
    for (final kind in SpecKind.values) {
      final icon = SpecIconMapper.iconFor(
        SpecEntryEntity(label: 'x', value: 'y', kind: kind),
      );
      expect(icon, isNotNull);
    }
  });
}
