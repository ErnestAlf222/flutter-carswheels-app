import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cars_wheels_app/core/core.dart';
import 'package:cars_wheels_app/features/compare/compare.dart';

CompareChartBarEntity _bar(int index, double? value, {bool best = false}) =>
    CompareChartBarEntity(
      slotIndex: index,
      value: value,
      valueText: '$value',
      isBest: best,
    );

const List<String> _names = ['Toyota Corolla', 'Honda Civic', 'Kia Rio'];

final CompareChartMetricEntity _consumption = CompareChartMetricEntity(
  kind: CompareRowKind.combinedConsumption,
  label: AppTexts.compareChartConsumption,
  bars: [_bar(0, 14.6), _bar(1, 16.0, best: true)],
);
final CompareChartMetricEntity _co2 = CompareChartMetricEntity(
  kind: CompareRowKind.co2,
  label: AppTexts.compareChartCo2,
  bars: [_bar(0, 150), _bar(1, 120, best: true)],
);
final CompareChartMetricEntity _cost = CompareChartMetricEntity(
  kind: CompareRowKind.annualCost,
  label: AppTexts.compareChartAnnualCost,
  bars: [_bar(0, 2000), _bar(1, 1500, best: true)],
);
final CompareChartMetricEntity _missing = CompareChartMetricEntity(
  kind: CompareRowKind.combinedConsumption,
  label: AppTexts.compareChartConsumption,
  bars: [_bar(0, 14.6), _bar(1, null), _bar(2, 16.0, best: true)],
);

Widget _host(
  Widget child, {
  bool still = true,
  double textScale = 1.0,
  double width = 360,
}) => MaterialApp(
  builder: (context, widget) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      size: Size(width, 800),
      disableAnimations: still,
      textScaler: TextScaler.linear(textScale),
    ),
    child: widget!,
  ),
  home: Scaffold(
    body: SizedBox(width: width, child: child),
  ),
);

Finder get _cardText => find.descendant(
  of: find.byType(CompareVerdictCardWidget),
  matching: find.byType(Text),
);

Text _textOf(WidgetTester tester) => tester.widget<Text>(_cardText.last);

// Sin los caracteres de unión que evitan cortar "km/l" y "%" entre líneas.
String _plain(WidgetTester tester) =>
    _textOf(tester).textSpan!
        .toPlainText()
        .replaceAll('⁠', '')
        .replaceAll(' ', ' ');

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('consumo: dice quién ahorra más, cuánto y el porcentaje', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(CompareVerdictCardWidget(metric: _consumption, names: _names)),
    );
    expect(
      _plain(tester),
      'El Honda Civic ahorra más combustible: 1.4 km/l, 10 % más eficiente '
      'que el Toyota Corolla',
    );
  });

  testWidgets('CO₂ y costo anual usan su propio texto', (tester) async {
    await tester.pumpWidget(
      _host(CompareVerdictCardWidget(metric: _co2, names: _names)),
    );
    expect(
      _plain(tester),
      'El Honda Civic emite menos: 30 g/km menos, 20 % menos que el Toyota '
      'Corolla',
    );
    await tester.pumpWidget(
      _host(CompareVerdictCardWidget(metric: _cost, names: _names)),
    );
    await tester.pump();
    expect(
      _plain(tester),
      'El Honda Civic cuesta menos al año: \$500 menos, 25 % menos que el '
      'Toyota Corolla',
    );
  });

  testWidgets('el ganador va en negrita tinta y solo la medalla es amarilla', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(CompareVerdictCardWidget(metric: _consumption, names: _names)),
    );
    final root = _textOf(tester).textSpan! as TextSpan;
    final spans = root.children!.whereType<TextSpan>().toList();
    final winner = spans.firstWhere((span) => span.text == 'Honda Civic');
    expect(winner.style!.fontWeight, FontWeight.w700);
    expect(winner.style!.color, AppColors.ink);
    for (final span in spans) {
      expect(span.style!.color, isNot(AppColors.accent));
    }
    final medals = tester
        .widgetList<Container>(
          find.descendant(
            of: find.byType(CompareVerdictCardWidget),
            matching: find.byType(Container),
          ),
        )
        .map((container) => container.decoration)
        .whereType<BoxDecoration>()
        .where((decoration) => decoration.color == AppColors.accent);
    expect(medals.length, 1);
  });

  testWidgets('con un dato faltante no hay veredicto y se nombra el auto', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(CompareVerdictCardWidget(metric: _missing, names: _names)),
    );
    expect(_plain(tester), 'Sin dato de consumo para Honda Civic');
    expect(_plain(tester), isNot(contains('ahorra')));
  });

  testWidgets('empate de dos autos', (tester) async {
    final tie = CompareChartMetricEntity(
      kind: CompareRowKind.combinedConsumption,
      label: 'x',
      bars: [_bar(0, 15), _bar(1, 15)],
    );
    await tester.pumpWidget(
      _host(CompareVerdictCardWidget(metric: tie, names: _names)),
    );
    expect(_plain(tester), 'Toyota Corolla y Honda Civic consumen igual');
  });

  testWidgets('sin animaciones el veredicto cambia de inmediato', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(CompareVerdictCardWidget(metric: _consumption, names: _names)),
    );
    await tester.pumpWidget(
      _host(CompareVerdictCardWidget(metric: _co2, names: _names)),
    );
    await tester.pump();
    // Sin tiempo de transición: solo queda el veredicto nuevo.
    expect(_cardText, findsOneWidget);
    expect(_plain(tester), contains('emite menos'));
  });

  testWidgets('con animaciones el nuevo veredicto entra con fundido', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        CompareVerdictCardWidget(metric: _consumption, names: _names),
        still: false,
      ),
    );
    await tester.pumpWidget(
      _host(
        CompareVerdictCardWidget(metric: _co2, names: _names),
        still: false,
      ),
    );
    await tester.pump(AppMotion.fast);
    expect(
      find.descendant(
        of: find.byType(CompareVerdictCardWidget),
        matching: find.byType(FadeTransition),
      ),
      findsWidgets,
    );
    await tester.pumpAndSettle();
    expect(_plain(tester), contains('emite menos'));
  });

  testWidgets('sin desbordes a 360 dp y texto 1.3', (tester) async {
    await tester.pumpWidget(
      _host(
        CompareVerdictCardWidget(metric: _consumption, names: _names),
        textScale: 1.3,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('la hoja de la gráfica cambia el veredicto con la métrica', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(
        CompareChartSheetWidget(
          metrics: [_consumption, _co2, _cost],
          names: _names,
        ),
      ),
    );
    await tester.pump();
    expect(_plain(tester), contains('ahorra más'));
    await tester.tap(find.text(AppTexts.compareChartCo2));
    await tester.pump();
    await tester.pump();
    expect(_plain(tester), contains('emite menos'));
    await tester.ensureVisible(find.text(AppTexts.compareChartAnnualCost));
    await tester.tap(find.text(AppTexts.compareChartAnnualCost));
    await tester.pump();
    await tester.pump();
    expect(_plain(tester), contains('cuesta menos'));
    expect(tester.takeException(), isNull);
  });
}
