import 'package:cars_wheels_app/core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const items = [
    FloatingNavItemModel(icon: Symbols.home, label: AppTexts.navHomeLabel),
    FloatingNavItemModel(icon: Symbols.search, label: AppTexts.navSearchLabel),
  ];

  Widget build({required bool visible, required ValueChanged<int> onSelected}) {
    return MaterialApp(
      home: Scaffold(
        body: FloatingNavBar(
          items: items,
          currentIndex: 0,
          onSelected: onSelected,
          visible: visible,
        ),
      ),
    );
  }

  testWidgets('muestra los botones y avisa el índice tocado', (tester) async {
    final List<int> taps = [];
    await tester.pumpWidget(build(visible: true, onSelected: taps.add));
    expect(find.byIcon(Symbols.home), findsOneWidget);
    expect(find.byIcon(Symbols.search), findsOneWidget);
    await tester.tap(find.byIcon(Symbols.search));
    expect(taps, [1]);
  });

  testWidgets('es una sola píldora tinta y el ítem activo es amarillo', (
    tester,
  ) async {
    await tester.pumpWidget(build(visible: true, onSelected: (_) {}));
    final decorations = tester
        .widgetList<DecoratedBox>(find.byType(DecoratedBox))
        .map((box) => box.decoration as BoxDecoration);
    expect(decorations.where((d) => d.color == AppColors.accent), hasLength(1));
    final pills = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => (c.decoration as BoxDecoration?)?.color == AppColors.ink);
    expect(pills, hasLength(1));
    final active = tester.widget<Icon>(find.byIcon(Symbols.home));
    expect(active.color, AppColors.ink);
    final inactive = tester.widget<Icon>(find.byIcon(Symbols.search));
    expect(inactive.color, AppColors.navInactive);
  });

  testWidgets('la altura de la píldora sale de NavConfig', (tester) async {
    await tester.pumpWidget(build(visible: true, onSelected: (_) {}));
    final pill = find.ancestor(
      of: find.byIcon(Symbols.home),
      matching: find.byType(Container),
    );
    expect(tester.getSize(pill.last).height, NavConfig.pillHeight);
  });

  testWidgets('oculto no recibe toques', (tester) async {
    final List<int> taps = [];
    await tester.pumpWidget(build(visible: false, onSelected: taps.add));
    await tester.tap(find.byIcon(Symbols.home), warnIfMissed: false);
    expect(taps, isEmpty);
  });
}
